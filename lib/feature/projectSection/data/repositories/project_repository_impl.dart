import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/data/models/daily_log_model.dart';
import 'package:site_board/feature/projectSection/data/models/project_model.dart';
import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/connection_checker.dart';
import '../../domain/repositories/project_repository.dart';
import '../dataSources/project_local_data_source.dart';
import '../dataSources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource projectRemoteDataSource;
  final ProjectLocalDataSource projectLocalDataSource;
  final ConnectionChecker connectionChecker;
  ProjectRepositoryImpl(
    this.projectRemoteDataSource,
    this.projectLocalDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, Project>> uploadProject({
    required Project project,
    required DailyLog? dailyLog,
    required bool isUpdate,
    required bool isCoverImage,
    required bool isDailyLogIncluded,
    required File image,
    required List<File?> taskImageList,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      if (isUpdate) {
        ProjectModel projectModel = ProjectModel(
          id: project.id,
          projectName: project.projectName,
          creatorId: project.creatorId,
          teamMemberIds: project.teamMemberIds,
          createdDate: project.createdDate,
          dailyLogs: logConverter(project.dailyLogs),
          isActive: project.isActive,
          lastUpdated: DateTime.now(),
        );

        if (isCoverImage) {
          final imageUrl = await projectRemoteDataSource
              .uploadProjectCoverImage(image: image, project: projectModel);
          projectModel = projectModel.copyWith(coverPhotoUrl: imageUrl);
        }

        if (isDailyLogIncluded) {
          DailyLogModel nDailyLog = DailyLogModel(
            id: dailyLog!.id,
            dateTimeList: dailyLog.dateTimeList,
            numberOfWorkers: dailyLog.numberOfWorkers,
            weatherCondition: dailyLog.weatherCondition,
            materialsAvailable: dailyLog.materialsAvailable,
            plannedTasks: dailyLog.plannedTasks,
            startingImageUrl: dailyLog.startingImageUrl,
            endingImageUrl: dailyLog.endingImageUrl,
            observations: dailyLog.observations,
            isConfirmed: dailyLog.isConfirmed,
          );
          final taskImageUrlList = await projectRemoteDataSource
              .uploadDailyLogImages(
                images: taskImageList,
                dailyLogModel: nDailyLog,
              );
          List<String> newList = nDailyLog.startingImageUrl;
          for (int index = 0; index < taskImageUrlList.length; index++) {
            final selectedUrl = taskImageUrlList[index];
            if (selectedUrl != '') {
              newList[index] = selectedUrl;
            }
          }
          nDailyLog.copyWith(startingImageUrl: newList);
        }

        final uploadedProject = await projectRemoteDataSource.updateProject(
          projectModel,
        );
        return right(uploadedProject);
      } else {
        ProjectModel projectModel = ProjectModel(
          id: const Uuid().v1(),
          projectName: project.projectName,
          creatorId: project.creatorId,
          teamMemberIds: project.teamMemberIds,
          createdDate: DateTime.now(),
          dailyLogs: logConverter(project.dailyLogs),
          isActive: project.isActive,
          lastUpdated: DateTime.now(),
        );
        final uploadedProject = await projectRemoteDataSource.uploadProject(
          projectModel,
        );
        return right(uploadedProject);
      }
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects({
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final projects = projectLocalDataSource.loadProjects();
        return right(projects);
      }
      final projects = await projectRemoteDataSource.getAllProjects(
        userId: userId,
      );
      projectLocalDataSource.uploadLocalProjects(projects: projects);
      return right(projects);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  List<DailyLogModel> logConverter(List<DailyLog> logs) {
    List<DailyLogModel> updatedList = [];
    for (DailyLog dLog in logs) {
      updatedList.add(
        DailyLogModel(
          id: dLog.id,
          dateTimeList: dLog.dateTimeList,
          numberOfWorkers: dLog.numberOfWorkers,
          weatherCondition: dLog.weatherCondition,
          materialsAvailable: dLog.materialsAvailable,
          plannedTasks: taskConverter(dLog.plannedTasks),
          startingImageUrl: dLog.startingImageUrl,
          endingImageUrl: dLog.endingImageUrl,
          observations: dLog.observations,
          isConfirmed: dLog.isConfirmed,
        ),
      );
    }
    return updatedList;
  }

  List<LogTaskModel> taskConverter(List<LogTask> tasks) {
    List<LogTaskModel> updatedList = [];

    for (LogTask lTask in tasks) {
      updatedList.add(
        LogTaskModel(
          plannedTask: lTask.plannedTask,
          percentCompleted: lTask.percentCompleted,
        ),
      );
    }
    return updatedList;
  }
}
