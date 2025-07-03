import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';

import '../../../../core/error/failure.dart';
import '../entities/daily_log.dart';
import '../entities/retrieved_projects.dart';

abstract interface class ProjectRepository {
  Future<Either<Failure, Project>> createProject({required Project project});

  Future<Either<Failure, Project>> updateProject({
    required Project project,
    required File? image,
  });

  Future<Either<Failure, DailyLog>> createDailyLog({
    required String projectId,
    required DailyLog dailyLog,
    required bool isCurrentTaskModified,
    required List<LogTask> currentTasks,
    required List<File?> startingTaskImageList,
  });

  Future<Either<Failure, DailyLog>> updateDailyLog({
    required String projectId,
    required DailyLog dailyLog,
    required bool isCurrentTaskModified,
    required List<LogTask> currentTasks,
    required List<File?> startingTaskImageList,
    required List<File?> endingTaskImageList,
  });

  Future<Either<Failure, List<LogTask>>> manageLogTasks({
    required String dailyLogId,
    required List<LogTask> currentTasks,
  });

  Future<Either<Failure, RetrievedProjects>> getAllProjects({
    required String userId,
  });
}
