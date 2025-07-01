import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class CreateDailyLog implements UserCase<DailyLog, CreateDailyLogParams> {
  final ProjectRepository projectRepository;
  CreateDailyLog(this.projectRepository);
  @override
  Future<Either<Failure, DailyLog>> call(CreateDailyLogParams params) async {
    return await projectRepository.createDailyLog(
      projectId: params.projectId,
      dailyLog: params.dailyLog,
      isCurrentTaskModified: params.isCurrentTaskModified,
      currentTasks: params.currentTasks,
      startingTaskImageList: params.startingTaskImageList,
    );
  }
}

class CreateDailyLogParams {
  final String projectId;
  final DailyLog dailyLog;
  final bool isCurrentTaskModified;
  final List<LogTask> currentTasks;
  final List<File?> startingTaskImageList;

  CreateDailyLogParams({
    required this.projectId,
    required this.dailyLog,
    required this.isCurrentTaskModified,
    required this.currentTasks,
    required this.startingTaskImageList,
  });
}
