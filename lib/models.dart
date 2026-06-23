import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────────────
//  CHECKLIST ITEM
// ────────────────────────────────────────────────────────────────────────────
class ChecklistItem {
  String id;
  String title;
  bool isDone;

  ChecklistItem({required this.id, required this.title, this.isDone = false});
}

// ────────────────────────────────────────────────────────────────────────────
//  KANBAN CARD
// ────────────────────────────────────────────────────────────────────────────
class KanbanCard {
  String id;
  String title;
  String description;
  Color labelColor;
  String labelText;
  DateTime? dueDate;
  List<ChecklistItem> checklist;
  bool archived;

  KanbanCard({
    required this.id,
    required this.title,
    this.description = '',
    this.labelColor = Colors.transparent,
    this.labelText = '',
    this.dueDate,
    List<ChecklistItem>? checklist,
    this.archived = false,
  }) : checklist = checklist ?? [];

  int get checklistTotal => checklist.length;
  int get checklistDone => checklist.where((i) => i.isDone).length;
}

// ────────────────────────────────────────────────────────────────────────────
//  KANBAN LIST
// ────────────────────────────────────────────────────────────────────────────
class KanbanList {
  String id;
  String title;
  List<KanbanCard> cards;

  KanbanList({
    required this.id,
    required this.title,
    List<KanbanCard>? cards,
  }) : cards = cards ?? [];

  List<KanbanCard> get activeCards =>
      cards.where((c) => !c.archived).toList();
}

// ────────────────────────────────────────────────────────────────────────────
//  KANBAN BOARD
// ────────────────────────────────────────────────────────────────────────────
class KanbanBoard {
  String id;
  String title;
  Color color;
  String description;
  List<KanbanList> lists;
  final DateTime createdAt;

  KanbanBoard({
    required this.id,
    required this.title,
    required this.color,
    this.description = '',
    List<KanbanList>? lists,
    DateTime? createdAt,
  })  : lists = lists ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get totalCards =>
      lists.fold(0, (s, l) => s + l.activeCards.length);
}
