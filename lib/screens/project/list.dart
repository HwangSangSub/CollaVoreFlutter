import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ProjectPage extends StatefulWidget {
  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  // 초기 선택 날짜를 현재 날짜로 설정
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱 바 설정
      // appBar: AppBar(
      //   title: Text('프로젝트관리'), // 앱 바의 타이틀 설정
      // ),
      body: Center(
        child: TableCalendar(
          // 캘린더에서 날짜가 선택될때 이벤트
          onDaySelected: onDaySelected,
          // 특정 날짜가 선택된 날짜와 동일한지 여부 판단
          selectedDayPredicate: (date) {
            return isSameDay(selectedDate, date);
          },
          focusedDay: DateTime.now(),
          firstDay: DateTime(2024, 1, 1),
          lastDay: DateTime(2099, 12, 31),
          locale: 'ko-KR',
          daysOfWeekHeight: 30,
          // 달력 헤더의 스타일 설정
          headerStyle: HeaderStyle(
            titleCentered: true, // 타이틀을 가운데 정렬
            formatButtonVisible: false, // 헤더에 있는 버튼 숨김
            // 타이틀 텍스트 스타일 설정
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700, // 타이틀 텍스트 두께
              fontSize: 20.0, // 타이틀 텍스트 크기
            ),
          ),
        ),
      ),
    );
  }

  // 달력에서 날짜가 선택됐을 때 호출되는 콜백 함수
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}
