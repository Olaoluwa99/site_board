/*class UploadProject implements UserCase<Project, UploadProjectParams> {
  final ProjectRepository projectRepository;
  UploadProject(this.projectRepository);
  @override
  Future<Either<Failure, Project>> call(UploadProjectParams params) async {
    return await projectRepository.uploadProject(
      project: params.project,
      dailyLog: params.dailyLog,
      isUpdate: params.isUpdate,
      isCoverImage: params.isCoverImage,
      isDailyLogIncluded: params.isDailyLogIncluded,
      image: params.coverImage,
      taskImageList: params.taskImageList,
    );
  }
}

class UploadProjectParams {
  final Project project;
  final DailyLog? dailyLog;
  final bool isUpdate;
  final bool isCoverImage;
  final bool isDailyLogIncluded;
  final File? coverImage;
  final List<File?> taskImageList;

  UploadProjectParams({
    required this.project,
    required this.dailyLog,
    required this.isUpdate,
    required this.isCoverImage,
    required this.isDailyLogIncluded,
    required this.coverImage,
    required this.taskImageList,
  });
}*/
