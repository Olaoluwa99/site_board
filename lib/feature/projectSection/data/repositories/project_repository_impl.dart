import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/data/models/daily_log_model.dart';
import 'package:site_board/feature/projectSection/data/models/member_model.dart';
import 'package:site_board/feature/projectSection/data/models/project_model.dart';
import 'package:site_board/feature/projectSection/domain/entities/Member.dart';
import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/domain/entities/retrieved_projects.dart';
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
  Future<Either<Failure, Project>> createProject({
    required Project project,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      ProjectModel projectModel = ProjectModel(
        id: const Uuid().v1(),
        projectName: project.projectName,
        creatorId: project.creatorId,
        projectLink: project.projectLink,
        description: project.description,
        teamAdminIds: project.teamAdminIds,
        teamMembers: project.teamMembers,
        createdDate: DateTime.now(),
        endDate: project.endDate,
        dailyLogs: [],
        location: project.location,
        isActive: project.isActive,
        lastUpdated: DateTime.now(),
        coverPhotoUrl: project.coverPhotoUrl,
        projectSecurityType: project.projectSecurityType,
        projectPassword: project.projectPassword,
      );
      debugPrint(
        '-------------------------------------------------------------------------------------------------',
      );
      final uploadedProject = await projectRemoteDataSource.createProject(
        projectModel,
      );
      return right(uploadedProject);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject({
    required Project project,
    required File? image,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      ProjectModel projectModel = ProjectModel(
        id: project.id,
        projectName: project.projectName,
        creatorId: project.creatorId,
        projectLink: project.projectLink,
        description: project.description,
        teamAdminIds: project.teamAdminIds,
        teamMembers: project.teamMembers,
        createdDate: project.createdDate,
        endDate: project.endDate,
        dailyLogs: [],
        location: project.location,
        isActive: project.isActive,
        lastUpdated: DateTime.now(),
        coverPhotoUrl: project.coverPhotoUrl,
        projectSecurityType: project.projectSecurityType,
        projectPassword: project.projectPassword,
      );
      final uploadedProject = await projectRemoteDataSource.updateProject(
        projectModel,
      );
      return right(uploadedProject);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, DailyLog>> createDailyLog({
    required String projectId,
    required DailyLog dailyLog,
    required bool isCurrentTaskModified,
    required List<LogTask> currentTasks,
    required List<File?> startingTaskImageList,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      DailyLogModel dailyLogModel = DailyLogModel(
        id: dailyLog.id,
        projectId: dailyLog.projectId,
        dateTimeList: dailyLog.dateTimeList,
        numberOfWorkers: dailyLog.numberOfWorkers,
        weatherCondition: dailyLog.weatherCondition,
        materialsAvailable: dailyLog.materialsAvailable,
        plannedTasks: dailyLog.plannedTasks,
        startingImageUrl: dailyLog.startingImageUrl,
        endingImageUrl: dailyLog.endingImageUrl,
        observations: dailyLog.observations,
        isConfirmed: dailyLog.isConfirmed,
        workScore: dailyLog.workScore,
        generatedSummary: dailyLog.generatedSummary,
      );
      final modifiedStartingImageUrlList = await projectRemoteDataSource
          .uploadDailyLogImages(
            isEndingImages: false,
            images: startingTaskImageList,
            dailyLogModel: dailyLogModel,
          );
      dailyLogModel.copyWith(
        startingImageUrl: imageModifier(
          dailyLog.startingImageUrl,
          modifiedStartingImageUrlList,
        ),
      );

      final uploadedDailyLog = await projectRemoteDataSource.createDailyLog(
        dailyLogModel,
      );

      if (isCurrentTaskModified) {
        final setupCurrentTasks = taskConverter(currentTasks);
        await projectRemoteDataSource.syncLogTasks(
          dailyLogId: dailyLog.id,
          currentTasks: setupCurrentTasks,
        );
      }
      return right(uploadedDailyLog.copyWith(plannedTasks: currentTasks));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, DailyLog>> updateDailyLog({
    required String projectId,
    required DailyLog dailyLog,
    required bool isCurrentTaskModified,
    required List<LogTask> currentTasks,
    required List<File?> startingTaskImageList,
    required List<File?> endingTaskImageList,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      DailyLogModel dailyLogModel = DailyLogModel(
        id: dailyLog.id,
        projectId: dailyLog.projectId,
        dateTimeList: dailyLog.dateTimeList,
        numberOfWorkers: dailyLog.numberOfWorkers,
        weatherCondition: dailyLog.weatherCondition,
        materialsAvailable: dailyLog.materialsAvailable,
        plannedTasks: dailyLog.plannedTasks,
        startingImageUrl: dailyLog.startingImageUrl,
        endingImageUrl: dailyLog.endingImageUrl,
        observations: dailyLog.observations,
        isConfirmed: dailyLog.isConfirmed,
        workScore: dailyLog.workScore,
        generatedSummary: dailyLog.generatedSummary,
      );

      if (hasAtLeastOneFile(startingTaskImageList)) {
        final modifiedStartingImageUrlList = await projectRemoteDataSource
            .uploadDailyLogImages(
              isEndingImages: false,
              images: startingTaskImageList,
              dailyLogModel: dailyLogModel,
            );
        dailyLogModel.copyWith(
          startingImageUrl: imageModifier(
            dailyLog.startingImageUrl,
            modifiedStartingImageUrlList,
          ),
        );
      }

      if (hasAtLeastOneFile(endingTaskImageList)) {
        final modifiedEndingTaskImageUrlList = await projectRemoteDataSource
            .uploadDailyLogImages(
              isEndingImages: true,
              images: endingTaskImageList,
              dailyLogModel: dailyLogModel,
            );

        dailyLogModel.copyWith(
          endingImageUrl: imageModifier(
            dailyLog.endingImageUrl,
            modifiedEndingTaskImageUrlList,
          ),
        );
      }

      /*dailyLogModel.copyWith(
        startingImageUrl: imageModifier(
          dailyLog.startingImageUrl,
          modifiedStartingImageUrlList,
        ),
        endingImageUrl: imageModifier(
          dailyLog.endingImageUrl,
          modifiedEndingTaskImageUrlList,
        ),
      );*/

      final setupCurrentTasks = taskConverter(currentTasks);
      await projectRemoteDataSource.syncLogTasks(
        dailyLogId: dailyLog.id,
        currentTasks: setupCurrentTasks,
      );

      final uploadedDailyLog = await projectRemoteDataSource.updateDailyLog(
        dailyLogModel,
      );
      return right(uploadedDailyLog.copyWith(plannedTasks: currentTasks));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Member>> createMember({
    required String projectId,
    required Member member,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      MemberModel memberModel = MemberModel(
        id: member.id,
        projectId: member.projectId,
        name: member.name,
        email: member.email,
        userId: member.userId,
        isAccepted: member.isAccepted,
        isBlocked: member.isBlocked,
        isAdmin: member.isAdmin,
        hasLeft: member.hasLeft,
        lastViewed: member.lastViewed,
      );

      final uploadedMember = await projectRemoteDataSource.createMember(
        memberModel,
      );
      return right(uploadedMember);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Member>> updateMember({
    required String projectId,
    required Member member,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      MemberModel memberModel = MemberModel(
        id: member.id,
        projectId: member.projectId,
        name: member.name,
        email: member.email,
        userId: member.userId,
        isAccepted: member.isAccepted,
        isBlocked: member.isBlocked,
        isAdmin: member.isAdmin,
        hasLeft: member.hasLeft,
        lastViewed: member.lastViewed,
      );

      final uploadedMember = await projectRemoteDataSource.updateMember(
        memberModel,
      );
      return right(uploadedMember);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<LogTask>>> manageLogTasks({
    required String dailyLogId,
    required List<LogTask> currentTasks,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final setupCurrentTasks = taskConverter(currentTasks);
      await projectRemoteDataSource.syncLogTasks(
        dailyLogId: dailyLogId,
        currentTasks: setupCurrentTasks,
      );
      return right(setupCurrentTasks);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, RetrievedProjects>> getAllProjects({
    required String userId,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        /*final projects = projectLocalDataSource.loadProjects();
        return right(RetrievedProjects(isLocal: true, projects: projects));*/
        return left(Failure('Not connected to the internet. Try again later.'));
      }
      final projects = await projectRemoteDataSource.getAllProjects(
        userId: userId,
      );
      projectLocalDataSource.uploadLocalProjects(projects: projects);
      return right(RetrievedProjects(projects: projects));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getRecentProjects() async {
    try {
      final projects = projectLocalDataSource.loadRecentProjects();
      return right(projects);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProjectModel>> getProjectById({
    required String projectId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
          Failure(
            'Can\'t fetch project right now. Connect to the internet and try again.',
          ),
        );
      }
      final remoteProject = await projectRemoteDataSource.getProjectById(
        projectId: projectId,
      );
      projectLocalDataSource.uploadRecentProject(project: remoteProject);
      return right(remoteProject);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectModel>> getProjectByLink({
    required String projectLink,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
          Failure(
            'Can\'t fetch project right now. Connect to the internet and try again.',
          ),
        );
      }
      final remoteProject = await projectRemoteDataSource.getProjectByLink(
        projectLink: projectLink,
      );
      projectLocalDataSource.uploadRecentProject(project: remoteProject);
      return right(remoteProject);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  List<DailyLogModel> logConverter(List<DailyLog> logs) {
    List<DailyLogModel> updatedList = [];
    for (DailyLog dLog in logs) {
      updatedList.add(
        DailyLogModel(
          id: dLog.id,
          projectId: dLog.projectId,
          dateTimeList: dLog.dateTimeList,
          numberOfWorkers: dLog.numberOfWorkers,
          weatherCondition: dLog.weatherCondition,
          materialsAvailable: dLog.materialsAvailable,
          plannedTasks: taskConverter(dLog.plannedTasks),
          startingImageUrl: dLog.startingImageUrl,
          endingImageUrl: dLog.endingImageUrl,
          observations: dLog.observations,
          isConfirmed: dLog.isConfirmed,
          workScore: dLog.workScore,
          generatedSummary: dLog.generatedSummary,
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
          id: lTask.id,
          dailyLogId: lTask.dailyLogId,
          plannedTask: lTask.plannedTask,
          percentCompleted: lTask.percentCompleted,
        ),
      );
    }
    return updatedList;
  }

  List<String> imageModifier(
    List<String> currentImageUrls,
    List<String> newImageUrls,
  ) {
    List<String> updatedStartingList = currentImageUrls;
    for (int index = 0; index < newImageUrls.length; index++) {
      final selectedUrl = newImageUrls[index];
      if (selectedUrl != '') {
        updatedStartingList[index] = selectedUrl;
      }
    }
    return updatedStartingList;
  }

  bool hasAtLeastOneFile(List<File?> files) {
    if (files.isEmpty) return false;
    return files.any((file) => file != null);
  }
}
