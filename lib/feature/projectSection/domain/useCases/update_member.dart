import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/Member.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class UpdateMember implements UserCase<Member, UpdateMemberParams> {
  final ProjectRepository projectRepository;
  UpdateMember(this.projectRepository);
  @override
  Future<Either<Failure, Member>> call(UpdateMemberParams params) async {
    if (params.isCreateMember) {
      return await projectRepository.createMember(
        projectId: params.projectId,
        member: params.member,
      );
    } else {
      return await projectRepository.updateMember(
        projectId: params.projectId,
        member: params.member,
      );
    }
  }
}

class UpdateMemberParams {
  final String projectId;
  final Member member;
  final bool isCreateMember;

  UpdateMemberParams({
    required this.projectId,
    required this.member,
    required this.isCreateMember,
  });
}
