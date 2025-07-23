import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/usecases/usecase.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_project_by_id.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_project_by_link.dart';
import 'package:site_board/feature/projectSection/domain/useCases/manage_log_task.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_project.dart';

import '../../domain/entities/Member.dart';
import '../../domain/entities/daily_log.dart';
import '../../domain/entities/project.dart';
import '../../domain/useCases/get_all_projects.dart';
import '../../domain/useCases/get_recent_projects.dart';
import '../../domain/useCases/update_member.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetAllProjects _getAllProjects;
  final GetRecentProjects _getRecentProjects;
  final CreateProject _createProject;
  final UpdateProject _updateProject;
  final CreateDailyLog _createDailyLog;
  final UpdateDailyLog _updateDailyLog;
  final ManageLogTask _manageLogTask;
  final GetProjectByLink _getProjectByLink;
  final GetProjectById _getProjectById;
  final UpdateMember _updateMember;

  ProjectBloc({
    required GetAllProjects getAllProjects,
    required GetRecentProjects getRecentProjects,
    required CreateProject createProject,
    required UpdateProject updateProject,
    required CreateDailyLog createDailyLog,
    required UpdateDailyLog updateDailyLog,
    required ManageLogTask manageLogTask,
    required GetProjectById getProjectById,
    required GetProjectByLink getProjectByLink,
    required UpdateMember updateMember,
  }) : _createProject = createProject,
       _updateProject = updateProject,
       _createDailyLog = createDailyLog,
       _updateDailyLog = updateDailyLog,
       _manageLogTask = manageLogTask,
       _getAllProjects = getAllProjects,
       _getRecentProjects = getRecentProjects,
       _getProjectById = getProjectById,
       _getProjectByLink = getProjectByLink,
       _updateMember = updateMember,
       super(ProjectInitial()) {
    //on<ProjectEvent>((event, emit) => emit(ProjectLoading()));
    on<ProjectCreate>(_onProjectCreate);
    on<ProjectUpdate>(_onProjectUpdate);
    on<DailyLogCreate>(_onDailyLogCreate);
    on<DailyLogUpdate>(_onDailyLogUpdate);
    on<ManageCurrentLogTask>(_onManageLogTask);
    on<ProjectGetAllProjects>(_onGetAllProjects);
    on<ProjectGetRecentProjects>(_onGetRecentProjects);
    on<ProjectGetProjectById>(_onGetProjectById);
    on<ProjectGetProjectByLink>(_onGetProjectByLink);
    on<UpdateMemberEvent>(_onUpdateMember);
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
          Project? outputProject;
          final updatedProjects =
              currentState.projects.map((project) {
                outputProject = project;
                return project.id == event.project.id ? event.project : project;
              }).toList();
          emit(
            ProjectCreateSuccess(
              projects: updatedProjects,
              project: outputProject!,
            ),
          );
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

  void _onUpdateMember(
    UpdateMemberEvent event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _updateMember(
        UpdateMemberParams(
          projectId: event.projectId,
          member: event.member,
          isCreateMember: event.isCreateMember,
        ),
      );

      response.fold(
        (l) {
          emit(
            ProjectMemberUpdateFailure(
              error: l.message,
              projects: currentState.projects,
            ),
          );
        },
        (r) {
          Project? outputProject;
          final updatedProjects =
              currentState.projects.map((project) {
                if (project.id == event.projectId) {
                  final updatedMembers = [...project.teamMembers, event.member];
                  outputProject = project.copyWith(teamMembers: updatedMembers);
                  return outputProject!;
                }
                return project;
              }).toList();

          emit(
            ProjectMemberUpdateSuccess(
              projects: updatedProjects,
              project: outputProject!,
              member: event.member,
            ),
          );
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

  void _onGetRecentProjects(
    ProjectGetRecentProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    final response = await _getRecentProjects(NoParams());
    response.fold((l) => emit(ProjectFailure(l.message)), (r) {
      emit(ProjectRetrieveRecentSuccess(projects: r));
    });
  }

  void _onGetProjectById(
    ProjectGetProjectById event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess && !isLocalMode) {
      emit(ProjectLoading());
      final response = await _getProjectById(
        GetProjectByIdParams(projectId: event.projectId),
      );
      response.fold((l) => emit(ProjectFailure(l.message)), (retrievedProject) {
        final updatedProjects =
            currentState.projects.map((p) {
              return p.id == event.projectId ? retrievedProject : p;
            }).toList();
        emit(
          ProjectRetrieveSuccessSingle(
            projects: updatedProjects,
            project: retrievedProject,
          ),
        );
      });
    } else {
      emit(
        ProjectFailure('To retrieve a project by ID, switch to Normal Mode.'),
      );
    }
  }

  void _onGetProjectByLink(
    ProjectGetProjectByLink event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess && !isLocalMode) {
      emit(ProjectLoading());
      final response = await _getProjectByLink(
        GetProjectByLinkParams(projectLink: event.projectLink),
      );
      response.fold((l) => emit(ProjectFailure(l.message)), (retrievedProject) {
        final updatedProjects =
            currentState.projects.map((p) {
              return p.projectLink == event.projectLink ? retrievedProject : p;
            }).toList();
        emit(
          ProjectRetrieveSuccessSingle(
            projects: updatedProjects,
            project: retrievedProject,
          ),
        );
      });
    } else {
      emit(
        ProjectFailure('To retrieve a project by Link, switch to Normal Mode.'),
      );
    }
  }
}

//TODO - Switch to Offline mode button that allows user once you launch the app and there is error to choose to use the offline mode.
//TODO - Switch to online mode on home that allows user to keep trying to retrieve data.
