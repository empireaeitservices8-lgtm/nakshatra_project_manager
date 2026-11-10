import 'package:flutter/material.dart';
import 'models.dart';

// Gold palette constants
class NGColors {
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF0C040);
  static const goldDark = Color(0xFFA67C2E);
  static const champagne = Color(0xFFF5D78E);
  static const obsidian = Color(0xFF0A0A0A);
  static const charcoal = Color(0xFF1A1A1A);
  static const graphite = Color(0xFF2A2A2A);
  static const rose = Color(0xFFB76E79);
  static const platinum = Color(0xFFE5E4E2);
  static const ruby = Color(0xFF9B1B30);
  static const emerald = Color(0xFF046307);
  static const sapphire = Color(0xFF0F52BA);
}

class AppState extends ChangeNotifier {
  final List<KanbanBoard> boards;

  // Initialized empty with zero mock data. Real data is loaded via API ViewModels.
  AppState() : boards = [];

  // ─── Board Operations ──────────────────────────────────────────────────────

  void setBoards(List<KanbanBoard> newBoards) {
    boards.clear();
    boards.addAll(newBoards);
    notifyListeners();
  }

  void addBoard(KanbanBoard board) {
    boards.insert(0, board);
    notifyListeners();
  }

  void deleteBoard(String id) {
    boards.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void updateBoard(String id, {String? title, Color? color, String? description}) {
    final b = _findBoard(id);
    if (b == null) return;
    if (title != null) b.title = title;
    if (color != null) b.color = color;
    if (description != null) b.description = description;
    notifyListeners();
  }

  // ─── List Operations ───────────────────────────────────────────────────────

  void addList(String boardId, KanbanList list) {
    _findBoard(boardId)?.lists.add(list);
    notifyListeners();
  }

  void deleteList(String boardId, String listId) {
    _findBoard(boardId)?.lists.removeWhere((l) => l.id == listId);
    notifyListeners();
  }

  void renameList(String boardId, String listId, String newTitle) {
    _findList(boardId, listId)?.title = newTitle;
    notifyListeners();
  }

  // ─── Card Operations ───────────────────────────────────────────────────────

  void addCard(String boardId, String listId, KanbanCard card) {
    _findList(boardId, listId)?.cards.add(card);
    notifyListeners();
  }

  void deleteCard(String boardId, String listId, String cardId) {
    _findList(boardId, listId)?.cards.removeWhere((c) => c.id == cardId);
    notifyListeners();
  }

  void updateCard(String boardId, String listId, KanbanCard card) {
    final list = _findList(boardId, listId);
    if (list == null) return;
    final idx = list.cards.indexWhere((c) => c.id == card.id);
    if (idx != -1) list.cards[idx] = card;
    notifyListeners();
  }

  void moveCard({
    required String boardId,
    required String fromListId,
    required String toListId,
    required KanbanCard card,
  }) {
    if (fromListId == toListId) return;
    final board = _findBoard(boardId);
    if (board == null) return;
    final fromList = board.lists.firstWhere((l) => l.id == fromListId);
    final toList = board.lists.firstWhere((l) => l.id == toListId);
    fromList.cards.remove(card);
    toList.cards.add(card);
    notifyListeners();
  }

  void notify() => notifyListeners();

  // ─── Helpers ───────────────────────────────────────────────────────────────

  KanbanBoard? _findBoard(String id) {
    try {
      return boards.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  KanbanList? _findList(String boardId, String listId) {
    try {
      return _findBoard(boardId)?.lists.firstWhere((l) => l.id == listId);
    } catch (_) {
      return null;
    }
  }
}
