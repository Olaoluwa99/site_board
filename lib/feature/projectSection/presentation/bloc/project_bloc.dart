import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/daily_log.dart';
import '../../domain/entities/project.dart';
import '../../domain/useCases/get_all_projects.dart';
import '../../domain/useCases/upload_project.dart';
import '../../rough_project.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final UploadProject _uploadProject;
  final GetAllProjects _getAllProjects;

  // ✅ Testing mode
  final bool useDummyData;

  ProjectBloc({
    required UploadProject uploadProject,
    required GetAllProjects getAllProjects,
    this.useDummyData = false,
  }) : _uploadProject = uploadProject,
       _getAllProjects = getAllProjects,
       super(ProjectInitial()) {
    on<ProjectEvent>((event, emit) => emit(ProjectLoading()));
    on<ProjectUpload>(_onProjectUpload);
    on<ProjectGetAllProjects>(_onGetAllProjects);
  }

  void _onProjectUpload(ProjectUpload event, Emitter<ProjectState> emit) async {
    final response = await _uploadProject(
      UploadProjectParams(
        project: event.project,
        dailyLog: event.dailyLog,
        isUpdate: event.isUpdate,
        isCoverImage: event.isCoverImage,
        isDailyLogIncluded: event.isDailyLogIncluded,
        coverImage: event.coverImage,
        taskImageList: event.taskImageList,
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
    if (useDummyData) {
      // ✅ Return Dummy Projects
      emit(ProjectRetrieveSuccess(_getDummyProjects()));
      return;
    }

    final response = await _getAllProjects(
      GetAllProjectsParams(userId: event.userId),
    );
    response.fold(
      (l) => emit(ProjectFailure(l.message)),
      (r) => emit(ProjectRetrieveSuccess(r)),
    );
  }

  // ✅ Dummy Projects
  List<Project> _getDummyProjects() {
    return getDummyProjects();
  }
}

/*
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final UploadProject _uploadProject;
  final GetAllProjects _getAllProjects;

  ProjectBloc({
    required UploadProject uploadProject,
    required GetAllProjects getAllProjects,
  }) : _uploadProject = uploadProject,
       _getAllProjects = getAllProjects,
       super(ProjectInitial()) {
    on<ProjectEvent>((event, emit) => emit(ProjectLoading()));
    on<ProjectUpload>(_onProjectUpload);
    on<ProjectGetAllProjects>(_onGetAllProjects);
  }

  void _onProjectUpload(ProjectUpload event, Emitter<ProjectState> emit) async {
    final response = await _uploadProject(
      UploadProjectParams(
        project: event.project,
        dailyLog: event.dailyLog,
        isUpdate: event.isUpdate,
        isCoverImage: event.isCoverImage,
        isDailyLogIncluded: event.isDailyLogIncluded,
        coverImage: event.coverImage,
        taskImageList: event.taskImageList,
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

  void _onGetFalseProjects(
    ProjectGetFalseProjects event,
    Emitter<ProjectState> emit,
  ) {
    emit(ProjectRetrieveSuccess([Project(projectName: '', creatorId: '')]));
  }
}
*/
