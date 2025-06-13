class DailyLog {
  final String id;
  final DateTime dateTime;
  final int numberOfWorkers;
  final String weatherCondition;
  final List<String> materialsAvailable;
  final List<LogTask> plannedTasks;
  final List<String> startingImageUrl;
  final List<String> endingImageUrl;
  final String observations;

  const DailyLog({
    required this.id,
    required this.dateTime,
    required this.numberOfWorkers,
    required this.weatherCondition,
    required this.materialsAvailable,
    required this.plannedTasks,
    required this.startingImageUrl,
    required this.endingImageUrl,
    required this.observations,
  });
}

class LogTask {
  final String plannedTask;
  final String status;

  const LogTask({required this.plannedTask, required this.status});
}
