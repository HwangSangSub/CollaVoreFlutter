import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './login.dart';

class FindPwdResultPage extends StatelessWidget {
  final TextEditingController _pwdController = TextEditingController();
  final String foundId; // 전달받은 아이디
  FindPwdResultPage({required this.foundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '변경할 비밀번호',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _pwdController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '변경할 비밀번호를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // 취소 및 아이디 찾기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // 취소 버튼 - 이전 화면으로 돌아가기
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String email = foundId;
                        String resetPwd = _pwdController.text;
                        final url =
                            Uri.parse('http://192.168.0.40:8099/api/pwdModify');
                        final response = await http.post(url,
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'email': email,
                              'resetPwd': resetPwd,
                            }));
                        late String resetResult;
                        if (response.statusCode == 200) {
                            resetResult = response.body;
                        } else {
                          resetResult = 'Error';
                        }
                        if (resetResult == 'Error') {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: const Text('비밀번호 재설정 실패'),
                                  content:
                                      const Text('비밀번호 재설정 실패입니다. 관리자에게 문의바랍니다.'),
                                  actions: [
                                    TextButton(
                                      child: const Text('확인'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('취소'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: Text('비밀번호 재설정 성공'),
                                content: Text('비밀번호가 성공적으로 재설정되었습니다.'),
                                actions: [
                                  TextButton(
                                    child: Text('확인'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false,
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // 버튼 색상
                      ),
                      child: const Text('비밀번호 재설정'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
