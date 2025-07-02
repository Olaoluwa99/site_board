import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/retrieved_projects.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class GetAllProjects
    implements UserCase<RetrievedProjects, GetAllProjectsParams> {
  final ProjectRepository projectRepository;
  GetAllProjects(this.projectRepository);

  @override
  Future<Either<Failure, RetrievedProjects>> call(
    GetAllProjectsParams params,
  ) async {
    return await projectRepository.getAllProjects(userId: params.userId);
  }
}

class GetAllProjectsParams {
  final String userId;

  GetAllProjectsParams({required this.userId});
}
