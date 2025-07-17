import 'package:site_board/feature/projectSection/domain/entities/Member.dart';
import 'package:uuid/uuid.dart';

import 'daily_log.dart';

class Project {
  final String id;
  final String projectName;
  final String creatorId;
  final String? projectLink;
  final String? description;
  final List<String> teamAdminIds;
  final List<Member> teamMembers;
  final DateTime createdDate;
  final DateTime? endDate;
  final List<DailyLog> dailyLogs;
  final String? location;
  final bool isActive;
  final DateTime lastUpdated;
  final String? coverPhotoUrl;
  final String projectSecurityType;
  final String projectPassword;

  Project({
    String? id,
    required this.projectName,
    required this.creatorId,
    this.projectLink,
    this.description,
    this.teamAdminIds = const [],
    this.teamMembers = const [],
    DateTime? createdDate,
    this.endDate,
    this.dailyLogs = const [],
    this.location,
    this.isActive = true,
    DateTime? lastUpdated,
    this.coverPhotoUrl,
    required this.projectSecurityType,
    required this.projectPassword,
  }) : id = id ?? const Uuid().v4(),
       createdDate = createdDate ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();

  Project copyWith({
    String? id,
    String? projectName,
    String? creatorId,
    String? projectLink,
    String? description,
    List<String>? teamAdminIds,
    List<Member>? teamMembers,
    DateTime? createdDate,
    DateTime? endDate,
    List<DailyLog>? dailyLogs,
    String? location,
    bool? isActive,
    DateTime? lastUpdated,
    String? coverPhotoUrl,
    String? projectSecurityType,
    String? projectPassword,
  }) {
    return Project(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      creatorId: creatorId ?? this.creatorId,
      projectLink: projectLink ?? this.projectLink,
      description: description ?? this.description,
      teamAdminIds: teamAdminIds ?? this.teamAdminIds,
      teamMembers: teamMembers ?? this.teamMembers,
      createdDate: createdDate ?? this.createdDate,
      endDate: endDate ?? this.endDate,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      projectSecurityType: projectSecurityType ?? this.projectSecurityType,
      projectPassword: projectPassword ?? this.projectPassword,
    );
  }
}
