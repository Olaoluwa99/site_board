import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class UpdateProject implements UserCase<Project, UpdateProjectParams> {
  final ProjectRepository projectRepository;
  UpdateProject(this.projectRepository);
  @override
  Future<Either<Failure, Project>> call(UpdateProjectParams params) async {
    return await projectRepository.updateProject(
      project: params.project,
      image: params.image,
    );
  }
}

class UpdateProjectParams {
  final Project project;
  final File? image;

  UpdateProjectParams({required this.project, required this.image});
}
