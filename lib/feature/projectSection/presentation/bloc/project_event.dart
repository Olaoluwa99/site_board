part of 'project_bloc.dart';

@immutable
sealed class ProjectEvent {}

final class ProjectCreate extends ProjectEvent {
  final Project project;

  ProjectCreate({required this.project});
}

final class ProjectUpdate extends ProjectEvent {
  final Project project;
  final File? coverImage;

  ProjectUpdate({required this.project, required this.coverImage});
}

final class DailyLogCreate extends ProjectEvent {
  final String projectId;
  final DailyLog dailyLog;
  final bool isCurrentTaskModified;
  final List<LogTask> currentTasks;
  final List<File?> startingTaskImageList;

  DailyLogCreate({
    required this.projectId,
    required this.dailyLog,
    required this.isCurrentTaskModified,
    required this.currentTasks,
    required this.startingTaskImageList,
  });
}

final class DailyLogUpdate extends ProjectEvent {
  final String projectId;
  final DailyLog dailyLog;
  final bool isCurrentTaskModified;
  final List<LogTask> currentTasks;
  final List<File?> startingTaskImageList;
  final List<File?> endingTaskImageList;

  DailyLogUpdate({
    required this.projectId,
    required this.dailyLog,
    required this.isCurrentTaskModified,
    required this.currentTasks,
    required this.startingTaskImageList,
    required this.endingTaskImageList,
  });
}

final class ManageCurrentLogTask extends ProjectEvent {
  final String dailyLogId;
  final List<LogTask> currentTasks;

  ManageCurrentLogTask({required this.dailyLogId, required this.currentTasks});
}

final class ProjectGetAllProjects extends ProjectEvent {
  final String userId;
  ProjectGetAllProjects({required this.userId});
}

final class ProjectGetProjectById extends ProjectEvent {
  final Project project;
  ProjectGetProjectById({required this.project});
}

final class ProjectGetProjectByLink extends ProjectEvent {
  final String projectLink;
  ProjectGetProjectByLink({required this.projectLink});
}

final class ProjectAddToRecent extends ProjectEvent {
  final Project project;
  ProjectAddToRecent({required this.project});
}

final class ProjectGetRecentProjects extends ProjectEvent {}

final class UpdateMemberEvent extends ProjectEvent {
  final Member member;
  final Project project;
  final bool isCreateMember;
  UpdateMemberEvent({
    required this.member,
    required this.project,
    required this.isCreateMember,
  });
}

final class ProjectDeleteEvent extends ProjectEvent {
  final String projectId;
  ProjectDeleteEvent({required this.projectId});
}

final class ProjectLeaveEvent extends ProjectEvent {
  final String projectId;
  final String userId;
  ProjectLeaveEvent({required this.projectId, required this.userId});
}

final class DailyLogDelete extends ProjectEvent {
  final String logId;
  final String projectId;
  DailyLogDelete({required this.logId, required this.projectId});
}