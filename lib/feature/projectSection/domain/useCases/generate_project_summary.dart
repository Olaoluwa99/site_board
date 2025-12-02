import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/domain/entities/project_summary.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/format_date.dart';

class GenerateProjectSummary
    implements UserCase<ProjectSummary, GenerateProjectSummaryParams> {
  final ProjectRepository projectRepository;

  GenerateProjectSummary(this.projectRepository);

  @override
  Future<Either<Failure, ProjectSummary>> call(
      GenerateProjectSummaryParams params,
      ) async {
    // 1. Filter Logs based on Mode
    List<DailyLog> filteredLogs = [];

    if (params.mode == SummaryMode.daily) {
      if (params.selectedDate == null) {
        return left(Failure("Date must be selected for Daily Summary"));
      }
      filteredLogs =
          params.project.dailyLogs.where((log) {
            // Check if any date in the log's dateTimeList matches the selected date
            return log.dateTimeList.any(
                  (dt) => isSameDate(dt, params.selectedDate!),
            );
          }).toList();
    } else if (params.mode == SummaryMode.custom) {
      if (params.startDate == null || params.endDate == null) {
        return left(Failure("Date range must be selected for Custom Summary"));
      }
      filteredLogs =
          params.project.dailyLogs.where((log) {
            // Check if any date in log falls within range
            return log.dateTimeList.any((dt) {
              return dt.isAfter(
                params.startDate!.subtract(const Duration(seconds: 1)),
              ) &&
                  dt.isBefore(params.endDate!.add(const Duration(seconds: 1)));
            });
          }).toList();
    } else {
      // Full Project
      filteredLogs = params.project.dailyLogs;
    }

    if (filteredLogs.isEmpty) {
      return left(
        Failure(
          "No logs found for the selected period. Cannot generate summary.",
        ),
      );
    }

    // 2. Construct Prompt
    final prompt = _constructPrompt(params.project.projectName, filteredLogs);

    // 3. Call Repository
    return await projectRepository.generateProjectSummary(promptText: prompt);
  }

  String _constructPrompt(String projectName, List<DailyLog> logs) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln("Generate a professional project summary for: $projectName.");
    buffer.writeln(
      "The summary should be based on the following daily logs data:",
    );
    buffer.writeln("--------------------------------------------------");

    for (var log in logs) {
      buffer.writeln(
        "Date: ${log.dateTimeList.isNotEmpty ? formatDateBydMMMYYYY(log.dateTimeList.first) : 'Unknown'}",
      );
      buffer.writeln("Weather: ${log.weatherCondition}");
      buffer.writeln("Workers: ${log.numberOfWorkers}");
      buffer.writeln("Observations: ${log.observations}");
      buffer.writeln("Tasks:");
      for (var task in log.plannedTasks) {
        buffer.writeln(
          "- ${task.plannedTask} (${task.percentCompleted}% completed)",
        );
      }
      buffer.writeln("--------------------------------------------------");
    }

    buffer.writeln("Output ONLY valid JSON matching this schema:");
    buffer.writeln("""
    {
      "title": "A concise title for the summary",
      "date_range": "e.g., '12 Oct - 15 Oct 2023' or '12 Oct 2023'",
      "overview": "A professional paragraph summarizing the progress, weather impact, and workforce.",
      "completed_tasks": ["List of tasks that reached 100% or significant progress"],
      "issues_raised": ["List of challenges, delays, or critical observations mentioned"],
      "upcoming_plans": "A suggestion for next steps based on unfinished tasks."
    }
    """);

    return buffer.toString();
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

enum SummaryMode { daily, custom, full }

class GenerateProjectSummaryParams {
  final Project project;
  final SummaryMode mode;
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;

  GenerateProjectSummaryParams({
    required this.project,
    required this.mode,
    this.selectedDate,
    this.startDate,
    this.endDate,
  });
}