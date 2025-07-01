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
    on<ProjectEvent>((event, emit) => emit(ProjectLoading()));
    on<ProjectCreate>(_onProjectCreate);
    on<ProjectUpdate>(_onProjectUpdate);
    on<DailyLogCreate>(_onDailyLogCreate);
    on<DailyLogUpdate>(_onDailyLogUpdate);
    on<ManageCurrentLogTask>(_onManageLogTask);
    on<ProjectGetAllProjects>(_onGetAllProjects);
  }

  void _onProjectCreate(ProjectCreate event, Emitter<ProjectState> emit) async {
    final response = await _createProject(
      CreateProjectParams(project: event.project),
    );
    response.fold(
      (l) => emit(ProjectFailure(l.message)),
      (r) => emit(ProjectUploadSuccess()),
    );
  }

  void _onProjectUpdate(ProjectUpdate event, Emitter<ProjectState> emit) async {
    final response = await _updateProject(
      UpdateProjectParams(project: event.project, image: event.coverImage),
    );
    response.fold(
      (l) => emit(ProjectFailure(l.message)),
      (r) => emit(ProjectUploadSuccess()),
    );
  }

  void _onDailyLogCreate(
    DailyLogCreate event,
    Emitter<ProjectState> emit,
  ) async {
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
      (l) => emit(ProjectFailure(l.message)),
      (r) => emit(ProjectUploadSuccess()),
    );
  }

  void _onDailyLogUpdate(
    DailyLogUpdate event,
    Emitter<ProjectState> emit,
  ) async {
    final response = await _updateDailyLog(
      UpdateDailyLogParams(
        projectId: event.projectId,
        dailyLog: event.dailyLog,
        isCurrentTaskModified: event.isCurrentTaskModified,
        currentTasks: event.currentTasks,
        startingTaskImageList: event.startingTaskImageList,
        endingTaskImageList: event.startingTaskImageList,
      ),
    );
    response.fold(
      (l) => emit(ProjectFailure(l.message)),
      (r) => emit(ProjectUploadSuccess()),
    );
  }

  void _onManageLogTask(
    ManageCurrentLogTask event,
    Emitter<ProjectState> emit,
  ) async {
    final response = await _manageLogTask(
      ManageLogTaskParams(
        dailyLogId: event.dailyLogId,
        currentTasks: event.currentTasks,
      ),
    );
    response.fold(
      (l) => emit(ProjectFailure(l.message)),
      (r) => emit(ProjectUploadSuccess()),
    );
  }

  void _onGetAllProjects(
    ProjectGetAllProjects event,
    Emitter<ProjectState> emit,
  ) async {
    final response = await _getAllProjects(
      GetAllProjectsParams(userId: event.userId),
    );
    response.fold(
      (l) => emit(ProjectFailure(l.message)),
      (r) => emit(ProjectRetrieveSuccess(r)),
    );
  }
}
