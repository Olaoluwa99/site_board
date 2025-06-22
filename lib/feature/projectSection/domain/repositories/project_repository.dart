import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';

import '../../../../core/error/failure.dart';
import '../entities/daily_log.dart';

abstract interface class ProjectRepository {
  Future<Either<Failure, Project>> uploadProject({
    required Project project,
    required DailyLog? dailyLog,
    required bool isUpdate,
    required bool isCoverImage,
    required bool isDailyLogIncluded,
    required File? image,
    required List<File?> taskImageList,
  });

  Future<Either<Failure, List<Project>>> getAllProjects({
    required String userId,
  });
}
