import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../common/apiAddress.dart';

import './FindPwdResult.dart';

class FindPwdPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 찾기'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이메일',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: '이메일을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '이름',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '이름을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // 취소 및 아이디 찾기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // 취소 버튼 - 이전 화면으로 돌아가기
                      },
                      child: Text(
                        '취소',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String email = _emailController.text;
                        String name = _nameController.text;
                        final url = Uri.parse(ApiAddress.chkUser);
                        final response = await http.post(url,
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'email': email,
                              'name': name,
                            }));
                        late String resetResult;
                        print(response.body);
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
                                  title: Text('아이디인증 실패'),
                                  content: Text('해당정보로 등록된 사원이 없습니다.'),
                                  actions: [
                                    TextButton(
                                      child: Text('확인'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('취소'),
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
                                title: Text('이메일 인증 성공'),
                                content: Text('이메일 인증이 완료되어 비밀번호 재설정으로 이동됩니다.'),
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
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FindPwdResultPage(foundId: email)),
                              (route) => false,
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // 버튼 색상
                      ),
                      child: Text('이메일 본인인증'),
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
