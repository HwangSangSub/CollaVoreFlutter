import 'package:flutter/material.dart';

class FindIdPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

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
                  controller: _contactController,
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
                      onPressed: () {
                        // 아이디 찾기 로직 추가
                        print('아이디 찾기');
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
