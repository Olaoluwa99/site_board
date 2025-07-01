import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class UpdateDailyLog implements UserCase<DailyLog, UpdateDailyLogParams> {
  final ProjectRepository projectRepository;
  UpdateDailyLog(this.projectRepository);
  @override
  Future<Either<Failure, DailyLog>> call(UpdateDailyLogParams params) async {
    return await projectRepository.updateDailyLog(
      projectId: params.projectId,
      dailyLog: params.dailyLog,
      isCurrentTaskModified: params.isCurrentTaskModified,
      currentTasks: params.currentTasks,
      startingTaskImageList: params.startingTaskImageList,
      endingTaskImageList: params.endingTaskImageList,
    );
  }
}

class UpdateDailyLogParams {
  final String projectId;
  final DailyLog dailyLog;
  final List<LogTask> currentTasks;
  final bool isCurrentTaskModified;
  final List<File?> startingTaskImageList;
  final List<File?> endingTaskImageList;

  UpdateDailyLogParams({
    required this.projectId,
    required this.dailyLog,
    required this.currentTasks,
    required this.isCurrentTaskModified,
    required this.startingTaskImageList,
    required this.endingTaskImageList,
  });
}
