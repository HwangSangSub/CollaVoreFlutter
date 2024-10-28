import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/loginProvider.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late int empNo;
  late TextEditingController nameController;
  late TextEditingController jobController;
  late TextEditingController positionController;
  late TextEditingController telController;
  late TextEditingController infoController;
  late TextEditingController passwordController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    empNo = Provider.of<LoginProvider>(context, listen: false).empNo!;
    nameController = TextEditingController();
    jobController = TextEditingController();
    positionController = TextEditingController();
    telController = TextEditingController();
    infoController = TextEditingController();
    passwordController = TextEditingController();
    _fetchUserInfo();
  }

  // 회원 정보 조회
  Future<void> _fetchUserInfo() async {
    final url = Uri.parse('http://192.168.0.40:8099/api/userInfo?empNo=$empNo');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          nameController.text = data['name'] ?? '';
          jobController.text = data['jobName'] ?? '';
          positionController.text = data['posiName'] ?? '';
          telController.text = data['tel'] ?? '';
          infoController.text = data['info'] ?? '';
        });
      } else {
        _showErrorDialog('회원 정보를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('오류가 발생했습니다: $e');
    }
  }

  // 전화번호 형식 적용 함수
  String _formatPhoneNumber(String input) {
    final digitsOnly = input.replaceAll(RegExp(r'\D'), ''); // 숫자 이외 제거
    if (digitsOnly.length <= 3) {
      return digitsOnly;
    } else if (digitsOnly.length <= 7) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    } else {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7, 11)}';
    }
  }

  // 전화번호 입력 핸들러
  void _onPhoneChanged(String value) {
    final formatted = _formatPhoneNumber(value);
    telController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _updateUserInfo() async {
    final url = Uri.parse('http://192.168.0.40:8099/api/updateUserInfo');
    final request = http.MultipartRequest('POST', url);

    // 필드 추가
    request.fields['empNo'] = empNo.toString();
    request.fields['tel'] = telController.text;
    request.fields['info'] = infoController.text;
    request.fields['password'] = passwordController.text;

    // 이미지 파일이 있을 경우 추가
    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'img', // 서버의 파라미터 이름과 일치해야 함
        _selectedImage!.path,
      ));
      print(_selectedImage!.path);
    }

    try {
      final response = await request.send(); // 요청 보내기
      if (response.statusCode == 200) {
        _showSuccessDialog('회원 정보가 성공적으로 업데이트되었습니다.');
      } else {
        _showErrorDialog('회원 정보 업데이트에 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('오류가 발생했습니다: $e');
    }
  }

// 성공 메시지 표시
  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성공'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

// 오류 메시지 표시
  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 사진 선택
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : const AssetImage('assets/images/member/default.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _buildReadOnlyTextField(
                controller: nameController,
                label: '이름',
                icon: Icons.badge,
              ),
              const SizedBox(height: 20),
              _buildReadOnlyTextField(
                controller: jobController,
                label: '직무',
                icon: Icons.work,
              ),
              const SizedBox(height: 20),
              _buildReadOnlyTextField(
                controller: positionController,
                label: '직급',
                icon: Icons.business_center,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: telController,
                label: '핸드폰 번호',
                icon: Icons.phone,
                onChanged: _onPhoneChanged,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildMultiLineTextField(
                controller: infoController,
                label: '소개글',
                icon: Icons.text_snippet,
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: passwordController,
                label: '비밀번호',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateUserInfo,
                child: const Text('정보 업데이트'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 읽기 전용 텍스트 필드 위젯 생성
  Widget _buildReadOnlyTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // 일반 텍스트 필드 위젯 생성
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // 다중 줄 텍스트 필드 위젯 생성
  Widget _buildMultiLineTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int minLines,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
