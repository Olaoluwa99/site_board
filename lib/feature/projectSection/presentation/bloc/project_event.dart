part of 'project_bloc.dart';

@immutable
sealed class ProjectEvent {}

final class ProjectUpload extends ProjectEvent {
  final Project project;
  final DailyLog? dailyLog;
  final bool isUpdate;
  final bool isCoverImage;
  final bool isDailyLogIncluded;
  final File? coverImage;
  final List<File?> taskImageList;

  ProjectUpload({
    required this.project,
    required this.dailyLog,
    required this.isUpdate,
    required this.isCoverImage,
    required this.isDailyLogIncluded,
    required this.coverImage,
    required this.taskImageList,
  });
}

final class ProjectGetAllProjects extends ProjectEvent {
  final String userId;
  ProjectGetAllProjects({required this.userId});
}
