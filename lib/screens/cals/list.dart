import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert'; // JSON 파싱용

import '../../provider/loginProvider.dart';
import './info.dart';

class CalsPage extends StatefulWidget {
  @override
  State<CalsPage> createState() => _CalsPageState();
}

class _CalsPageState extends State<CalsPage> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<dynamic> events = []; // 일정 목록 저장
  int? empNo; // empNo 저장 변수

  @override
  void initState() {
    super.initState();
    // Provider 접근 및 API 호출 예약
    Future.microtask(() {
      empNo = Provider.of<LoginProvider>(context, listen: false).empNo;
      fetchEvents(); // API 호출
    });
  }

  // API에서 일정 데이터를 가져오는 함수
  Future<void> fetchEvents() async {
    final url = Uri.parse(
        'http://192.168.0.40:8099/api/schsSelectAll?empNo=$empNo'); // API URL 설정

    try {
      final response = await http.get(url);
      print(jsonDecode(utf8.decode(response.bodyBytes))); // 응답 디코딩 후 출력
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          events = data; // 가져온 데이터를 상태에 저장
        });
      } else {
        print('일정 데이터를 불러오는 데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 달력 표시
          TableCalendar(
            onDaySelected: onDaySelected,
            selectedDayPredicate: (date) {
              return isSameDay(selectedDate, date);
            },
            focusedDay: DateTime.now(),
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2099, 12, 31),
            locale: 'ko-KR',
            daysOfWeekHeight: 30,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
              ),
            ),
          ),
          SizedBox(height: 10), // 간격 추가

          // 일정 목록 표시
          Expanded(
            child: events.isEmpty
                ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 표시
                : ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              event['schNo'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            event['schTitle'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SchsInfoPage(
                                  schNo: event['schNo'],
                                ),
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
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}
