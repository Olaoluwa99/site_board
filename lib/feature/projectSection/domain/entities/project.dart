import 'package:uuid/uuid.dart';

import 'daily_log.dart';

class Project {
  final String id;
  final String projectName;
  final String creatorId;
  final String? projectLink;
  final String? description;
  final List<String> teamMemberIds;
  final DateTime createdDate;
  final DateTime? endDate;
  final List<DailyLog> dailyLogs;
  final String? location;
  final bool isActive;
  final DateTime lastUpdated;
  final String? coverPhotoUrl;

  Project({
    String? id,
    required this.projectName,
    required this.creatorId,
    this.projectLink,
    this.description,
    this.teamMemberIds = const [],
    DateTime? createdDate,
    this.endDate,
    this.dailyLogs = const [],
    this.location,
    this.isActive = true,
    DateTime? lastUpdated,
    this.coverPhotoUrl,
  }) : id = id ?? const Uuid().v4(),
       createdDate = createdDate ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();

  Project copyWith({
    String? id,
    String? projectName,
    String? creatorId,
    String? projectLink,
    String? description,
    List<String>? teamMemberIds,
    DateTime? createdDate,
    DateTime? endDate,
    List<DailyLog>? dailyLogs,
    String? location,
    bool? isActive,
    DateTime? lastUpdated,
    String? coverPhotoUrl,
  }) {
    return Project(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      creatorId: creatorId ?? this.creatorId,
      projectLink: projectLink ?? this.projectLink,
      description: description ?? this.description,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      createdDate: createdDate ?? this.createdDate,
      endDate: endDate ?? this.endDate,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
    );
  }
}
