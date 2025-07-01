import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/daily_log.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class ManageLogTask implements UserCase<List<LogTask>, ManageLogTaskParams> {
  final ProjectRepository projectRepository;
  ManageLogTask(this.projectRepository);
  @override
  Future<Either<Failure, List<LogTask>>> call(
    ManageLogTaskParams params,
  ) async {
    return await projectRepository.manageLogTasks(
      dailyLogId: params.dailyLogId,
      currentTasks: params.currentTasks,
    );
  }
}

class ManageLogTaskParams {
  final String dailyLogId;
  final List<LogTask> currentTasks;

  ManageLogTaskParams({required this.dailyLogId, required this.currentTasks});
}
