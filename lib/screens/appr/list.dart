import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../provider/loginProvider.dart';

class ApprPage extends StatefulWidget {
  @override
  State<ApprPage> createState() => _ApprPageState();
}

class _ApprPageState extends State<ApprPage> {
  late Future<List<Map<String, int>>> allDocuments;
  late Future<List<Map<String, int>>> draftDocuments;
  late Future<List<Map<String, int>>> approvalDocuments;

  @override
  void initState() {
    super.initState();
  }
  Future<List<Map<String, String>>> fetchDocuments(
      String category, int empN) async {
    final url = Uri.parse(
        'https://example.com/api/documents?category=$category&empNo=$empNo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return {
          'title': item['title']?.toString() ?? 'No Title',
          'subtitle': item['description']?.toString() ?? 'No Description',
          'status': category,
        };
      }).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  @override
  Widget build(BuildContext context) {
    int? empNo = Provider.of<LoginProvider>(context).empNo;
    allDocuments = fetchDocuments('all', empNo!) as Future<List<Map<String, int>>>;
    draftDocuments = fetchDocuments('draft', empNo) as Future<List<Map<String, int>>>;
    approvalDocuments = fetchDocuments('approval', empNo) as Future<List<Map<String, int>>>;

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _buildTabMenu(), // 탭 메뉴
            Expanded(
              child: TabBarView(
                children: [
                  buildDocumentList(allDocuments), // All Tab
                  buildDocumentList(draftDocuments), // Draft Tab
                  buildDocumentList(approvalDocuments), // Approval Tab
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 탭 메뉴 UI
  Widget _buildTabMenu() {
    return const TabBar(
      indicatorColor: Colors.blue,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle:
          TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 탭 글자 크기 조정
      tabs: [
        Tab(text: 'All'),
        Tab(text: 'Draft'),
        Tab(text: 'Approval'),
      ],
    );
  }

  // 비동기 데이터 로드를 처리하는 위젯
  Widget buildDocumentList(Future<List<Map<String, String>>> futureDocs) {
    return FutureBuilder<List<Map<String, String>>>(
      future: futureDocs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 로딩 중
        } else if (snapshot.hasError) {
          return const Center(child: Text('Failed to load documents')); // 오류 처리
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No documents available')); // 데이터가 없을 때
        } else {
          final documents = snapshot.data!;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.description, color: Colors.blue),
                  title: Text(doc['title']!,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(doc['subtitle']!),
                  trailing: Text(
                    doc['status']!,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${doc['title']} selected')),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
