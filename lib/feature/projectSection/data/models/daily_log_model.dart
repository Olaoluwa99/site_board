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
}

class LogTaskModel extends LogTask {

  const LogTaskModel({
    required super.plannedTask,
    required super.percentCompleted,
  });
}
