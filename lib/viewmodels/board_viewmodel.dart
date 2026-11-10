// =============================================================================
//  BoardViewModel — Handles fetching, searching, creating, updating boards & detail
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class BoardViewModel extends ChangeNotifier {
  final TaskManagerApiService _api;

  BoardViewModel({TaskManagerApiService? api})
      : _api = api ?? TaskManagerApiService();

  List<BoardModel> _boards = [];
  BoardModel? _currentBoard;
  DashboardModel? _dashboardData;

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _errorMessage;
  String? _searchQuery;
  String? _activeTagFilter;

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<BoardModel> get boards => _boards;
  BoardModel? get currentBoard => _currentBoard;
  DashboardModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  String? get searchQuery => _searchQuery;
  String? get activeTagFilter => _activeTagFilter;

  // ─── Dashboard ──────────────────────────────────────────────────────────────
  Future<void> fetchDashboard() async {
    try {
      _dashboardData = await _api.getDashboardData();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (_) {}
  }

  // ─── Fetch All Boards ───────────────────────────────────────────────────────
  Future<void> fetchBoards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _boards = await _api.getAllBoards();
      _searchQuery = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Failed to load boards: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Search Boards ──────────────────────────────────────────────────────────
  Future<void> searchBoards(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (query.trim().isEmpty) {
        _boards = await _api.getAllBoards();
      } else {
        _boards = await _api.searchBoards(query.trim());
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Search failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Board Details ──────────────────────────────────────────────────────────
  Future<void> fetchBoardDetails(int boardId) async {
    _isDetailLoading = true;
    _errorMessage = null;
    _activeTagFilter = null;
    notifyListeners();

    try {
      _currentBoard = await _api.getBoardDetails(boardId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Failed to load board details: $e";
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // ─── Filter Tasks by Tag in Board ───────────────────────────────────────────
  Future<void> filterByTag(int boardId, String tag) async {
    _isDetailLoading = true;
    _errorMessage = null;
    _activeTagFilter = tag;
    notifyListeners();

    try {
      if (tag.isEmpty) {
        _currentBoard = await _api.getBoardDetails(boardId);
        _activeTagFilter = null;
      } else {
        _currentBoard = await _api.filterTasksByTagInBoard(
          boardId: boardId,
          tag: tag,
        );
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Failed to filter board tasks: $e";
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // ─── Create Board (Variant 1) ───────────────────────────────────────────────
  Future<BoardModel?> createBoardVariant1({
    required String name,
    required String description,
    required int color,
    required List<String> lists,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBoard = await _api.createBoardVariant1(
        name: name,
        description: description,
        color: color,
        lists: lists,
      );
      _boards.insert(0, newBoard);
      return newBoard;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = "Failed to create board: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Create Board (Variant 2) ───────────────────────────────────────────────
  Future<BoardModel?> createBoardVariant2({
    required String boardName,
    required String colour,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBoard = await _api.createBoardVariant2(
        boardName: boardName,
        colour: colour,
      );
      _boards.insert(0, newBoard);
      return newBoard;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = "Failed to create board: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update Board ───────────────────────────────────────────────────────────
  Future<bool> updateBoard({
    required int boardId,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.updateBoard(boardId: boardId, description: description);
      // Update local board in list
      final index = _boards.indexWhere((b) => b.id == boardId);
      if (index != -1) {
        final current = _boards[index];
        _boards[index] = BoardModel(
          id: current.id,
          name: current.name,
          description: description,
          color: current.color,
          colour: current.colour,
          lists: current.lists,
        );
      }
      if (_currentBoard != null && _currentBoard!.id == boardId) {
        _currentBoard = BoardModel(
          id: _currentBoard!.id,
          name: _currentBoard!.name,
          description: description,
          color: _currentBoard!.color,
          colour: _currentBoard!.colour,
          lists: _currentBoard!.lists,
        );
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Failed to update board: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Global Search ──────────────────────────────────────────────────────────
  Future<dynamic> globalSearch(String query) async {
    try {
      return await _api.globalSearch(query);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      return null;
    }
  }

  void clearCurrentBoard() {
    _currentBoard = null;
    _activeTagFilter = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
