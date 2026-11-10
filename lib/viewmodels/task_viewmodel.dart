// =============================================================================
//  TaskViewModel — Handles task creation and updating / moving tasks
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskManagerApiService _api;

  TaskViewModel({TaskManagerApiService? api})
      : _api = api ?? TaskManagerApiService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  TaskModel? _lastCreatedTask;

  // ─── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  TaskModel? get lastCreatedTask => _lastCreatedTask;

  // ─── Create Task ────────────────────────────────────────────────────────────
  Future<TaskModel?> createTask({
    required int boardId,
    required String listName,
    required String name,
    required String description,
    required String tag,
    required String dueDate,
    required String checklist,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final task = await _api.createTask(
        boardId: boardId,
        listName: listName,
        name: name,
        description: description,
        tag: tag,
        dueDate: dueDate,
        checklist: checklist,
      );
      _lastCreatedTask = task;
      _successMessage = "Task created successfully";
      return task;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = "Failed to create task: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update / Move Task (Drag & Drop) ───────────────────────────────────────
  Future<bool> updateTask({
    required int taskId,
    required String listName,
    required String dueDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _api.updateTask(
        taskId: taskId,
        listName: listName,
        dueDate: dueDate,
      );
      _successMessage = "Task moved/updated successfully";
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Failed to move/update task: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearStatus() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
