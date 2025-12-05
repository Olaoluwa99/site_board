import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class DeleteAccount implements UserCase<void, NoParams> {
  final AuthRepository authRepository;
  DeleteAccount(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.deleteAccount();
  }
}