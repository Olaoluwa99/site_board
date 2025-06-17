import 'package:uuid/uuid.dart';

import 'DailyLog.dart';

class Project {
  final String id;
  final String projectName;
  final String creatorId;
  final String? projectLink;
  final String? description;
  final List<String> teamMemberIds;
  final DateTime createdDate;
  final DateTime? startDate;
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
    this.startDate,
    this.endDate,
    this.dailyLogs = const [],
    this.location,
    this.isActive = true,
    DateTime? lastUpdated,
    this.coverPhotoUrl,
  }) : id = id ?? const Uuid().v4(),
       createdDate = createdDate ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();
}
