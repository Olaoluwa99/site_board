import 'package:site_board/feature/projectSection/data/models/daily_log_model.dart';
import 'package:site_board/feature/projectSection/data/models/member_model.dart';

import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  ProjectModel({
    required super.id,
    required super.projectName,
    required super.creatorId,
    super.projectLink,
    super.description,
    required super.teamAdminIds,
    required super.teamMembers,
    required super.createdDate,
    super.endDate,
    required super.dailyLogs,
    super.location,
    required super.isActive,
    required super.lastUpdated,
    super.coverPhotoUrl = '',
    required super.projectSecurityType,
    required super.projectPassword,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          projectName == other.projectName &&
          creatorId == other.creatorId &&
          projectLink == other.projectLink &&
          description == other.description &&
          teamAdminIds == other.teamAdminIds &&
          teamMembers == other.teamMembers &&
          createdDate == other.createdDate &&
          endDate == other.endDate &&
          dailyLogs == other.dailyLogs &&
          location == other.location &&
          isActive == other.isActive &&
          lastUpdated == other.lastUpdated &&
          coverPhotoUrl == other.coverPhotoUrl &&
          projectSecurityType == other.projectSecurityType &&
          projectPassword == other.projectPassword);

  @override
  String toString() {
    return 'ProjectModel{' +
        ' id: $id,' +
        ' projectName: $projectName,' +
        ' creatorId: $creatorId,' +
        ' projectLink: $projectLink,' +
        ' description: $description,' +
        ' teamAdminIds: $teamAdminIds,' +
        ' members: $teamMembers,' +
        ' createdDate: $createdDate,' +
        ' endDate: $endDate,' +
        ' dailyLogs: $dailyLogs,' +
        ' location: $location,' +
        ' isActive: $isActive,' +
        ' lastUpdated: $lastUpdated,' +
        ' coverPhotoUrl: $coverPhotoUrl,' +
        ' projectSecurityType: $projectSecurityType,' +
        ' projectPassword: $projectPassword,' +
        '}';
  }

  ProjectModel copyWithModel({
    String? id,
    String? projectName,
    String? creatorId,
    String? projectLink,
    String? description,
    List<String>? teamAdminIds,
    List<MemberModel>? teamMembers,
    DateTime? createdDate,
    DateTime? endDate,
    List<DailyLogModel>? dailyLogs,
    String? location,
    bool? isActive,
    DateTime? lastUpdated,
    String? coverPhotoUrl,
    String? projectSecurityType,
    String? projectPassword,
  }) {
    return ProjectModel(
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

  Map<String, dynamic> toCompleteJson() {
    return {
      'id': id,
      'project_name': projectName,
      'creator_id': creatorId,
      'project_link': projectLink,
      'description': description,
      'team_admin_ids': teamAdminIds,
      'members':
          teamMembers
              .map((member) => (member as MemberModel).toJson())
              .toList(),
      'created_date': createdDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'daily_logs':
          dailyLogs
              .map((log) => (log as DailyLogModel).toCompleteJson())
              .toList(),
      'location': location,
      'is_active': isActive,
      'last_updated': lastUpdated.toIso8601String(),
      'cover_photo_url': coverPhotoUrl,
      'project_security_type': projectSecurityType,
      'project_password': projectPassword,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_name': projectName,
      'creator_id': creatorId,
      'project_link': projectLink,
      'description': description,
      'team_admin_ids': teamAdminIds,
      'created_date': createdDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'is_active': isActive,
      'last_updated': lastUpdated.toIso8601String(),
      'cover_photo_url': coverPhotoUrl,
      'project_security_type': projectSecurityType,
      'project_password': projectPassword,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      projectName: map['project_name'] ?? '',
      creatorId: map['creator_id'] ?? '',
      projectLink: map['project_link'] ?? '',
      description: map['description'] ?? '',
      teamAdminIds: List<String>.from(map['team_admin_ids'] ?? const []),
      teamMembers:
          (map['members'] as List<dynamic>?)
              ?.map(
                (member) =>
                    MemberModel.fromJson(Map<String, dynamic>.from(member)),
              )
              .toList() ??
          [],
      createdDate:
          map['created_date'] == null
              ? DateTime.now()
              : DateTime.parse(map['created_date']),
      endDate:
          map['end_date'] == null
              ? DateTime.now()
              : DateTime.parse(map['end_date']),
      dailyLogs:
          (map['daily_logs'] as List<dynamic>?)
              ?.map(
                (log) => DailyLogModel.fromJson(Map<String, dynamic>.from(log)),
              )
              .toList() ??
          [],
      location: map['location'] ?? '',
      isActive: map['is_active'] as bool,
      lastUpdated:
          map['last_updated'] == null
              ? DateTime.now()
              : DateTime.parse(map['last_updated']),
      coverPhotoUrl: map['cover_photo_url'] ?? '',
      projectSecurityType: map['project_security_type'] ?? '',
      projectPassword: map['project_password'] ?? '',
    );
  }
}
