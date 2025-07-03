import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/manage_log_task.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_project.dart';

import '../../domain/entities/daily_log.dart';
import '../../domain/entities/project.dart';
import '../../domain/useCases/get_all_projects.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetAllProjects _getAllProjects;
  final CreateProject _createProject;
  final UpdateProject _updateProject;
  final CreateDailyLog _createDailyLog;
  final UpdateDailyLog _updateDailyLog;
  final ManageLogTask _manageLogTask;

  ProjectBloc({
    required GetAllProjects getAllProjects,
    required CreateProject createProject,
    required UpdateProject updateProject,
    required CreateDailyLog createDailyLog,
    required UpdateDailyLog updateDailyLog,
    required ManageLogTask manageLogTask,
  }) : _createProject = createProject,
       _updateProject = updateProject,
       _createDailyLog = createDailyLog,
       _updateDailyLog = updateDailyLog,
       _manageLogTask = manageLogTask,
       _getAllProjects = getAllProjects,
       super(ProjectInitial()) {
    //on<ProjectEvent>((event, emit) => emit(ProjectLoading()));
    on<ProjectCreate>(_onProjectCreate);
    on<ProjectUpdate>(_onProjectUpdate);
    on<DailyLogCreate>(_onDailyLogCreate);
    on<DailyLogUpdate>(_onDailyLogUpdate);
    on<ManageCurrentLogTask>(_onManageLogTask);
    on<ProjectGetAllProjects>(_onGetAllProjects);
  }

  bool isLocalMode = false;

  void _onProjectCreate(ProjectCreate event, Emitter<ProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _createProject(
        CreateProjectParams(project: event.project),
      );
      response.fold(
        (l) {
          emit(ProjectFailure(l.message));
          emit(ProjectRetrieveSuccess(currentState.projects));
        },
        (r) {
          // Replace updated project in list
          final updatedProjects =
              currentState.projects.map((p) {
                return p.id == event.project.id ? event.project : p;
              }).toList();
          emit(ProjectRetrieveSuccess(updatedProjects));
        },
      );
    }
  }

  void _onProjectUpdate(ProjectUpdate event, Emitter<ProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _updateProject(
        UpdateProjectParams(project: event.project, image: event.coverImage),
      );
      response.fold(
        (l) {
          emit(ProjectFailure(l.message));
          emit(ProjectRetrieveSuccess(currentState.projects));
        },
        (r) {
          // Replace updated project in list
          final updatedProjects =
              currentState.projects.map((p) {
                return p.id == event.project.id ? event.project : p;
              }).toList();
          emit(ProjectRetrieveSuccess(updatedProjects));
        },
      );
    }
  }

  void _onDailyLogCreate(
    DailyLogCreate event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _createDailyLog(
        CreateDailyLogParams(
          projectId: event.projectId,
          dailyLog: event.dailyLog,
          isCurrentTaskModified: event.isCurrentTaskModified,
          currentTasks: event.currentTasks,
          startingTaskImageList: event.startingTaskImageList,
        ),
      );

      response.fold(
        (l) {
          emit(
            DailyLogUploadFailure(
              error: l.message,
              projects: currentState.projects,
            ),
          );
          //emit(ProjectRetrieveSuccess(currentState.projects));
        },
        (r) {
          final updatedProjects =
              currentState.projects.map((project) {
                if (project.id == event.projectId) {
                  /*final updatedLogs = [
                  ...project.dailyLogs.where(
                    (log) => log.id != event.dailyLog.id,
                  ),
                  event.dailyLog,
                ];*/
                  final updatedLogs = [...project.dailyLogs, event.dailyLog];
                  return project.copyWith(dailyLogs: updatedLogs);
                }
                return project;
              }).toList();

          emit(DailyLogUploadSuccess(updatedProjects));
        },
      );
    }
  }

  void _onDailyLogUpdate(
    DailyLogUpdate event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _updateDailyLog(
        UpdateDailyLogParams(
          projectId: event.projectId,
          dailyLog: event.dailyLog,
          isCurrentTaskModified: event.isCurrentTaskModified,
          currentTasks: event.currentTasks,
          startingTaskImageList: event.startingTaskImageList,
          endingTaskImageList: event.endingTaskImageList,
        ),
      );

      response.fold(
        (l) {
          emit(
            DailyLogUploadFailure(
              error: l.message,
              projects: currentState.projects,
            ),
          );
          //Changed so that when second click of upload, it still shows popup
          //emit(ProjectRetrieveSuccess(currentState.projects));
        },
        (r) {
          final updatedProjects =
              currentState.projects.map((project) {
                if (project.id == event.projectId) {
                  final updatedLogs =
                      project.dailyLogs.map((log) {
                        return log.id == event.dailyLog.id
                            ? event.dailyLog
                            : log;
                      }).toList();

                  return project.copyWith(dailyLogs: updatedLogs);
                }
                return project;
              }).toList();

          emit(DailyLogUploadSuccess(updatedProjects));
        },
      );
    }
  }

  void _onManageLogTask(
    ManageCurrentLogTask event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _manageLogTask(
        ManageLogTaskParams(
          dailyLogId: event.dailyLogId,
          currentTasks: event.currentTasks,
        ),
      );

      response.fold(
        (l) {
          emit(
            DailyLogUploadFailure(
              error: l.message,
              projects: currentState.projects,
            ),
          );
          //emit(ProjectRetrieveSuccess(currentState.projects));
        },
        (r) {
          final updatedProjects =
              currentState.projects.map((project) {
                final updatedLogs =
                    project.dailyLogs.map((log) {
                      if (log.id == event.dailyLogId) {
                        return log.copyWith(plannedTasks: event.currentTasks);
                      }
                      return log;
                    }).toList();

                return project.copyWith(dailyLogs: updatedLogs);
              }).toList();

          emit(DailyLogUploadSuccess(updatedProjects));
        },
      );
    }
  }

  void _onGetAllProjects(
    ProjectGetAllProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    final response = await _getAllProjects(
      GetAllProjectsParams(userId: event.userId),
    );
    response.fold((l) => emit(ProjectFailure(l.message)), (r) {
      isLocalMode = r.isLocal;
      emit(
        ProjectRetrieveSuccessInit(projects: r.projects, isLocal: r.isLocal),
      );
    });
  }
}

//TODO - Switch to Offline mode button that allows user once you launch the app and there is error to choose to use the offline mode.
//TODO - Switch to online mode on home that allows user to keep trying to retrieve data.
