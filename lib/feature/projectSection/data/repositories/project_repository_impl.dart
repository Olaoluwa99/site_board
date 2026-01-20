import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/data/models/daily_log_model.dart';
import 'package:site_board/feature/projectSection/data/models/member_model.dart';
import 'package:site_board/feature/projectSection/data/models/project_model.dart';
import 'package:site_board/feature/projectSection/domain/entities/Member.dart';
import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/domain/entities/project_summary.dart';
import 'package:site_board/feature/projectSection/domain/entities/retrieved_projects.dart';
import 'package:site_board/core/enums/sync_status.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/connection_checker.dart';
import '../../domain/repositories/project_repository.dart';
import '../dataSources/gemini_remote_data_source.dart';
import '../dataSources/project_local_data_source.dart';
import '../dataSources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource projectRemoteDataSource;
  final ProjectLocalDataSource projectLocalDataSource;
  final GeminiRemoteDataSource geminiRemoteDataSource;
  final ConnectionChecker connectionChecker;

  ProjectRepositoryImpl(
    this.projectRemoteDataSource,
    this.projectLocalDataSource,
    this.geminiRemoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, Project>> createProject({
    required Project project,
    File? coverImage,
  }) async {
    try {
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
        syncStatus: SyncStatus.created,
      );

      // Optimistic Save
      projectLocalDataSource.uploadRecentProject(project: projectModel);

      // Trigger background sync (Fire and forget)
      _syncCreatedProject(projectModel, coverImage);

      return right(projectModel);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> _syncCreatedProject(
    ProjectModel projectModel,
    File? coverImage,
  ) async {
    if (await connectionChecker.isConnected) {
      try {
        if (coverImage != null) {
          final imageUrl = await projectRemoteDataSource
              .uploadProjectCoverImage(
                image: coverImage,
                project: projectModel,
              );
          projectModel = projectModel.copyWithModel(coverPhotoUrl: imageUrl);
        }

        final uploadedProject = await projectRemoteDataSource.createProject(
          projectModel,
        );

        if (projectModel.creatorId.isNotEmpty) {
          try {
            MemberModel creatorMember = MemberModel(
              id: const Uuid().v4(),
              projectId: uploadedProject.id,
              name: "Creator",
              email: "",
              userId: uploadedProject.creatorId,
              isAccepted: true,
              isBlocked: false,
              isAdmin: true,
              hasLeft: false,
              lastViewed: DateTime.now(),
            );

            await projectRemoteDataSource.createMember(creatorMember);
          } catch (e) {
            debugPrint("Warning: Auto-member creation failed: $e");
          }
        }

        // Update local with synced status
        final syncedProject = uploadedProject.copyWithModel(
          syncStatus: SyncStatus.synced,
        );
        projectLocalDataSource.uploadRecentProject(project: syncedProject);
      } catch (e) {
        debugPrint("Background sync failed for project ${projectModel.id}: $e");
      }
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

      if (image != null) {
        final imageUrl = await projectRemoteDataSource.uploadProjectCoverImage(
          image: image,
          project: projectModel,
        );
        projectModel = projectModel.copyWithModel(coverPhotoUrl: imageUrl);
      }

      final uploadedProject = await projectRemoteDataSource.updateProject(
        projectModel,
      );
      return right(uploadedProject);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProjectModel>> getProjectById({
    required String projectId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        // Try to find in local recent projects
        final localProjects = projectLocalDataSource.loadRecentProjects();
        final localProject =
            localProjects.where((p) => p.id == projectId).firstOrNull;
        if (localProject != null) {
          return right(localProject);
        }
        return left(
          Failure(
            'Project not found locally. Connect to the internet and try again.',
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
      // Fallback to local on generic error too?
      final localProjects = projectLocalDataSource.loadRecentProjects();
      final localProject =
          localProjects.where((p) => p.id == projectId).firstOrNull;
      if (localProject != null) {
        return right(localProject);
      }
      return left(Failure(e.toString()));
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
      DailyLogModel dailyLogModel = DailyLogModel(
        id: dailyLog.id,
        projectId: dailyLog.projectId,
        dateTimeList: dailyLog.dateTimeList,
        numberOfWorkers: dailyLog.numberOfWorkers,
        weatherCondition: dailyLog.weatherCondition,
        materialsAvailable: dailyLog.materialsAvailable,
        plannedTasks: taskConverter(dailyLog.plannedTasks),
        startingImageUrl: dailyLog.startingImageUrl, // Initially empty/local
        endingImageUrl: dailyLog.endingImageUrl,
        observations: dailyLog.observations,
        isConfirmed: dailyLog.isConfirmed,
        workScore: dailyLog.workScore,
        generatedSummary: dailyLog.generatedSummary,
        syncStatus: SyncStatus.created,
      );

      if (!await (connectionChecker.isConnected)) {
        // Offline Creation
        // 1. Get Local Project
        final localProjects = projectLocalDataSource.loadRecentProjects();
        final localProject =
            localProjects.where((p) => p.id == projectId).firstOrNull;

        if (localProject == null) {
          return left(Failure("Project not found locally. Cannot create log."));
        }

        // 2. Handle Images (Keep local paths)
        final localImagePaths =
            startingTaskImageList.map((file) => file?.path ?? '').toList();

        dailyLogModel = dailyLogModel.copyWithModel(
          startingImageUrl: localImagePaths,
        );

        // 3. Update Project Logs
        // We need to append this log to the project's list.
        final updatedLogs = List<DailyLogModel>.from(localProject.dailyLogs)
          ..add(dailyLogModel);

        final updatedProject = localProject.copyWithModel(
          dailyLogs: updatedLogs,
        );

        // 4. Save Project
        projectLocalDataSource.uploadRecentProject(project: updatedProject);

        // 5. Return Success
        return right(dailyLogModel.copyWith(plannedTasks: currentTasks));
      }

      // Online Flow
      final modifiedStartingImageUrlList = await projectRemoteDataSource
          .uploadDailyLogImages(
            isEndingImages: false,
            images: startingTaskImageList,
            dailyLogModel: dailyLogModel,
          );

      dailyLogModel = DailyLogModel(
        id: dailyLogModel.id,
        projectId: dailyLogModel.projectId,
        dateTimeList: dailyLogModel.dateTimeList,
        numberOfWorkers: dailyLogModel.numberOfWorkers,
        weatherCondition: dailyLogModel.weatherCondition,
        materialsAvailable: dailyLogModel.materialsAvailable,
        plannedTasks: dailyLogModel.plannedTasks,
        startingImageUrl: imageModifier(
          dailyLog.startingImageUrl,
          modifiedStartingImageUrlList,
        ),
        endingImageUrl: dailyLogModel.endingImageUrl,
        observations: dailyLogModel.observations,
        isConfirmed: dailyLogModel.isConfirmed,
        workScore: dailyLogModel.workScore,
        generatedSummary: dailyLogModel.generatedSummary,
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
    } catch (e) {
      return left(Failure(e.toString()));
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
      DailyLogModel dailyLogModel = DailyLogModel(
        id: dailyLog.id,
        projectId: dailyLog.projectId,
        dateTimeList: dailyLog.dateTimeList,
        numberOfWorkers: dailyLog.numberOfWorkers,
        weatherCondition: dailyLog.weatherCondition,
        materialsAvailable: dailyLog.materialsAvailable,
        plannedTasks: taskConverter(dailyLog.plannedTasks),
        startingImageUrl: dailyLog.startingImageUrl,
        endingImageUrl: dailyLog.endingImageUrl,
        observations: dailyLog.observations,
        isConfirmed: dailyLog.isConfirmed,
        workScore: dailyLog.workScore,
        generatedSummary: dailyLog.generatedSummary,
      );

      if (!await (connectionChecker.isConnected)) {
        // Offline Update
        final localProjects = projectLocalDataSource.loadRecentProjects();
        final localProject =
            localProjects.where((p) => p.id == projectId).firstOrNull;

        if (localProject == null) {
          return left(Failure("Project not found locally. Cannot update log."));
        }

        // Handle offline images for update
        List<String> updatedStartingImages = dailyLogModel.startingImageUrl;
        if (hasAtLeastOneFile(startingTaskImageList)) {
          updatedStartingImages = imageModifier(
            dailyLogModel.startingImageUrl,
            startingTaskImageList.map((f) => f?.path ?? '').toList(),
          );
        }

        List<String> updatedEndingImages = dailyLogModel.endingImageUrl;
        if (hasAtLeastOneFile(endingTaskImageList)) {
          updatedEndingImages = imageModifier(
            dailyLogModel.endingImageUrl,
            endingTaskImageList.map((f) => f?.path ?? '').toList(),
          );
        }

        dailyLogModel = dailyLogModel.copyWithModel(
          startingImageUrl: updatedStartingImages,
          endingImageUrl: updatedEndingImages,
          // Ensure plannedTasks are updated too in case they changed
          plannedTasks: taskConverter(currentTasks),
        );

        // Replace the log in the list
        final updatedLogs =
            localProject.dailyLogs.map((log) {
              return log.id == dailyLog.id ? dailyLogModel : log;
            }).toList();

        // Cast strictly to ensure type safety if needed, but map returns Iterable.
        final List<DailyLogModel> strictLogs = [];
        for (var l in updatedLogs) {
          if (l is DailyLogModel) {
            strictLogs.add(l);
          } else {
            // Convert entity to model if needed (assumed logic)
            strictLogs.add(
              DailyLogModel(
                id: l.id,
                projectId: l.projectId,
                dateTimeList: l.dateTimeList,
                numberOfWorkers: l.numberOfWorkers,
                weatherCondition: l.weatherCondition,
                materialsAvailable: l.materialsAvailable,
                plannedTasks: l.plannedTasks,
                startingImageUrl: l.startingImageUrl,
                endingImageUrl: l.endingImageUrl,
                observations: l.observations,
                isConfirmed: l.isConfirmed,
              ),
            );
          }
        }

        final updatedProject = localProject.copyWithModel(
          dailyLogs: strictLogs,
        );
        projectLocalDataSource.uploadRecentProject(project: updatedProject);

        return right(dailyLogModel.copyWith(plannedTasks: currentTasks));
      }

      // Online Flow
      if (hasAtLeastOneFile(startingTaskImageList)) {
        final modifiedStartingImageUrlList = await projectRemoteDataSource
            .uploadDailyLogImages(
              isEndingImages: false,
              images: startingTaskImageList,
              dailyLogModel: dailyLogModel,
            );

        dailyLogModel = DailyLogModel(
          id: dailyLogModel.id,
          projectId: dailyLogModel.projectId,
          dateTimeList: dailyLogModel.dateTimeList,
          numberOfWorkers: dailyLogModel.numberOfWorkers,
          weatherCondition: dailyLogModel.weatherCondition,
          materialsAvailable: dailyLogModel.materialsAvailable,
          plannedTasks: dailyLogModel.plannedTasks,
          startingImageUrl: imageModifier(
            dailyLog.startingImageUrl,
            modifiedStartingImageUrlList,
          ),
          endingImageUrl: dailyLogModel.endingImageUrl,
          observations: dailyLogModel.observations,
          isConfirmed: dailyLogModel.isConfirmed,
          workScore: dailyLogModel.workScore,
          generatedSummary: dailyLogModel.generatedSummary,
        );
      }

      if (hasAtLeastOneFile(endingTaskImageList)) {
        final modifiedEndingTaskImageUrlList = await projectRemoteDataSource
            .uploadDailyLogImages(
              isEndingImages: true,
              images: endingTaskImageList,
              dailyLogModel: dailyLogModel,
            );

        dailyLogModel = DailyLogModel(
          id: dailyLogModel.id,
          projectId: dailyLogModel.projectId,
          dateTimeList: dailyLogModel.dateTimeList,
          numberOfWorkers: dailyLogModel.numberOfWorkers,
          weatherCondition: dailyLogModel.weatherCondition,
          materialsAvailable: dailyLogModel.materialsAvailable,
          plannedTasks: dailyLogModel.plannedTasks,
          startingImageUrl: dailyLogModel.startingImageUrl,
          endingImageUrl: imageModifier(
            dailyLog.endingImageUrl,
            modifiedEndingTaskImageUrlList,
          ),
          observations: dailyLogModel.observations,
          isConfirmed: dailyLogModel.isConfirmed,
          workScore: dailyLogModel.workScore,
          generatedSummary: dailyLogModel.generatedSummary,
        );
      }

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

  @override
  Future<Either<Failure, ProjectSummary>> generateProjectSummary({
    required String promptText,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
          Failure(
            'AI generation requires an internet connection. Please connect and try again.',
          ),
        );
      }
      final summary = await geminiRemoteDataSource.generateSummary(
        promptText: promptText,
      );
      return right(summary);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await projectRemoteDataSource.deleteProject(projectId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveProject(
    String projectId,
    String userId,
  ) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await projectRemoteDataSource.leaveProject(projectId, userId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDailyLog(String dailyLogId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await projectRemoteDataSource.deleteDailyLog(dailyLogId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<void> syncPendingProject(Project project) async {
    // We cast to ProjectModel to use the internal method, or refactor _sync to take entity
    if (project is ProjectModel) {
      if (project.syncStatus == SyncStatus.created) {
        // We assume coverImage is handled separately or null for sync retry for now,
        // unless we store the image path locally.
        // For simplicity, we sync the data.
        // TODO: Handle offline image persistence for retry.
        await _syncCreatedProject(project, null);
      }
    }
  }

  @override
  Future<void> syncPendingLogs() async {
    if (!await connectionChecker.isConnected) return;

    final localProjects = projectLocalDataSource.loadRecentProjects();
    for (var project in localProjects) {
      final pendingLogs = project.dailyLogs.where(
        (log) => log.syncStatus == SyncStatus.created,
      );

      for (var log in pendingLogs) {
        // Find current tasks?
        // We need 'currentTasks' to call createDailyLog/updateDailyLog properly,
        // but wait, createDailyLog takes 'currentTasks'.
        // If we just sync the log object...
        // The log object has 'plannedTasks' which IS the tasks.
        // We use that.
        // Also images? Offline images are local paths.
        // We need to upload them.

        try {
          if (log is DailyLogModel) {
            final images =
                log.startingImageUrl
                    .map((path) => path.isEmpty ? null : File(path))
                    .toList();
            // TODO: handle ending images if any

            // Call _syncCreatedLog (we need to extract logic from createDailyLog)
            // Or just call createDailyLog?
            // createDailyLog includes adding to local. We already have it local.
            // We just need the "Online Flow" from createDailyLog.

            // Refactoring createDailyLog to expose _syncCreatedLog would be best.
            // But for now, let's implement the sync logic here.

            final modifiedStartingImageUrlList = await projectRemoteDataSource
                .uploadDailyLogImages(
                  isEndingImages: false,
                  images: images,
                  dailyLogModel: log,
                );

            final syncedStartingImages = imageModifier(
              log.startingImageUrl,
              modifiedStartingImageUrlList,
            );

            // Handle ending images
            final endingImages =
                log.endingImageUrl
                    .map((path) => path.isEmpty ? null : File(path))
                    .toList();

            final modifiedEndingImageUrlList = await projectRemoteDataSource
                .uploadDailyLogImages(
                  isEndingImages: true,
                  images: endingImages,
                  dailyLogModel: log,
                );

            final syncedEndingImages = imageModifier(
              log.endingImageUrl,
              modifiedEndingImageUrlList,
            );

            final syncedLog = log.copyWithModel(
              startingImageUrl: syncedStartingImages,
              endingImageUrl: syncedEndingImages,
              syncStatus: SyncStatus.synced,
            );

            await projectRemoteDataSource.createDailyLog(syncedLog);

            // Sync tasks
            // log.plannedTasks are LogTask/Model
            final tasksModel = taskConverter(log.plannedTasks);
            await projectRemoteDataSource.syncLogTasks(
              dailyLogId: log.id,
              currentTasks: tasksModel,
            );

            // Update local project with synced log
            await _updateLocalLogStatus(project.id, log.id, SyncStatus.synced);
          }
        } catch (e) {
          debugPrint("Failed to sync log ${log.id}: $e");
        }
      }
    }
  }

  Future<void> _updateLocalLogStatus(
    String projectId,
    String logId,
    SyncStatus status,
  ) async {
    // Reload recent projects to ensure thread-safety-ish behavior
    final localProjects = projectLocalDataSource.loadRecentProjects();
    final project = localProjects.where((p) => p.id == projectId).firstOrNull;

    if (project != null) {
      final updatedLogs =
          project.dailyLogs.map((l) {
            if (l.id == logId && l is DailyLogModel) {
              return l.copyWithModel(syncStatus: status);
            }
            return l;
          }).toList();

      final List<DailyLogModel> strictLogs = [];
      for (var l in updatedLogs) {
        if (l is DailyLogModel) {
          strictLogs.add(l);
        } else {
          // Conversion fallback if somehow non-model got in
          strictLogs.add(
            DailyLogModel(
              id: l.id,
              projectId: l.projectId,
              dateTimeList: l.dateTimeList,
              numberOfWorkers: l.numberOfWorkers,
              weatherCondition: l.weatherCondition,
              materialsAvailable: l.materialsAvailable,
              plannedTasks: l.plannedTasks,
              startingImageUrl: l.startingImageUrl,
              endingImageUrl: l.endingImageUrl,
              observations: l.observations,
              isConfirmed: l.isConfirmed,
              workScore: l.workScore,
              generatedSummary: l.generatedSummary,
              syncStatus: l.syncStatus,
            ),
          );
        }
      }

      projectLocalDataSource.uploadRecentProject(
        project: project.copyWithModel(dailyLogs: strictLogs),
      );
    }
  }

  @override
  Stream<int> getUnsyncedCount() {
    return projectLocalDataSource.getUnsyncedCountStream();
  }

  @override
  Future<void> deleteLocalProject(String projectId) async {
    projectLocalDataSource.deleteProject(projectId);
  }

  @override
  Future<List<Project>> getPendingProjects() async {
    return projectLocalDataSource.getProjectsByStatus(SyncStatus.created);
  }

  @override
  Future<List<DailyLog>> getPendingDailyLogs() async {
    final localProjects = projectLocalDataSource.loadRecentProjects();
    List<DailyLog> pendingLogs = [];

    for (var project in localProjects) {
      final logs = project.dailyLogs.where(
        (log) => log.syncStatus == SyncStatus.created,
      );
      pendingLogs.addAll(logs);
    }
    return pendingLogs;
  }

  @override
  Future<void> deleteLocalDailyLog(String logId) async {
    final localProjects = projectLocalDataSource.loadRecentProjects();
    bool projectModified = false;
    late ProjectModel targetProject;

    // Find the project containing the log
    for (var project in localProjects) {
      final exists = project.dailyLogs.any((log) => log.id == logId);
      if (exists) {
        targetProject = project;
        projectModified = true;
        break;
      }
    }

    if (projectModified) {
      final updatedLogs =
          targetProject.dailyLogs.where((log) => log.id != logId).toList();

      // Strict cast to maintain type integrity
      final List<DailyLogModel> strictLogs = [];
      for (var l in updatedLogs) {
        if (l is DailyLogModel) {
          strictLogs.add(l);
        } else {
          // Fallback conversion
          strictLogs.add(logConverter([l]).first);
        }
      }

      final updatedProject = targetProject.copyWithModel(dailyLogs: strictLogs);
      projectLocalDataSource.uploadRecentProject(project: updatedProject);
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
          syncStatus: dLog.syncStatus,
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
    List<String> updatedStartingList = List.from(currentImageUrls);

    for (int index = 0; index < newImageUrls.length; index++) {
      final selectedUrl = newImageUrls[index];
      if (selectedUrl != '') {
        updatedStartingList[index] = selectedUrl;
      }
    }
    return updatedStartingList;
  }

  @override
  Future<Either<Failure, Member>> createMember({
    required String projectId,
    required Member member,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      // Convert Member to MemberModel
      final memberModel = MemberModel(
        id: member.id,
        projectId: projectId,
        name: member.name,
        email: member.email,
        userId: member.userId,
        isAccepted: member.isAccepted,
        isBlocked: member.isBlocked,
        isAdmin: member.isAdmin,
        hasLeft: member.hasLeft,
        lastViewed: member.lastViewed,
      );
      final result = await projectRemoteDataSource.createMember(memberModel);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Member>> updateMember({
    required String projectId,
    required Member member,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final memberModel = MemberModel(
        id: member.id,
        projectId: projectId,
        name: member.name,
        email: member.email,
        userId: member.userId,
        isAccepted: member.isAccepted,
        isBlocked: member.isBlocked,
        isAdmin: member.isAdmin,
        hasLeft: member.hasLeft,
        lastViewed: member.lastViewed,
      );
      final result = await projectRemoteDataSource.updateMember(memberModel);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogTask>>> manageLogTasks({
    required String dailyLogId,
    required List<LogTask> currentTasks,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        // Offline: Update local log task list?
        // For now, fail if not connected, or implement local update implies log update.
        // Since manageLogTasks is often standalone, we might want to defer.
        // But user can update LOG via updateDailyLog which handles tasks.
        // This method might be specific for checkbox toggles.
        // Let's return error for now or fallback to local log update?
        // Simpler to return failure if strictly online, but for offline support we should handle it.
        // Let's implement local update logic.
        return left(
          Failure(
            "Offline task management not fully implemented yet. Use Update Log.",
          ),
        );
      }

      final tasksModel = taskConverter(currentTasks);
      await projectRemoteDataSource.syncLogTasks(
        dailyLogId: dailyLogId,
        currentTasks: tasksModel,
      );
      return right(currentTasks);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RetrievedProjects>> getAllProjects({
    required String userId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        final localProjects = projectLocalDataSource.loadRecentProjects();
        return right(
          RetrievedProjects(
            projects: List<Project>.from(localProjects),
            isLocal: true,
          ),
        );
      }
      final result = await projectRemoteDataSource.getAllProjects(
        userId: userId,
      );
      return right(
        RetrievedProjects(projects: List<Project>.from(result), isLocal: false),
      );
    } on ServerException catch (e) {
      // Fallback to local
      final localProjects = projectLocalDataSource.loadRecentProjects();
      if (localProjects.isNotEmpty) {
        return right(
          RetrievedProjects(
            projects: List<Project>.from(localProjects),
            isLocal: true,
          ),
        );
      }
      return left(Failure(e.message));
    } catch (e) {
      final localProjects = projectLocalDataSource.loadRecentProjects();
      if (localProjects.isNotEmpty) {
        return right(
          RetrievedProjects(
            projects: List<Project>.from(localProjects),
            isLocal: true,
          ),
        );
      }
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getRecentProjects() async {
    try {
      final projects = projectLocalDataSource.loadRecentProjects();
      return right(projects);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addRecentProject({
    required Project project,
  }) async {
    try {
      ProjectModel projectModel;
      if (project is ProjectModel) {
        projectModel = project;
      } else {
        projectModel = ProjectModel(
          id: project.id,
          projectName: project.projectName,
          creatorId: project.creatorId,
          projectLink: project.projectLink,
          description: project.description,
          teamAdminIds: project.teamAdminIds,
          teamMembers: project.teamMembers,
          createdDate: project.createdDate,
          endDate: project.endDate,
          dailyLogs:
              project.dailyLogs
                  .map(
                    (log) => DailyLogModel(
                      id: log.id,
                      projectId: log.projectId,
                      dateTimeList: log.dateTimeList,
                      numberOfWorkers: log.numberOfWorkers,
                      weatherCondition: log.weatherCondition,
                      materialsAvailable: log.materialsAvailable,
                      plannedTasks: taskConverter(log.plannedTasks),
                      startingImageUrl: log.startingImageUrl,
                      endingImageUrl: log.endingImageUrl,
                      observations: log.observations,
                      isConfirmed: log.isConfirmed,
                      workScore: log.workScore,
                      generatedSummary: log.generatedSummary,
                    ),
                  )
                  .toList(),
          location: project.location,
          isActive: project.isActive,
          lastUpdated: DateTime.now(),
          coverPhotoUrl: project.coverPhotoUrl,
          projectSecurityType: project.projectSecurityType,
          projectPassword: project.projectPassword,
          syncStatus: project.syncStatus,
        );
      }
      projectLocalDataSource.uploadRecentProject(project: projectModel);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  bool hasAtLeastOneFile(List<File?> files) {
    if (files.isEmpty) return false;
    return files.any((file) => file != null);
  }
}
