import 'package:fpdart/fpdart.dart';
import 'package:site_board/core/error/failure.dart';
import 'package:site_board/core/usecases/usecase.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

class DeleteDailyLog implements UserCase<void, DeleteDailyLogParams> {
  final ProjectRepository projectRepository;

  DeleteDailyLog(this.projectRepository);

  @override
  Future<Either<Failure, void>> call(DeleteDailyLogParams params) async {
    return await projectRepository.deleteDailyLog(params.dailyLogId);
  }
}

class DeleteDailyLogParams {
  final String dailyLogId;

  DeleteDailyLogParams({required this.dailyLogId});
}