import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../provider/loginProvider.dart';

class ApproverInfoPage extends StatefulWidget {
  final int eaNo;
  late String eaStatus;

  ApproverInfoPage({
    Key? key,
    required this.eaNo,
    required this.eaStatus,
  }) : super(key: key);

  @override
  _ApproverInfoPageState createState() => _ApproverInfoPageState();
}

class _ApproverInfoPageState extends State<ApproverInfoPage> {
  late int empNo;
  late Future<List<dynamic>> approversFuture;

  @override
  void initState() {
    super.initState();
    empNo = Provider.of<LoginProvider>(context, listen: false).empNo!;
    approversFuture = fetchApprovers();
  }

  /// 결재자 정보를 가져오는 비동기 함수
  Future<List<dynamic>> fetchApprovers() async {
    final url = Uri.parse(
      'http://192.168.0.40:8099/api/apprInfo?empNo=$empNo&eaNo=${widget.eaNo}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('데이터 로딩 중 오류: $e');
    }
  }

  /// 결재 처리 API 호출 함수
  Future<void> processApproval(int earNo, String status) async {
    final url = Uri.parse(
      'http://192.168.0.40:8099/api/processApproval?earNo=$earNo&apprStatus=$status',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        // 결재 성공 알림창 표시
        await showAlertDialog(
          context: context,
          title: '결재 처리 완료',
          content: '결재가 성공적으로 처리되었습니다.',
        );

        // 이전 페이지로 이동하면서 결과 전달
        Navigator.pop(context, true);
      } else {
        // 결재 오류 알림창 표시
        await showAlertDialog(
          context: context,
          title: '결재 처리 오류',
          content: '오류 코드: ${response.statusCode}',
        );
      }
    } catch (e) {
      // 예외 발생 알림창 표시
      await showAlertDialog(
        context: context,
        title: '예외 발생',
        content: '예외 메시지: $e',
      );
    }
  }

  /// 알림창 표시 함수
  Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 사용자 외부 클릭으로 닫기 방지
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 알림창 닫기
              },
            ),
          ],
        );
      },
    );
  }

  /// 결재 상태에 따른 색상 반환 함수
  Color getStatusColor(String status) {
    switch (status) {
      case 'b1':
        return Colors.grey;
      case 'b2':
        return Colors.green;
      case 'b3':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  /// 결재 상태에 따른 텍스트 반환 함수
  String getStatusText(String status) {
    switch (status) {
      case 'b1':
        return '대기';
      case 'b2':
        return '승인';
      case 'b3':
        return '반려';
      default:
        return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결재자 정보'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: approversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('결재자 정보가 없습니다.'));
          } else {
            final approvers = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: approvers.length,
              itemBuilder: (context, index) {
                final approver = approvers[index];
                final statusColor =
                    getStatusColor(approver['apprStatus'] ?? '');
                final statusText = getStatusText(approver['apprStatus'] ?? '');

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      '${approver['apprEmpName'] ?? '이름 없음'} (${approver['apprPosiName'] ?? '직책 정보 없음'})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing:
                        (widget.eaStatus == 'a1' || widget.eaStatus == 'a2') &&
                                approver['apprStatus'] == 'b1'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      processApproval(
                                          approver['earNo'], 'b2'); // 승인 처리
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('승인'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      processApproval(
                                          approver['earNo'], 'b3'); // 반려 처리
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('반려'),
                                  ),
                                ],
                              )
                            : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
