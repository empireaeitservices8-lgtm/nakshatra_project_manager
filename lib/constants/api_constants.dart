// -----------------------------------------------------------------------------
//  API Constants - Nakshatra Project Manager
// -----------------------------------------------------------------------------

class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'http://100.52.86.195:8069/api/task_manager';

  // 1. Auth Endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String forgotPassword = '$baseUrl/forgot_password';

  // 2. Dashboard Endpoints
  static const String dashboard = '$baseUrl/dashboard';

  // 3. Board Management Endpoints
  static const String boards = '$baseUrl/boards';
  static const String boardDetail = '$baseUrl/boards/detail';
  static const String createBoard = '$baseUrl/boards/create';
  static const String updateBoard = '$baseUrl/boards/update';

  // 4. Task Management Endpoints
  static const String createTask = '$baseUrl/tasks/create';
  static const String updateTask = '$baseUrl/tasks/update';

  // 5. Search Endpoints
  static const String search = '$baseUrl/search';

  // 6. Notification Endpoints
  static const String notifications = '$baseUrl/notifications';
  static const String markNotificationRead = '$baseUrl/notifications/mark_read';
}
