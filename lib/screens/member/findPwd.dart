import 'package:flutter/material.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 재설정'),
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
                // 이메일 입력 필드
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

                // 취소 및 비밀번호 재설정 버튼
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
                      onPressed: () {
                        // 비밀번호 재설정 로직 추가
                        print('비밀번호 재설정');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // 버튼 색상
                      ),
                      child: Text('비밀번호 재설정'),
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
