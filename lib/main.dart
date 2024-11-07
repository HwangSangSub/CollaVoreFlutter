import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './provider/loginProvider.dart';
import './screens/member/login.dart';
import './screens/cals/list.dart';
// import './screens/project/list.dart';
import './screens/appr/list.dart';

import './screens/member/myPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업 보장
  await initializeDateFormatting(); // 날짜 포맷 초기화

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CollaVore',
      theme: ThemeData(
        primaryColor: const Color(0xFF6C4EFF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF6C4EFF),
          secondary: Colors.amber,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C4EFF),
          elevation: 4,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF6C4EFF),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
          titleLarge: TextStyle(
            color: Color(0xFF6C4EFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ko', ''),
      ],
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  String selectedName = '';

  @override
  Widget build(BuildContext context) {
    String? userId = Provider.of<LoginProvider>(context).loginId;
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const CalsPage();
        selectedName = '일정관리';
        break;
      // case 1:
      //   page = ProjectPage();
      //   selectedName = '프로젝트관리';
      //   break;
      case 1:
        page = ApprPage();
        selectedName = '전자결재관리';
        break;
      default:
        page = const CalsPage();
        selectedName = '일정관리';
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedName),
        actions: [
          Visibility(
            visible: userId == null,
            child: IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ),
          Visibility(
            visible: userId != null,
            child: Center(
              child: PopupMenuButton<int>(
                onSelected: (result) {
                  switch (result) {
                    case 1:
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyPage()),
                        (route) => true, // 이전 페이지 스택 제거
                      );

                      break;
                    case 2:
                      Provider.of<LoginProvider>(context, listen: false)
                          .logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => const [
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('마이페이지'),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text('로그아웃'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: mainArea),
          SafeArea(
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: '일정',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.list_alt),
                //   label: '프로젝트',
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt),
                  label: '전자결재',
                ),
              ],
              currentIndex: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
