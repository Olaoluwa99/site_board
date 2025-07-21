import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';

class GetProjectByLink implements UserCase<Project, GetProjectByLinkParams> {
  final ProjectRepository projectRepository;
  GetProjectByLink(this.projectRepository);

  @override
  Future<Either<Failure, Project>> call(GetProjectByLinkParams params) async {
    return await projectRepository.getProjectByLink(
      projectLink: params.projectLink,
      user: params.user,
    );
  }
}

class GetProjectByLinkParams {
  final String projectLink;
  final User user;

  GetProjectByLinkParams({required this.projectLink, required this.user});
}
