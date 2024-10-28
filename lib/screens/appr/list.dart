import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../provider/loginProvider.dart';
import './info.dart';
import '../../common/apiAddress.dart';

class ApprPage extends StatefulWidget {
  @override
  State<ApprPage> createState() => _ApprPageState();
}

class _ApprPageState extends State<ApprPage> {
  late int empNo;
  late Future<List<Map<String, String>>> allDocuments;
  late Future<List<Map<String, String>>> draftDocuments;
  late Future<List<Map<String, String>>> approvalDocuments;

  @override
  void initState() {
    super.initState();
    empNo = Provider.of<LoginProvider>(context, listen: false).empNo!;
    _refreshAllDocuments();
    _refreshDraftDocuments();
    _refreshApprovalDocuments();
  }

  // 각 카테고리별 문서를 다시 불러오는 함수
  void _refreshAllDocuments() {
    setState(() {
      allDocuments = fetchDocuments('all', empNo);
    });
  }

  void _refreshDraftDocuments() {
    setState(() {
      draftDocuments = fetchDocuments('draft', empNo);
    });
  }

  void _refreshApprovalDocuments() {
    setState(() {
      approvalDocuments = fetchDocuments('approval', empNo);
    });
  }

  // API 호출 함수
  Future<List<Map<String, String>>> fetchDocuments(
      String category, int empNo) async {
    final url =
        Uri.parse(ApiAddress.apprAll + '?appType=$category&empNo=$empNo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) {
        return {
          'eaNo': item['eaNo']?.toString() ?? '0',
          'title': item['title']?.toString() ?? 'No Title',
          'content': item['content']?.toString() ?? 'No Description',
          'status': item['status']?.toString() ?? 'No Status',
          'regDate': item['regDate']?.toString() ?? 'No Registration Date',
          'compDate': item['compDate']?.toString() ?? 'No Completion Date',
        };
      }).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _buildTabMenu(),
            Expanded(
              child: TabBarView(
                children: [
                  buildDocumentList('all'),
                  buildDocumentList('draft'),
                  buildDocumentList('approval'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabMenu() {
    return Container(
      color: Colors.white,
      child: const TabBar(
        indicatorColor: Colors.blueAccent,
        labelColor: Colors.blueAccent,
        unselectedLabelColor: Colors.grey,
        indicatorWeight: 3.0,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: '전체'),
          Tab(text: '나의 기안'),
          Tab(text: '결재'),
        ],
      ),
    );
  }

  Widget buildDocumentList(String category) {
    return FutureBuilder<List<Map<String, String>>>(
      future: fetchDocuments(category, empNo), // 매번 새로운 Future 생성
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('문서 로드 실패'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('문서가 없습니다'));
        } else {
          final documents = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // 강제로 UI 갱신
              await Future.delayed(
                  const Duration(milliseconds: 500)); // 지연 시간 (옵션)
            },
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                final eaNo = int.tryParse(doc['eaNo'] ?? '') ?? 0;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: Text(
                      doc['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(doc['status']!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(doc['status']!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApprInfoPage(eaNo: eaNo),
                        ),
                      ).then((_) => setState(() {})); // 돌아온 후 UI 갱신
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'a1':
        return Colors.orange;
      case 'a2':
        return Colors.green;
      case 'a3':
        return Colors.blue;
      case 'a4':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'a1':
        return '대기';
      case 'a2':
        return '진행';
      case 'a3':
        return '승인';
      case 'a4':
        return '반려';
      default:
        return '알 수 없음';
    }
  }
}
