import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';

class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
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
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> map) {
    return DailyLogModel(
      id: map['id'] as String,
      dateTimeList:
          (map['date_time_list'] as List<dynamic>?)
              ?.map((ts) => DateTime.fromMillisecondsSinceEpoch(ts))
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
      plannedTasks:
          (map['log_tasks'] as List<dynamic>?)
              ?.map((t) => LogTaskModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
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

  factory LogTaskModel.fromJson(Map<String, dynamic> map) {
    return LogTaskModel(
      id: map['id'] as String,
      dailyLogId: map['daily_log_id'] as String,
      plannedTask: map['planned_task'] ?? '',
      percentCompleted: (map['percent_completed'] ?? 0).toDouble(),
    );
  }
}
