class Cals {
  int? schNo;
  String title;
  int empNo;
  DateTime date;

  // 생성자에서 모든 필드를 초기화
  Cals({
    this.schNo,
    required this.title,
    required this.empNo,
    required DateTime date,
  }) : date = date; // date 필드 초기화

  // Map에서 객체로 변환하는 팩토리 생성자
  factory Cals.from(Map<String, dynamic> map) {
    return Cals(
      schNo: map['schNo'] as int?,
      title: map['title'] as String,
      empNo: map['empNo'] as int,
      date: DateTime.parse(map['date'] as String),
    );
  }

  // 객체를 Map으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'schNo': schNo,
      'title': title,
      'empNo': empNo,
      'date': date.toIso8601String(), // ISO 8601 형식으로 변환
    };
  }
}
