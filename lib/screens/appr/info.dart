import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import '../../provider/loginProvider.dart';

class ApprInfoPage extends StatefulWidget {
  final int eaNo;

  const ApprInfoPage({Key? key, required this.eaNo}) : super(key: key);

  @override
  _ApprInfoPageState createState() => _ApprInfoPageState();
}

class _ApprInfoPageState extends State<ApprInfoPage> {
  late Map<String, dynamic> appDetail = {};
  late int empNo;
  PdfControllerPinch? pdfController; // PDF Controller

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Flutter 위젯 초기화 보장
    super.initState();
    empNo = Provider.of<LoginProvider>(context, listen: false).empNo!;
    fetchScheduleDetail(); // API 호출 시작
  }

  @override
  void dispose() {
    pdfController?.dispose(); // PdfController 해제
    super.dispose();
  }

  /// API에서 스케줄 정보를 가져오고 PDF를 초기화합니다.
  Future<void> fetchScheduleDetail() async {
    final url = Uri.parse(
      'http://192.168.0.40:8099/api/appInfo?empNo=$empNo&eaNo=${widget.eaNo}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          appDetail = data;
        });
        final pdfBytes = decodePdfContent(appDetail['pdfInfo']);

        setState(() {
          pdfController = PdfControllerPinch(
            document: PdfDocument.openData(pdfBytes),
          );
        });
      } else {
        print('오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      print('예외 발생: $e');
    }
  }

  /// PDF 콘텐츠를 Uint8List로 변환합니다.
  Uint8List decodePdfContent(dynamic content) {
    if (content is String) {
      // Base64 문자열을 디코딩
      return base64.decode(content);
    } else if (content is Uint8List) {
      return content;
    } else {
      throw Exception('알 수 없는 PDF 데이터 형식');
    }
  }

  /// 날짜 포맷팅 함수
  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '알 수 없음';
    }
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전자결재상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      appDetail['title'] ?? '제목 없음',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: '기안일',
                    value: formatDateTime(appDetail['regDate']),
                  ),
                  const SizedBox(height: 10),
                  if (appDetail['compDate'] != null &&
                      appDetail['compDate'].toString().isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: '결재종료일',
                      value: formatDateTime(appDetail['compDate']),
                    ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  pdfController == null
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 500,
                          child: PdfViewPinch(
                            controller: pdfController!,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
