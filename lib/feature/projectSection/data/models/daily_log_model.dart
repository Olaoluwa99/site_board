import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';

import 'package:site_board/core/enums/sync_status.dart';

class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
    required super.projectId,
    required super.dateTimeList,
    required super.numberOfWorkers,
    required super.weatherCondition,
    required super.materialsAvailable,
    required super.plannedTasks,
    required super.startingImageUrl,
    required super.endingImageUrl,
    required super.observations,
    required super.isConfirmed,
    super.workScore = 0.0,
    super.generatedSummary = '',
    super.syncStatus,
  });

  DailyLogModel copyWithModel({
    String? id,
    String? projectId,
    List<DateTime>? dateTimeList,
    int? numberOfWorkers,
    String? weatherCondition,
    List<String>? materialsAvailable,
    List<LogTask>? plannedTasks,
    List<String>? startingImageUrl,
    List<String>? endingImageUrl,
    String? observations,
    bool? isConfirmed,
    double? workScore,
    String? generatedSummary,
    SyncStatus? syncStatus,
  }) {
    return DailyLogModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      dateTimeList: dateTimeList ?? this.dateTimeList,
      numberOfWorkers: numberOfWorkers ?? this.numberOfWorkers,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      materialsAvailable: materialsAvailable ?? this.materialsAvailable,
      plannedTasks: plannedTasks ?? this.plannedTasks,
      startingImageUrl: startingImageUrl ?? this.startingImageUrl,
      endingImageUrl: endingImageUrl ?? this.endingImageUrl,
      observations: observations ?? this.observations,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      workScore: workScore ?? this.workScore,
      generatedSummary: generatedSummary ?? this.generatedSummary,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toCompleteJson() {
    return {
      'id': id,
      'project_id': projectId,
      'date_time_list': dateTimeList.map((dt) => dt.toIso8601String()).toList(),
      'number_of_workers': numberOfWorkers,
      'weather_condition': weatherCondition,
      'materials_available': materialsAvailable,
      'log_tasks':
          plannedTasks.map((task) => (task as LogTaskModel).toJson()).toList(),
      'starting_image_url': startingImageUrl,
      'ending_image_url': endingImageUrl,
      'observations': observations,
      'is_confirmed': isConfirmed,
      'work_score': workScore,

      'generated_summary': generatedSummary,
      'sync_status': syncStatus?.name ?? SyncStatus.synced.name,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'date_time_list': dateTimeList.map((dt) => dt.toIso8601String()).toList(),
      'number_of_workers': numberOfWorkers,
      'weather_condition': weatherCondition,
      'materials_available': materialsAvailable,
      //'planned_tasks': plannedTasks,
      'starting_image_urls': startingImageUrl,
      'ending_image_urls': endingImageUrl,
      'observations': observations,
      'is_confirmed': isConfirmed,
      'work_score': workScore,

      'generated_summary': generatedSummary,
      // 'sync_status': syncStatus?.name ?? SyncStatus.synced.name, // Local only
    };
  }

  factory DailyLogModel.fromJson(Map<String, dynamic> map) {
    return DailyLogModel(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      dateTimeList:
          (map['date_time_list'] as List<dynamic>?)
              ?.map((ts) => DateTime.parse(ts as String))
              .toList() ??
          [],
      numberOfWorkers: map['number_of_workers'] ?? 0,
      weatherCondition: map['weather_condition'] ?? '',
      materialsAvailable: List<String>.from(
        map['materials_available'] ?? const [],
      ),
      startingImageUrl: List<String>.from(
        map['starting_image_urls'] ?? const [],
      ),
      endingImageUrl: List<String>.from(map['ending_image_urls'] ?? const []),
      observations: map['observations'] ?? '',
      isConfirmed: map['is_confirmed'] ?? false,
      workScore: (map['work_score'] ?? 0).toDouble(),
      generatedSummary: map['generated_summary'] ?? '',
      /*plannedTasks:
          (map['log_tasks'] as List<dynamic>?)
              ?.map((t) => LogTaskModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],*/
      plannedTasks:
          (map['log_tasks'] as List<dynamic>?)
              ?.map(
                (log) => LogTaskModel.fromJson(Map<String, dynamic>.from(log)),
              )
              .toList() ??
          [],
      syncStatus:
          map['sync_status'] != null
              ? SyncStatus.values.firstWhere(
                (e) => e.name == map['sync_status'],
                orElse: () => SyncStatus.synced,
              )
              : SyncStatus.synced,
    );
  }

  factory DailyLogModel.fromEntity(DailyLog log) {
    return DailyLogModel(
      id: log.id,
      projectId: log.projectId,
      dateTimeList: log.dateTimeList,
      numberOfWorkers: log.numberOfWorkers,
      weatherCondition: log.weatherCondition,
      materialsAvailable: log.materialsAvailable,
      plannedTasks: log.plannedTasks,
      startingImageUrl: log.startingImageUrl,
      endingImageUrl: log.endingImageUrl,
      observations: log.observations,
      isConfirmed: log.isConfirmed,
      workScore: log.workScore,
      generatedSummary: log.generatedSummary,
      syncStatus: log.syncStatus,
    );
  }
}

class LogTaskModel extends LogTask {
  const LogTaskModel({
    required super.id,
    required super.dailyLogId,
    required super.plannedTask,
    required super.percentCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'daily_log_id': dailyLogId,
      'planned_task': plannedTask,
      'percent_completed': percentCompleted,
    };
  }

  factory LogTaskModel.fromJson(Map<String, dynamic> map) {
    return LogTaskModel(
      id: map['id'] as String,
      dailyLogId: map['daily_log_id'] as String,
      plannedTask: map['planned_task'] ?? '',
      percentCompleted: (map['percent_completed'] ?? 0).toDouble(),
    );
  }
}
