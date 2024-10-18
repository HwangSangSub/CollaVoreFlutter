import 'package:flutter/material.dart';
import './login.dart';

class FindIdResultPage extends StatelessWidget {
  final String foundId;  // 전달받은 아이디

  FindIdResultPage({required this.foundId});  // 생성자에서 아이디를 받음

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('아이디 찾기 결과'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '찾은 아이디:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                foundId,  // 전달받은 아이디를 출력
                style: TextStyle(fontSize: 22, color: Colors.blue),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false,
                          );
                },
                child: Text('로그인 화면으로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}