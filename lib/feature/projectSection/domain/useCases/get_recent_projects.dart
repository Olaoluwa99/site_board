import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class GetRecentProjects implements UserCase<List<Project>, NoParams> {
  final ProjectRepository projectRepository;
  GetRecentProjects(this.projectRepository);

  @override
  Future<Either<Failure, List<Project>>> call(NoParams params) async {
    return await projectRepository.getRecentProjects();
  }
}
