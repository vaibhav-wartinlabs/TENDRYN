abstract class ApiEndpoints {
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String dashboardSummary = '/dashboard/summary';
  static const String queue = '/queue';
  static const String leaveRequests = '/leave-requests';

  /// Paths that must not carry a bearer token or trigger a refresh.
  static const List<String> public = [login, refresh];
}
