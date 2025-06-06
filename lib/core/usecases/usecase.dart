import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

abstract interface class UserCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}
