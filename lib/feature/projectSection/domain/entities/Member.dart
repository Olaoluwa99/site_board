class Member {
  final String id;
  final String projectId;
  final String name;
  final String email;
  final String userId;
  final bool isAccepted;
  final bool isBlocked;
  final bool isAdmin;
  final bool hasLeft;
  final DateTime lastViewed;

  const Member({
    required this.id,
    required this.projectId,
    required this.name,
    required this.email,
    required this.userId,
    required this.isAccepted,
    required this.isBlocked,
    required this.isAdmin,
    required this.hasLeft,
    required this.lastViewed,
  });

  Member copyWith({
    String? id,
    String? projectId,
    String? name,
    String? email,
    String? userId,
    bool? isAccepted,
    bool? isBlocked,
    bool? isAdmin,
    bool? hasLeft,
    DateTime? lastViewed,
  }) {
    return Member(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      isAccepted: isAccepted ?? this.isAccepted,
      isBlocked: isBlocked ?? this.isBlocked,
      isAdmin: isAdmin ?? this.isAdmin,
      hasLeft: hasLeft ?? this.hasLeft,
      lastViewed: lastViewed ?? this.lastViewed,
    );
  }
}
