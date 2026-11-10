// =============================================================================
//  BoardModel + TaskModel (nested inside board detail)
// =============================================================================
import 'task_model.dart';

class BoardModel {
  final int id;
  final String name;
  final String? description;
  final int? color;
  final String? colour;         // hex string variant from create v2 or color_hex
  final int? totalLists;
  final int? totalTasks;
  final List<String>? listNames;
  final List<BoardListModel>? lists;
  final String? createdAt;
  final String? updatedAt;

  const BoardModel({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.colour,
    this.totalLists,
    this.totalTasks,
    this.listNames,
    this.lists,
    this.createdAt,
    this.updatedAt,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    // If the json is wrapped in a 'board' key (e.g. from /boards/detail response or create response)
    final map = json['board'] is Map<String, dynamic>
        ? json['board'] as Map<String, dynamic>
        : json;

    // Parse nested lists (board detail view)
    List<BoardListModel>? parsedLists;
    if (map['lists'] is List) {
      parsedLists = (map['lists'] as List)
          .whereType<Map<String, dynamic>>()
          .map(BoardListModel.fromJson)
          .toList();
    }

    return BoardModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ??
          map['board_name'] as String? ??
          '',
      description: map['description'] as String?,
      color: map['color'] as int?,
      colour: map['color_hex'] as String? ?? map['colour'] as String?,
      totalLists: map['total_lists'] as int?,
      totalTasks: map['total_tasks'] as int?,
      lists: parsedLists,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (colour != null) 'colour': colour,
        if (totalLists != null) 'total_lists': totalLists,
        if (totalTasks != null) 'total_tasks': totalTasks,
        if (lists != null)
          'lists': lists!.map((l) => l.toJson()).toList(),
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };
}

// -----------------------------------------------------------------------------

/// A named list (column) inside a board, containing tasks.
class BoardListModel {
  final int id;
  final String name;
  final int? sequence;
  final int? tasksCount;
  final List<TaskModel> tasks;

  const BoardListModel({
    required this.id,
    required this.name,
    this.sequence,
    this.tasksCount,
    required this.tasks,
  });

  factory BoardListModel.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'] as List? ?? [];
    return BoardListModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      sequence: json['sequence'] as int?,
      tasksCount: json['tasks_count'] as int?,
      tasks: rawTasks
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (sequence != null) 'sequence': sequence,
        if (tasksCount != null) 'tasks_count': tasksCount,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  BoardListModel copyWith({
    int? id,
    String? name,
    int? sequence,
    int? tasksCount,
    List<TaskModel>? tasks,
  }) {
    return BoardListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      tasksCount: tasksCount ?? this.tasksCount,
      tasks: tasks ?? this.tasks,
    );
  }
}
