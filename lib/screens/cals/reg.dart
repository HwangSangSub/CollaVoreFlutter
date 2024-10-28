import 'package:collavore/models/cals.dart';
import 'package:collavore/screens/appr/info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // JSON 파싱용

import '../../provider/loginProvider.dart';
import '../../common/apiAddress.dart';

class CalsRegPage extends StatefulWidget {
  final DateTime selectDate; // 선택된 날짜를 외부에서 전달받음

  const CalsRegPage({Key? key, required this.selectDate}) : super(key: key);

  @override
  State<CalsRegPage> createState() => _CalsRegPageState();
}

class _CalsRegPageState extends State<CalsRegPage> {
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate; // 초기 날짜를 외부에서 전달받도록 변경

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectDate; // 초기값 설정
  }

  // 날짜 선택기 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'), // 한국어 설정
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // 선택된 날짜로 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int? empNo = Provider.of<LoginProvider>(context, listen: false).empNo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 선택된 날짜 표시
              Row(
                children: <Widget>[
                  Text(
                    DateFormat.yMMMd('ko_KR').format(_selectedDate),
                    style: const TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _selectDate(context), // 날짜 선택기 호출
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 제목 입력 필드
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '등록할 제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (empNo != null && _formKey.currentState!.validate()) {
                        String title = _titleController.text;
                        Cals cals = Cals(
                          title: title,
                          empNo: empNo,
                          date: _selectedDate,
                        );

                        bool success = await _registerEvent(cals);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('일정이 성공적으로 등록되었습니다.'),
                            ),
                          );
                          Navigator.pop(context, _selectedDate);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('일정 등록에 실패했습니다.'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 5),
                        Text(
                          '등록',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 이전 화면으로 돌아가기
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 5),
                        Text(
                          '돌아가기',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 서버에 일정 등록하는 함수
  Future<bool> _registerEvent(Cals cals) async {
    try {
      final response = await http.post(
        Uri.parse(ApiAddress.schsAdd),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schTitle': cals.title,
          'empNo': cals.empNo,
          'selectDate': DateFormat('yyyy-MM-dd').format(cals.date),
        }),
      );

      if (response.statusCode == 200) {
        return true; // 등록 성공
      } else {
        return false; // 등록 실패
      }
    } catch (e) {
      return false;
    }
  }
}
