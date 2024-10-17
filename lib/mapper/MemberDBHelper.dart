import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/member.dart';

class MemberDBHelper {
  static final MemberDBHelper _dbHelper = MemberDBHelper._init();

  MemberDBHelper._init() {}

  factory MemberDBHelper() {
    return _dbHelper;
  }

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final String path = join(await getDatabasesPath(), 'member.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
        '''
            CREATE TABLE members (
              id TEXT PRIMARY KEY,
              pwd TEXT NOT NULL
            )
            ''',
      );
    });
  }

  // 회원가입
  Future<int> insertMember(Member member) async {
    Database db = await database;
    return await db.insert('members', member.toMap());
  }

  // 로그인
  Future<Member> login(String id, String pwd) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'members',
      where: 'id = ? AND pwd = ?',
      whereArgs: [id, pwd],
    );
    if (result.isEmpty) {
      return Member(id: '', pwd: '');
    } else {
      Map<String, dynamic> member = result.first;
      return Member.from(member);
    }
  }

  // 내정보
  Future<Member> getMemberInfo(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
    Map<String, dynamic> member = result.first;
    return Member.from(member);
  }

  // 수정
  Future<int> updateMember(Member member) async {
    Database db = await database;
    return await db.update('members', member.toMap(),
        where: 'id =?', whereArgs: [member.id]);
  }
}
