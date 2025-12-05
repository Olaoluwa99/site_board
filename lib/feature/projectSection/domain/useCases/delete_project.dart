import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class DeleteProject implements UserCase<void, DeleteProjectParams> {
  final ProjectRepository projectRepository;
  DeleteProject(this.projectRepository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) async {
    return await projectRepository.deleteProject(params.projectId);
  }
}

class DeleteProjectParams {
  final String projectId;
  DeleteProjectParams({required this.projectId});
}