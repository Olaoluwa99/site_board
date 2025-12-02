import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/usecases/usecase.dart';
import 'package:site_board/feature/projectSection/domain/useCases/add_recent_project.dart';
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
  final AddRecentProject _addRecentProject;

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
    required AddRecentProject addRecentProject,
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
        _addRecentProject = addRecentProject,
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
    on<ProjectAddToRecent>(_onAddRecentProject);
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
            // If ID matches (shouldn't happen on create but checking)
            return project.id == event.project.id ? event.project : project;
          }).toList();

          // Add the new project to the list if not present
          if(!updatedProjects.any((p) => p.id == r.id)) {
            updatedProjects.add(r);
          }
          outputProject = r;

          emit(
            ProjectCreateSuccess(
              projects: updatedProjects,
              project: outputProject!,
            ),
          );
        },
      );
    } else {
      // If state wasn't loaded, just emit create success
      emit(ProjectLoading());
      final response = await _createProject(CreateProjectParams(project: event.project));
      response.fold(
              (l) => emit(ProjectFailure(l.message)),
              (r) => emit(ProjectCreateSuccess(projects: [r], project: r))
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
        },
            (r) {
          final updatedProjects =
          currentState.projects.map((project) {
            if (project.id == event.projectId) {
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
          projectId: event.project.id,
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
          Project outputProject = event.project;

          // Rebuild member list with updated/new member
          final updatedMembers = [
            for (final m in outputProject.teamMembers)
              if (m.userId != event.member.userId) m, // Filter out old instance of this user
            event.member, // Add new instance
          ];

          // FIX ISSUE B: Assign the copyWith result back to outputProject
          outputProject = outputProject.copyWith(teamMembers: updatedMembers);

          emit(
            ProjectMemberUpdateSuccess(
              projects: updateProjectInList(
                currentState.projects,
                outputProject,
              ),
              project: outputProject,
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
    // Allow retrieving even if current state is just recent projects
    List<Project> currentProjects = [];
    if (currentState is ProjectRetrieveSuccess) {
      currentProjects = currentState.projects;
    }

    if (!isLocalMode) {
      emit(ProjectLoading());
      final response = await _getProjectById(
        GetProjectByIdParams(projectId: event.project.id),
      );
      response.fold(
            (l) => emit(
          ProjectRetrieveByIdFailure(
            error: l.message,
            projects: currentProjects,
            oldProject: event.project,
          ),
        ),
            (retrievedProject) {
          // If the project exists in the list, replace it. If not, add it.
          List<Project> updatedProjects;
          if (currentProjects.any((p) => p.id == retrievedProject.id)) {
            updatedProjects = currentProjects.map((p) {
              return p.id == event.project.id ? retrievedProject : p;
            }).toList();
          } else {
            updatedProjects = [...currentProjects, retrievedProject];
          }

          emit(
            ProjectRetrieveSuccessId(
              projects: updatedProjects,
              project: retrievedProject,
            ),
          );
        },
      );
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
    List<Project> currentProjects = [];
    if (currentState is ProjectRetrieveSuccess) {
      currentProjects = currentState.projects;
    }

    if (!isLocalMode) {
      emit(ProjectLoading());
      final response = await _getProjectByLink(
        GetProjectByLinkParams(projectLink: event.projectLink),
      );
      response.fold(
            (l) => emit(
          ProjectRetrieveByLinkFailure(
            error: l.message,
            projects: currentProjects,
          ),
        ),
            (retrievedProject) {
          List<Project> updatedProjects;
          if (currentProjects.any((p) => p.id == retrievedProject.id)) {
            updatedProjects = currentProjects.map((p) {
              return p.id == retrievedProject.id ? retrievedProject : p;
            }).toList();
          } else {
            updatedProjects = [...currentProjects, retrievedProject];
          }
          emit(
            ProjectRetrieveSuccessLink(
              projects: updatedProjects,
              project: retrievedProject,
            ),
          );
        },
      );
    } else {
      emit(
        ProjectFailure('To retrieve a project by Link, switch to Normal Mode.'),
      );
    }
  }

  void _onAddRecentProject(
      ProjectAddToRecent event,
      Emitter<ProjectState> emit,
      ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      //emit(ProjectLoading()); // Optional: loading might flicker UI too much here
      await _addRecentProject(AddToRecentParams(project: event.project));

      emit(
        ProjectRetrieveAddRecent(
          project: event.project,
          projects: currentState.projects,
        ),
      );
    }
  }

  List<Project> updateProjectInList(List<Project> projects, Project updated) {
    // Helper to safely update project in list
    if (projects.isEmpty) return [updated];
    if (projects.any((p) => p.id == updated.id)) {
      return projects.map((p) => p.id == updated.id ? updated : p).toList();
    }
    return [...projects, updated];
  }
}