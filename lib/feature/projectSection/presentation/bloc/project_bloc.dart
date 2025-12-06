import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/usecases/usecase.dart';
import 'package:site_board/feature/projectSection/domain/useCases/add_recent_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/delete_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_project_by_id.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_project_by_link.dart';
import 'package:site_board/feature/projectSection/domain/useCases/leave_project.dart';
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
  final DeleteProject _deleteProject;
  final LeaveProject _leaveProject;

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
    required DeleteProject deleteProject,
    required LeaveProject leaveProject,
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
        _deleteProject = deleteProject,
        _leaveProject = leaveProject,
        super(ProjectInitial()) {
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
    on<ProjectDeleteEvent>(_onDeleteProject);
    on<ProjectLeaveEvent>(_onLeaveProject);
  }

  bool isLocalMode = false;

  void _onProjectCreate(ProjectCreate event, Emitter<ProjectState> emit) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _createProject(
        CreateProjectParams(project: event.project),
      );
      response.fold((l) {
        emit(ProjectFailure(l.message));
        emit(ProjectRetrieveSuccess(currentState.projects));
      }, (r) {
        // Refetch project to get full details (like auto-created member)
        add(ProjectGetProjectById(project: r));
      });
    } else {
      emit(ProjectLoading());
      final response = await _createProject(
        CreateProjectParams(project: event.project),
      );
      response.fold(
            (l) => emit(ProjectFailure(l.message)),
            (r) => emit(ProjectCreateSuccess(projects: [r], project: r)),
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
      response.fold((l) {
        emit(ProjectFailure(l.message));
        emit(ProjectRetrieveSuccess(currentState.projects));
      }, (r) async {
        // Refetch to ensure data consistency
        await _refetchProject(r.id, emit, currentState.projects);
      });
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

      response.fold((l) {
        emit(
          DailyLogUploadFailure(
            error: l.message,
            projects: currentState.projects,
          ),
        );
      }, (r) async {
        // After log creation, refetch the project to get the updated logs properly structured from backend
        final fetchResult = await _getProjectById(
          GetProjectByIdParams(projectId: event.projectId),
        );
        fetchResult.fold(
              (l) => emit(DailyLogUploadSuccess(currentState.projects)),
              (freshProject) {
            emit(
              DailyLogUploadSuccess(
                updateProjectInList(currentState.projects, freshProject),
              ),
            );
          },
        );
      });
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

      response.fold((l) {
        emit(
          DailyLogUploadFailure(
            error: l.message,
            projects: currentState.projects,
          ),
        );
      }, (r) async {
        // Refetch project to update UI correctly
        final fetchResult = await _getProjectById(
          GetProjectByIdParams(projectId: event.projectId),
        );
        fetchResult.fold(
              (l) => emit(DailyLogUploadSuccess(currentState.projects)),
              (freshProject) {
            emit(
              DailyLogUploadSuccess(
                updateProjectInList(currentState.projects, freshProject),
              ),
            );
          },
        );
      });
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

      response.fold((l) {
        emit(
          ProjectMemberUpdateFailure(
            error: l.message,
            projects: currentState.projects,
          ),
        );
      }, (r) async {
        // IMPORTANT: Refetch the project to get the complete and fresh list of members from the backend
        final fetchResponse = await _getProjectById(
          GetProjectByIdParams(projectId: event.project.id),
        );

        fetchResponse.fold(
          // If fetch fails, use manual update as fallback
              (l) {
            Project outputProject = event.project;
            final updatedMembers = [
              for (final m in outputProject.teamMembers)
                if (m.userId != event.member.userId) m,
              r,
            ];
            outputProject = outputProject.copyWith(teamMembers: updatedMembers);

            emit(
              ProjectMemberUpdateSuccess(
                projects: updateProjectInList(
                  currentState.projects,
                  outputProject,
                ),
                project: outputProject,
                member: r,
              ),
            );
          },
          // If fetch succeeds, use the fresh data
              (freshProject) {
            emit(
              ProjectMemberUpdateSuccess(
                projects: updateProjectInList(
                  currentState.projects,
                  freshProject,
                ),
                project: freshProject,
                member: r,
              ),
            );
          },
        );
      });
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

      response.fold((l) {
        emit(
          DailyLogUploadFailure(
            error: l.message,
            projects: currentState.projects,
          ),
        );
      }, (r) {
        // For task management, we can probably just patch locally to avoid spinner flicker
        // but if consistency is key, we could refetch.
        final updatedProjects =
        currentState.projects.map((project) {
          final updatedLogs =
          project.dailyLogs.map((log) {
            if (log.id == event.dailyLogId) {
              return log.copyWith(plannedTasks: r);
            }
            return log;
          }).toList();

          return project.copyWith(dailyLogs: updatedLogs);
        }).toList();

        emit(DailyLogUploadSuccess(updatedProjects));
      });
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
          final updatedProjects = updateProjectInList(
            currentProjects,
            retrievedProject,
          );
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
          final updatedProjects = updateProjectInList(
            currentProjects,
            retrievedProject,
          );
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
      await _addRecentProject(AddToRecentParams(project: event.project));

      emit(
        ProjectRetrieveAddRecent(
          project: event.project,
          projects: currentState.projects,
        ),
      );
    }
  }

  void _onDeleteProject(
      ProjectDeleteEvent event,
      Emitter<ProjectState> emit,
      ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _deleteProject(
        DeleteProjectParams(projectId: event.projectId),
      );
      response.fold((l) {
        emit(ProjectFailure(l.message));
        emit(ProjectRetrieveSuccess(currentState.projects));
      }, (r) {
        final updatedProjects =
        currentState.projects
            .where((p) => p.id != event.projectId)
            .toList();
        emit(ProjectRetrieveSuccess(updatedProjects));
      });
    }
  }

  void _onLeaveProject(
      ProjectLeaveEvent event,
      Emitter<ProjectState> emit,
      ) async {
    final currentState = state;
    if (currentState is ProjectRetrieveSuccess) {
      emit(ProjectLoading());
      final response = await _leaveProject(
        LeaveProjectParams(projectId: event.projectId, userId: event.userId),
      );
      response.fold((l) {
        emit(ProjectFailure(l.message));
        emit(ProjectRetrieveSuccess(currentState.projects));
      }, (r) {
        final updatedProjects =
        currentState.projects
            .where((p) => p.id != event.projectId)
            .toList();
        emit(ProjectRetrieveSuccess(updatedProjects));
      });
    }
  }

  // Helper method for refetching
  Future<void> _refetchProject(
      String projectId,
      Emitter<ProjectState> emit,
      List<Project> currentList,
      ) async {
    final fetchResponse = await _getProjectById(
      GetProjectByIdParams(projectId: projectId),
    );

    fetchResponse.fold(
          (l) => emit(ProjectRetrieveSuccess(currentList)), // Keep old on error
          (freshProject) {
        emit(
          ProjectRetrieveSuccess(
            updateProjectInList(currentList, freshProject),
          ),
        );
      },
    );
  }

  List<Project> updateProjectInList(List<Project> projects, Project updated) {
    if (projects.isEmpty) return [updated];
    if (projects.any((p) => p.id == updated.id)) {
      return projects.map((p) => p.id == updated.id ? updated : p).toList();
    }
    return [...projects, updated];
  }
}