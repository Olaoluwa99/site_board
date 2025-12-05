import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class LeaveProject implements UserCase<void, LeaveProjectParams> {
  final ProjectRepository projectRepository;
  LeaveProject(this.projectRepository);

  @override
  Future<Either<Failure, void>> call(LeaveProjectParams params) async {
    return await projectRepository.leaveProject(params.projectId, params.userId);
  }
}

class LeaveProjectParams {
  final String projectId;
  final String userId;
  LeaveProjectParams({required this.projectId, required this.userId});
}