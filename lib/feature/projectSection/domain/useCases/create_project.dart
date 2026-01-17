import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class CreateProject implements UserCase<Project, CreateProjectParams> {
  final ProjectRepository projectRepository;
  CreateProject(this.projectRepository);
  @override
  Future<Either<Failure, Project>> call(CreateProjectParams params) async {
    return await projectRepository.createProject(
      project: params.project,
      coverImage: params.coverImage,
    );
  }
}

class CreateProjectParams {
  final Project project;
  final File? coverImage;

  CreateProjectParams({required this.project, this.coverImage});
}
