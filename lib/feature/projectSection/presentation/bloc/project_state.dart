part of 'project_bloc.dart';

@immutable
sealed class ProjectState {}

final class ProjectInitial extends ProjectState {}

final class ProjectLoading extends ProjectState {}

final class ProjectFailure extends ProjectState {
  final String error;
  ProjectFailure(this.error);
}

final class ProjectUploadSuccess extends ProjectState {}

final class ProjectRetrieveSuccess extends ProjectState {
  final List<Project> projects;
  ProjectRetrieveSuccess(this.projects);
}
