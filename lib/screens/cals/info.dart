import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 날짜 포맷용 패키지
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

  // 날짜 문자열을 '년-월-일 시:분' 형식으로 변환하는 함수
  String formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 상세보기'),
      ),
      body: scheduleDetail == null
          ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          scheduleDetail!['schTitle'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.numbers,
                        label: '일정 번호',
                        value: scheduleDetail!['schNo'].toString(),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: '시작일',
                        value: formatDateTime(scheduleDetail!['startDate']),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: '종료일',
                        value: formatDateTime(scheduleDetail!['endDate']),
                      ),
                      // const SizedBox(height: 10),
                      // _buildInfoRow(
                      //   icon: Icons.notes,
                      //   label: '메모',
                      //   value: scheduleDetail!['notes'] ?? '메모가 없습니다.',
                      // ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // 일정 정보를 보여주는 위젯 생성 함수
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
