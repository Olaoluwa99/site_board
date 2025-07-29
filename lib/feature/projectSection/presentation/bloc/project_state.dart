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

//

/*final class DailyLogUploadFailure extends ProjectState {
  final String error;
  DailyLogUploadFailure(this.error);
}*/
/*final class DailyLogUploadSuccess extends ProjectRetrieveSuccess {}

class DailyLogUploadFailure extends ProjectRetrieveSuccess {
  final String error;
  final DateTime timestamp; // or use String uuid = Uuid().v4();

  DailyLogUploadFailure(this.error) : timestamp = DateTime.now();

  @override
  List<Object> get props => [error, timestamp];
}*/
final class DailyLogUploadSuccess extends ProjectRetrieveSuccess {
  DailyLogUploadSuccess(super.projects);
}

class DailyLogUploadFailure extends ProjectRetrieveSuccess {
  final String error;
  final DateTime timestamp;

  DailyLogUploadFailure({required this.error, required List<Project> projects})
    : timestamp = DateTime.now(),
      super(projects);

  List<Object> get props => [error, timestamp, ...projects];
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

class ProjectRetrieveAddRecent extends ProjectRetrieveSuccess {
  final Project project;

  ProjectRetrieveAddRecent({
    required List<Project> projects,
    required this.project,
  }) : super(projects);
}

class ProjectRetrieveSuccessLink extends ProjectRetrieveSuccess {
  final Project project;

  ProjectRetrieveSuccessLink({
    required List<Project> projects,
    required this.project,
  }) : super(projects);
}

class ProjectRetrieveSuccessId extends ProjectRetrieveSuccess {
  final Project project;

  ProjectRetrieveSuccessId({
    required List<Project> projects,
    required this.project,
  }) : super(projects);
}

class ProjectMemberUpdateSuccess extends ProjectRetrieveSuccess {
  final Project project;
  final Member member;

  ProjectMemberUpdateSuccess({
    required List<Project> projects,
    required this.project,
    required this.member,
  }) : super(projects);
}

class ProjectMemberUpdateFailure extends ProjectRetrieveSuccess {
  final String error;
  ProjectMemberUpdateFailure({
    required this.error,
    required List<Project> projects,
  }) : super(projects);
}

class ProjectRetrieveByIdFailure extends ProjectRetrieveSuccess {
  final String error;
  final Project oldProject;
  ProjectRetrieveByIdFailure({
    required this.error,
    required this.oldProject,
    required List<Project> projects,
  }) : super(projects);
}

class ProjectRetrieveByLinkFailure extends ProjectRetrieveSuccess {
  final String error;
  ProjectRetrieveByLinkFailure({
    required this.error,
    required List<Project> projects,
  }) : super(projects);
}

class ProjectRetrieveRecentSuccess extends ProjectRetrieveSuccess {
  ProjectRetrieveRecentSuccess({required List<Project> projects})
    : super(projects);
}

class ProjectCreateSuccess extends ProjectRetrieveSuccess {
  final Project project;

  ProjectCreateSuccess({required List<Project> projects, required this.project})
    : super(projects);
}

//EveryTime you Create/Update a DailyLog - Both the Create/Update and SyncTask is called
//Sync would always be called from the DailyLog Create/Update call and never by itself
