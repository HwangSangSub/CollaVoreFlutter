import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert'; // JSON 파싱용

import '../../provider/loginProvider.dart';
import './info.dart';
import './reg.dart';

class CalsPage extends StatefulWidget {
  final DateTime? selectedDate; // 선택된 날짜를 받을 수 있는 매개변수

  const CalsPage({Key? key, this.selectedDate}) : super(key: key);

  @override
  State<CalsPage> createState() => _CalsPageState();
}

class _CalsPageState extends State<CalsPage> {
  late DateTime selectedDate; // 초기값 설정
  List<dynamic> events = []; // 일정 목록 저장
  int? empNo; // empNo 저장 변수

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now(); // 전달된 날짜가 없으면 오늘 날짜 사용

    Future.microtask(() {
      empNo = Provider.of<LoginProvider>(context, listen: false).empNo;
      fetchEventsForDate(selectedDate); // 초기 로딩 시 해당 날짜의 일정 가져오기
    });
  }

  // 특정 날짜의 일정 데이터를 가져오는 함수
  Future<void> fetchEventsForDate(DateTime date) async {
    final formattedDate = _formatDate(date);
    final url = Uri.parse(
      'http://192.168.0.40:8099/api/schsSelectAll?empNo=$empNo&selectDate=$formattedDate',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          events = data; // 가져온 일정 데이터 저장
        });
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // 날짜를 yyyy-MM-dd 형식으로 변환하는 함수
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'), // 한국어 로케일 설정
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      fetchEventsForDate(pickedDate); // 선택한 날짜의 일정 가져오기
    }
  }

  // 일정 등록 페이지로 이동하고, 등록된 날짜를 받아와 일정 조회
  Future<void> _navigateToRegPage() async {
    final DateTime? newDate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalsRegPage(selectDate: selectedDate),
      ),
    );

    // 반환된 날짜로 일정 조회
    if (newDate != null) {
      setState(() {
        selectedDate = newDate;
      });
      fetchEventsForDate(newDate); // 반환된 날짜로 일정 다시 조회
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '선택된 날짜: ${_formatDate(selectedDate)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('날짜 선택하기', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '등록된 일정이 없습니다.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              event['schTitle'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SchsInfoPage(schNo: event['schNo']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToRegPage, // 일정 등록 페이지로 이동
        child: const Icon(Icons.create),
      ),
    );
  }
}
