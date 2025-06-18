import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class GetAllProjects implements UserCase<List<Project>, GetAllProjectsParams> {
  final ProjectRepository projectRepository;
  GetAllProjects(this.projectRepository);

  @override
  Future<Either<Failure, List<Project>>> call(
    GetAllProjectsParams params,
  ) async {
    return await projectRepository.getAllProjects(userId: params.userId);
  }
}

class GetAllProjectsParams {
  final String userId;

  GetAllProjectsParams({required this.userId});
}
