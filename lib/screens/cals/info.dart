import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱용

class SchsInfoPage extends StatefulWidget {
  final int schNo; // schNo를 전달받기 위한 변수

  const SchsInfoPage({Key? key, required this.schNo}) : super(key: key);

  @override
  _SchsInfoPageState createState() => _SchsInfoPageState();
}

class _SchsInfoPageState extends State<SchsInfoPage> {
  Map<String, dynamic>? scheduleDetail; // 일정 상세 정보를 저장할 변수

  @override
  void initState() {
    super.initState();
    fetchScheduleDetail(); // 페이지 초기화 시 API 호출
  }

  // API에서 일정 상세 정보를 가져오는 함수
  Future<void> fetchScheduleDetail() async {
    final url = Uri.parse(
        'http://192.168.0.40:8099/api/schsInfo?schNo=${widget.schNo}'); // API URL 설정

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          scheduleDetail =
              jsonDecode(utf8.decode(response.bodyBytes)); // 상세 정보 저장
        });
      } else {
        print('상세 정보를 불러오는 데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일정 상세보기'),
      ),
      body: scheduleDetail == null
          ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '일정 번호: ${scheduleDetail!['schNo']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '제목: ${scheduleDetail!['schTitle']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '시작일: ${scheduleDetail!['startDate']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '종료일: ${scheduleDetail!['endDate']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
