import 'package:site_board/feature/projectSection/domain/entities/Member.dart';

class MemberModel extends Member {
  MemberModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.email,
    required super.userId,
    required super.isAccepted,
    required super.isBlocked,
    required super.isAdmin,
    required super.hasLeft,
    required super.lastViewed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'email': email,
      'user_id': userId,
      'is_accepted': isAccepted,
      'is_blocked': isBlocked,
      'is_admin': isAdmin,
      'last_viewed': lastViewed.toIso8601String(),
    };
  }

  factory MemberModel.fromJson(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] as String,
      projectId: map['project_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userId: map['user_id'] ?? '',
      isAccepted: map['is_accepted'] ?? false,
      isBlocked: map['is_blocked'] ?? false,
      isAdmin: map['is_admin'] ?? false,
      hasLeft: map['has_left'] ?? false,
      lastViewed:
          map['last_viewed'] == null
              ? DateTime.now()
              : DateTime.parse(map['last_viewed']),
    );
  }
}
