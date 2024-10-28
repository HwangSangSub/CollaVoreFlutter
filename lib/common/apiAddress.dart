class ApiAddress {
  static const String baseUrl = "http://192.168.0.4:8099"; // 집에서
  static const String baseApiUrl = "http://192.168.0.4:8099/api"; // 집에서
  // static const String baseUrl = "http://192.168.0.40:8099/api"; // 학교에서

  static const String login = '$baseApiUrl/login';
  static const String findId = '$baseApiUrl/findId';
  static const String chkUser = '$baseApiUrl/chkUser';
  static const String pwdModify = '$baseApiUrl/pwdModify';
  static const String userInfo = '$baseApiUrl/userInfo';
  static const String updateUserInfo = '$baseApiUrl/updateUserInfo';

  static const String schsAdd = '$baseApiUrl/schsAdd';
  static const String schsSelectAll = '$baseApiUrl/schsSelectAll';
  static const String schsInfo = '$baseApiUrl/schsInfo';

  static const String apprAll = '$baseApiUrl/apprAll';
  static const String appInfo = '$baseApiUrl/appInfo';
  static const String processApproval = '$baseApiUrl/processApproval';
}
