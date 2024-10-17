import '../../main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../provider/loginProvider.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idEditingController = TextEditingController();
  final TextEditingController _pwdEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('로그인')),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _idEditingController,
                      decoration: InputDecoration(
                        labelText: '아이디',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력하세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _pwdEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력하세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String id = _idEditingController.text;
                          String pwd = _pwdEditingController.text;
                          final url =
                              Uri.parse('http://192.168.0.40:8099/api/login');
                          final response = await http.post(url,
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode({
                                'email': id,
                                'password': pwd,
                              }));
                          late Map<String, dynamic> result;
                          late String loginId;
                          if (response.statusCode == 200) {
                            result =
                                jsonDecode(utf8.decode(response.bodyBytes));
                            loginId = result['email'];
                          } else {
                            loginId = '';
                          }
                          if (loginId == '') {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext ctx) {
                                  return AlertDialog(
                                    title: Text('로그인 실패'),
                                    content: Text('아이디 또는 비밀번호가 일치하지 않습니다.'),
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
                            Provider.of<LoginProvider>(context, listen: false)
                                .login(loginId);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHomePage()),
                              (route) => false,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/join');
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '회원가입',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '돌아가기',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
