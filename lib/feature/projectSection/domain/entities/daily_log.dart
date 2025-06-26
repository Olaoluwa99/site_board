class DailyLog {
  final String id;
  final List<DateTime> dateTimeList;
  final int numberOfWorkers;
  final String weatherCondition;
  final List<String> materialsAvailable;
  final List<LogTask> plannedTasks;
  final List<String> startingImageUrl;
  final List<String> endingImageUrl;
  final String observations;
  final bool isConfirmed;
  final double workScore;
  final String generatedSummary;

  const DailyLog({
    required this.id,
    required this.dateTimeList,
    required this.numberOfWorkers,
    required this.weatherCondition,
    required this.materialsAvailable,
    required this.plannedTasks,
    required this.startingImageUrl,
    required this.endingImageUrl,
    required this.observations,
    required this.isConfirmed,
    this.workScore = 0.0,
    this.generatedSummary = '',
  });

  DailyLog copyWith({
    String? id,
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
  }) {
    return DailyLog(
      id: id ?? this.id,
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
    );
  }
}

class LogTask {
  final String id;
  final String dailyLogId;
  final String plannedTask;
  final double percentCompleted;

  const LogTask({
    required this.id,
    required this.dailyLogId,
    required this.plannedTask,
    required this.percentCompleted,
  });

  LogTask copyWith({
    String? id,
    String? dailyLogId,
    String? plannedTask,
    double? percentCompleted,
  }) {
    return LogTask(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      plannedTask: plannedTask ?? this.plannedTask,
      percentCompleted: percentCompleted ?? this.percentCompleted,
    );
  }
}
