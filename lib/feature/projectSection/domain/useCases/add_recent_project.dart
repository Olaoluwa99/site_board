import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project.dart';

class AddRecentProject implements UserCase<void, AddToRecentParams> {
  final ProjectRepository projectRepository;
  AddRecentProject(this.projectRepository);

  @override
  Future<Either<Failure, void>> call(AddToRecentParams params) async {
    return await projectRepository.addRecentProject(project: params.project);
  }

  /*@override
  Future<Either<Failure, void>> call(AddToRecentParams params) async {
    try {
      await projectRepository.addRecentProject(project: params.project);
      return Right(null); // represents success
    } catch (e) {
      return Left(ServerFailure()); // or a specific Failure subclass
    }
  }*/
}

class AddToRecentParams {
  final Project project;

  AddToRecentParams({required this.project});
}
