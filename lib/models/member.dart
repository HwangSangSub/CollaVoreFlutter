class Member {
  late String id;
  late String pwd;

  Member({required this.id, required this.pwd});

  Member.from(Map<String, dynamic> map) {
    this.id = map['id'] as String;
    this.pwd = map['pwd'] as String;
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'pwd': pwd};
  }
}