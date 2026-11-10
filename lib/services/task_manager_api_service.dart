// =============================================================================
//  TaskManagerApiService — Dedicated service methods for all 15 API endpoints
// =============================================================================

import '../constants/api_constants.dart';
import '../models/models.dart';
import 'api_service.dart';

class TaskManagerApiService {
  final ApiService _apiService;

  TaskManagerApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  ApiService get apiService => _apiService;

  // ===========================================================================
  // 1. AUTHENTICATION MODULE
  // ===========================================================================

  /// 1. Register User
  /// URL: /api/task_manager/register
  /// Payload: {"name", "email", "password", "confirm_password", "phone", "role"}
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String role,
  }) async {
    final result = await _apiService.post(
      ApiConstants.register,
      params: {
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'phone': phone,
        'role': role,
      },
    );

    if (result is Map<String, dynamic>) {
      if (result['status'] == 'error') {
        throw ApiException(
          code: -1,
          message: result['message']?.toString() ?? 'Registration failed',
        );
      }
      final user = UserModel.fromJson(result);
      if (user.token != null && user.token!.isNotEmpty) {
        _apiService.setSessionToken(user.token!);
      }
      return user;
    }
    throw const ApiException(code: -1, message: 'Invalid register response format');
  }

  /// 2. Login User
  /// URL: /api/task_manager/login
  /// Payload: {"email", "password"}
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.post(
      ApiConstants.login,
      params: {
        'email': email,
        'password': password,
      },
    );

    if (result is Map<String, dynamic>) {
      if (result['status'] == 'error') {
        throw ApiException(
          code: -1,
          message: result['message']?.toString() ?? 'Login failed',
        );
      }
      final user = UserModel.fromJson(result);
      if (user.token != null && user.token!.isNotEmpty) {
        _apiService.setSessionToken(user.token!);
      }
      return user;
    }
    throw const ApiException(code: -1, message: 'Invalid login response format');
  }

  /// 3. Forgot Password
  /// URL: /api/task_manager/forgot_password
  /// Payload: {"email"}
  Future<dynamic> forgotPassword({required String email}) async {
    return await _apiService.post(
      ApiConstants.forgotPassword,
      params: {'email': email},
    );
  }

  // ===========================================================================
  // 2. DASHBOARD MODULE
  // ===========================================================================

  /// 4. Get Dashboard Data
  /// URL: /api/task_manager/dashboard
  /// Payload: {}
  Future<DashboardModel> getDashboardData() async {
    final result = await _apiService.post(
      ApiConstants.dashboard,
      params: {},
    );

    if (result is Map<String, dynamic>) {
      return DashboardModel.fromJson(result);
    }
    return const DashboardModel(
      totalBoards: 0,
      totalTasks: 0,
      completedTasks: 0,
      pendingTasks: 0,
      overdueTasks: 0,
      recentActivity: [],
    );
  }

  // ===========================================================================
  // 3. BOARD MANAGEMENT MODULE
  // ===========================================================================

  /// 5. Get All Boards
  /// URL: /api/task_manager/boards
  /// Payload: {}
  Future<List<BoardModel>> getAllBoards() async {
    final result = await _apiService.post(
      ApiConstants.boards,
      params: {},
    );

    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map(BoardModel.fromJson)
          .toList();
    } else if (result is Map<String, dynamic> && result['boards'] is List) {
      return (result['boards'] as List)
          .whereType<Map<String, dynamic>>()
          .map(BoardModel.fromJson)
          .toList();
    }
    return [];
  }

  /// 6. Search Boards
  /// URL: /api/task_manager/boards
  /// Payload: {"search": "string"}
  Future<List<BoardModel>> searchBoards(String search) async {
    final result = await _apiService.post(
      ApiConstants.boards,
      params: {'search': search},
    );

    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map(BoardModel.fromJson)
          .toList();
    } else if (result is Map<String, dynamic> && result['boards'] is List) {
      return (result['boards'] as List)
          .whereType<Map<String, dynamic>>()
          .map(BoardModel.fromJson)
          .toList();
    }
    return [];
  }

  /// 7. Get Board Details
  /// URL: /api/task_manager/boards/detail
  /// Payload: {"board_id": int}
  Future<BoardModel> getBoardDetails(int boardId) async {
    final result = await _apiService.post(
      ApiConstants.boardDetail,
      params: {'board_id': boardId},
    );

    if (result is Map<String, dynamic>) {
      if (result['status'] == 'error') {
        throw ApiException(
          code: -1,
          message: result['message']?.toString() ?? 'Failed to load board details',
        );
      }
      return BoardModel.fromJson(result);
    }
    throw ApiException(
      code: -1,
      message: 'Failed to parse board details for ID $boardId',
    );
  }

  /// 8. Filter Tasks by Tag in Board
  /// URL: /api/task_manager/boards/detail
  /// Payload: {"board_id": int, "tag": "string"}
  Future<BoardModel> filterTasksByTagInBoard({
    required int boardId,
    required String tag,
  }) async {
    final result = await _apiService.post(
      ApiConstants.boardDetail,
      params: {
        'board_id': boardId,
        'tag': tag,
      },
    );

    if (result is Map<String, dynamic>) {
      if (result['status'] == 'error') {
        throw ApiException(
          code: -1,
          message: result['message']?.toString() ?? 'Failed to filter board tasks',
        );
      }
      return BoardModel.fromJson(result);
    }
    throw ApiException(
      code: -1,
      message: 'Failed to filter board tasks for tag "$tag"',
    );
  }

  /// 9. Create Board (Variant 1)
  /// URL: /api/task_manager/boards/create
  /// Payload: {"name": "string", "description": "string", "color": int, "lists": ["string"]}
  Future<BoardModel> createBoardVariant1({
    required String name,
    required String description,
    required int color,
    required List<String> lists,
  }) async {
    final result = await _apiService.post(
      ApiConstants.createBoard,
      params: {
        'name': name,
        'description': description,
        'color': color,
        'lists': lists,
      },
    );

    if (result is Map<String, dynamic>) {
      if (result['status'] == 'error') {
        throw ApiException(
          code: -1,
          message: result['message']?.toString() ?? 'Failed to create board',
        );
      }
      return BoardModel.fromJson(result);
    }
    return BoardModel(
      id: result is int ? result : 0,
      name: name,
      description: description,
      color: color,
      listNames: lists,
    );
  }

  /// 10. Create Board (Variant 2)
  /// URL: /api/task_manager/boards/create
  /// Payload: {"board_name": "string", "colour": "string"}
  Future<BoardModel> createBoardVariant2({
    required String boardName,
    required String colour,
  }) async {
    final result = await _apiService.post(
      ApiConstants.createBoard,
      params: {
        'board_name': boardName,
        'colour': colour,
      },
    );

    if (result is Map<String, dynamic>) {
      if (result['status'] == 'error') {
        throw ApiException(
          code: -1,
          message: result['message']?.toString() ?? 'Failed to create board',
        );
      }
      return BoardModel.fromJson(result);
    }
    return BoardModel(
      id: result is int ? result : 0,
      name: boardName,
      colour: colour,
    );
  }

  /// 11. Update Board
  /// URL: /api/task_manager/boards/update
  /// Payload: {"board_id": int, "description": "string"}
  Future<dynamic> updateBoard({
    required int boardId,
    required String description,
  }) async {
    return await _apiService.post(
      ApiConstants.updateBoard,
      params: {
        'board_id': boardId,
        'description': description,
      },
    );
  }

  // ===========================================================================
  // 4. TASK MANAGEMENT MODULE
  // ===========================================================================

  /// 12. Create Task
  /// URL: /api/task_manager/tasks/create
  /// Payload: {"board_id": int, "list_name": "string", "name": "string", "description": "string", "tag": "string", "due_date": "YYYY-MM-DD HH:MM:SS", "checklist": "string"}
  Future<TaskModel> createTask({
    required int boardId,
    required String listName,
    required String name,
    required String description,
    required String tag,
    required String dueDate,
    required String checklist,
  }) async {
    final result = await _apiService.post(
      ApiConstants.createTask,
      params: {
        'board_id': boardId,
        'list_name': listName,
        'name': name,
        'description': description,
        'tag': tag,
        'due_date': dueDate,
        'checklist': checklist,
      },
    );

    if (result is Map<String, dynamic>) {
      if (result['status'] == 'error') {
        throw ApiException(
          code: -1,
          message: result['message']?.toString() ?? 'Failed to create task',
        );
      }
      return TaskModel.fromJson(result);
    }
    return TaskModel(
      id: result is int ? result : 0,
      name: name,
      description: description,
      tag: tag,
      listName: listName,
      dueDate: dueDate,
      checklist: checklist,
      boardId: boardId,
    );
  }

  /// 13. Update / Move Task (Drag & Drop)
  /// URL: /api/task_manager/tasks/update
  /// Payload: {"task_id": int, "list_name": "string", "due_date": "YYYY-MM-DD HH:MM:SS"}
  Future<dynamic> updateTask({
    required int taskId,
    required String listName,
    required String dueDate,
  }) async {
    return await _apiService.post(
      ApiConstants.updateTask,
      params: {
        'task_id': taskId,
        'list_name': listName,
        'due_date': dueDate,
      },
    );
  }

  // ===========================================================================
  // 5. SEARCH MODULE
  // ===========================================================================

  /// 14. Global Search
  /// URL: /api/task_manager/search
  /// Payload: {"query": "string"}
  Future<dynamic> globalSearch(String query) async {
    return await _apiService.post(
      ApiConstants.search,
      params: {'query': query},
    );
  }

  // ===========================================================================
  // 6. NOTIFICATIONS MODULE
  // ===========================================================================

  /// 15. Get Notifications
  /// URL: /api/task_manager/notifications
  /// Payload: {"unread_only": bool}
  Future<List<NotificationModel>> getNotifications({
    required bool unreadOnly,
  }) async {
    final result = await _apiService.post(
      ApiConstants.notifications,
      params: {'unread_only': unreadOnly},
    );

    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    } else if (result is Map<String, dynamic> && result['notifications'] is List) {
      return (result['notifications'] as List)
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    }
    return [];
  }

  /// 16. Mark Notification Read
  /// URL: /api/task_manager/notifications/mark_read
  /// Payload: {"notification_id": int}
  Future<dynamic> markNotificationRead(int notificationId) async {
    return await _apiService.post(
      ApiConstants.markNotificationRead,
      params: {'notification_id': notificationId},
    );
  }
}
