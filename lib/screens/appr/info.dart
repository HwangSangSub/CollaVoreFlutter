import 'package:flutter/material.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import '../../provider/loginProvider.dart';

class ApprInfoPage extends StatefulWidget {
  final int eaNo;

  const ApprInfoPage({Key? key, required this.eaNo}) : super(key: key);

  @override
  _ApprInfoPageState createState() => _ApprInfoPageState();
}

class _ApprInfoPageState extends State<ApprInfoPage> {
  Map<String, dynamic>? appDetail;
  late int empNo;

  @override
  void initState() {
    super.initState();
    empNo = Provider.of<LoginProvider>(context, listen: false).empNo!;
    fetchScheduleDetail();
  }

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
      } else {
        print('오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      print('예외 발생: $e');
    }
  }

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
      body: appDetail == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            appDetail!['title'] ?? '제목 없음',
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
                          value: formatDateTime(appDetail!['regDate']),
                        ),
                        const SizedBox(height: 10),
                        if (appDetail!['compDate'] != null &&
                            appDetail!['compDate'].toString().isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: '결재종료일',
                            value: formatDateTime(appDetail!['compDate']),
                          ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        Html(
                          data: cleanEscapedHtml(
                              appDetail!['content'] ?? '<p>내용없음</p>'),
                          extensions: const [TableHtmlExtension()],
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

  String cleanEscapedHtml(String html) {
    String cleaned = html.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    cleaned = cleaned.replaceAll(r'\"', '"');
    return cleaned.trim();
  }
}
