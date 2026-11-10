// =============================================================================
//  TaskModel & AssigneeModel
// =============================================================================

class AssigneeModel {
  final int id;
  final String name;

  const AssigneeModel({
    required this.id,
    required this.name,
  });

  factory AssigneeModel.fromJson(Map<String, dynamic> json) {
    return AssigneeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class TaskModel {
  final int id;
  final String name;
  final String? description;
  final String? tag;
  final String? tagColor;
  final String? listName;
  final String? dueDate;
  final String? checklist;
  final String? state;
  final String? priority;
  final List<AssigneeModel>? assignees;
  final int? boardId;
  final String? createdAt;
  final String? updatedAt;

  const TaskModel({
    required this.id,
    required this.name,
    this.description,
    this.tag,
    this.tagColor,
    this.listName,
    this.dueDate,
    this.checklist,
    this.state,
    this.priority,
    this.assignees,
    this.boardId,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final map = json['task'] is Map<String, dynamic>
        ? json['task'] as Map<String, dynamic>
        : json;

    List<AssigneeModel>? parsedAssignees;
    if (map['assignees'] is List) {
      parsedAssignees = (map['assignees'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AssigneeModel.fromJson)
          .toList();
    }

    return TaskModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      tag: map['tag'] as String?,
      tagColor: map['tag_color'] as String?,
      listName: map['list_name'] as String?,
      dueDate: map['due_date'] as String?,
      checklist: map['checklist']?.toString(),
      state: map['state'] as String?,
      priority: map['priority']?.toString(),
      assignees: parsedAssignees,
      boardId: map['board_id'] as int?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (tag != null) 'tag': tag,
        if (tagColor != null) 'tag_color': tagColor,
        if (listName != null) 'list_name': listName,
        if (dueDate != null) 'due_date': dueDate,
        if (checklist != null) 'checklist': checklist,
        if (state != null) 'state': state,
        if (priority != null) 'priority': priority,
        if (assignees != null)
          'assignees': assignees!.map((a) => a.toJson()).toList(),
        if (boardId != null) 'board_id': boardId,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };

  TaskModel copyWith({
    int? id,
    String? name,
    String? description,
    String? tag,
    String? tagColor,
    String? listName,
    String? dueDate,
    String? checklist,
    String? state,
    String? priority,
    List<AssigneeModel>? assignees,
    int? boardId,
    String? createdAt,
    String? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      tagColor: tagColor ?? this.tagColor,
      listName: listName ?? this.listName,
      dueDate: dueDate ?? this.dueDate,
      checklist: checklist ?? this.checklist,
      state: state ?? this.state,
      priority: priority ?? this.priority,
      assignees: assignees ?? this.assignees,
      boardId: boardId ?? this.boardId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
