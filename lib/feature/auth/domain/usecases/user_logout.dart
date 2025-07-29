import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UserLogout implements UserCase<bool, NoParams> {
  final AuthRepository authRepository;
  const UserLogout(this.authRepository);
  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await authRepository.logoutUser();
  }
}
