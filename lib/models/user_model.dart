// =============================================================================
//  UserModel
// =============================================================================

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? token;
  final String? avatarUrl;
  final String? avatarLetter;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.token,
    this.avatarUrl,
    this.avatarLetter,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final sessionId = userMap['session_id'] as String? ??
        userMap['token'] as String? ??
        json['session_id'] as String? ??
        json['token'] as String?;

    return UserModel(
      id: userMap['id'] as int? ?? 0,
      name: userMap['name'] as String? ?? '',
      email: userMap['email'] as String? ?? '',
      phone: userMap['phone'] as String?,
      role: userMap['role'] as String?,
      token: sessionId,
      avatarUrl: userMap['avatar_url'] as String?,
      avatarLetter: userMap['avatar_letter'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
        if (token != null) 'token': token,
        if (token != null) 'session_id': token,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (avatarLetter != null) 'avatar_letter': avatarLetter,
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? token,
    String? avatarUrl,
    String? avatarLetter,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarLetter: avatarLetter ?? this.avatarLetter,
    );
  }
}
