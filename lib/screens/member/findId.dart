import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './findIdResult.dart';
import '../../common/apiAddress.dart';

class FindIdPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('아이디 찾기'),
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
                // 이름 입력 필드
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

                // 연락처 입력 필드
                Text(
                  '연락처',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _telController,
                  decoration: InputDecoration(
                    hintText: '연락처를 입력하세요',
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
                        String name = _nameController.text;
                        String tel = _telController.text;
                        final url = Uri.parse(ApiAddress.findId);
                        final response = await http.post(url,
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'name': name,
                              'tel': tel,
                            }));
                        late String chkId;
                        if (response.statusCode == 200) {
                          if (response.body != '') {
                            chkId = response.body;
                          } else {
                            chkId = '';
                          }
                        } else {
                          chkId = '';
                        }
                        if (chkId == '') {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: Text('아이디찾기 실패'),
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FindIdResultPage(foundId: chkId)),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // 버튼 색상
                      ),
                      child: Text('아이디 찾기'),
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
