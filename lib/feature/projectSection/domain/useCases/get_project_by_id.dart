import 'package:fpdart/fpdart.dart';
import 'package:site_board/core/common/entities/user.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';

class GetProjectById implements UserCase<Project, GetProjectByIdParams> {
  final ProjectRepository projectRepository;
  GetProjectById(this.projectRepository);

  @override
  Future<Either<Failure, Project>> call(GetProjectByIdParams params) async {
    return await projectRepository.getProjectById(
      projectId: params.projectId,
      user: params.user,
    );
  }
}

class GetProjectByIdParams {
  final String projectId;
  final User user;

  GetProjectByIdParams({required this.projectId, required this.user});
}
