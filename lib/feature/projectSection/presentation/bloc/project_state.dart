part of 'project_bloc.dart';

@immutable
sealed class ProjectState {}

final class ProjectInitial extends ProjectState {}

final class ProjectLoading extends ProjectState {}

final class ProjectFailure extends ProjectState {
  final String error;
  ProjectFailure(this.error);
}

//
final class ProjectUploadSuccess extends ProjectState {}

/*final class ProjectRetrieveSuccess extends ProjectState {
  final List<Project> projects;
  ProjectRetrieveSuccess(this.projects);
}*/

//
final class DailyLogUploadSuccess extends ProjectState {}

final class DailyLogUploadFailure extends ProjectState {
  final String error;
  DailyLogUploadFailure(this.error);
}

class ProjectRetrieveSuccess extends ProjectState {
  final List<Project> projects;

  ProjectRetrieveSuccess(this.projects);

  ProjectRetrieveSuccess copyWith({List<Project>? projects}) {
    return ProjectRetrieveSuccess(projects ?? this.projects);
  }
}

class ProjectRetrieveSuccessInit extends ProjectRetrieveSuccess {
  final bool isLocal;

  ProjectRetrieveSuccessInit({
    required List<Project> projects,
    required this.isLocal,
  }) : super(projects);
}

//EveryTime you Create/Update a DailyLog - Both the Create/Update and SyncTask is called
//Sync would always be called from the DailyLog Create/Update call and never by itself
