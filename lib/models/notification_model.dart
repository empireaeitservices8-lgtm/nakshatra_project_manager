// =============================================================================
//  NotificationModel
// =============================================================================

class NotificationModel {
  final int id;
  final String title;
  final String? message;
  final bool isRead;
  final String? type;
  final int? relatedId;    // e.g. task_id or board_id that triggered the notification
  final String? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    this.message,
    required this.isRead,
    this.type,
    this.relatedId,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ??
          json['name'] as String? ??
          '',
      message: json['message'] as String? ?? json['body'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      type: json['type'] as String?,
      relatedId: json['related_id'] as int?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (message != null) 'message': message,
        'is_read': isRead,
        if (type != null) 'type': type,
        if (relatedId != null) 'related_id': relatedId,
        if (createdAt != null) 'created_at': createdAt,
      };

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      type: type,
      relatedId: relatedId,
      createdAt: createdAt,
    );
  }
}
