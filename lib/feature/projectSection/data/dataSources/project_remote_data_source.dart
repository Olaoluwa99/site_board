import 'dart:io';

import 'package:site_board/feature/projectSection/data/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/daily_log_model.dart';

abstract interface class ProjectRemoteDataSource {
  Future<ProjectModel> uploadProject(ProjectModel project);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<String> uploadProjectCoverImage({
    required File image,
    required ProjectModel project,
  });
  Future<List<String>> uploadDailyLogImages({
    required List<File?> images,
    required DailyLogModel dailyLogModel,
  });
  Future<List<ProjectModel>> getAllProjects({required String userId});
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final SupabaseClient supabaseClient;
  ProjectRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProjectModel> uploadProject(ProjectModel project) async {
    try {
      final projectData =
          await supabaseClient
              .from('projects')
              .insert(project.toJson())
              .select();
      return ProjectModel.fromJson(projectData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final updatedProject =
          await supabaseClient
              .from('projects')
              .update(project.toJson())
              .eq('id', project.id)
              .select();

      return ProjectModel.fromJson(updatedProject.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadDailyLogImages({
    required List<File?> images,
    required DailyLogModel dailyLogModel,
  }) async {
    List<String> imageUrls = List.filled(images.length, '');

    for (int i = 0; i < images.length; i++) {
      try {
        final filePath = '${dailyLogModel.id}_${i + 1}';
        if (images[i] != null) {
          await supabaseClient.storage
              .from('project_log_images')
              .upload(
                filePath,
                images[i]!,
                fileOptions: const FileOptions(upsert: true),
              );
          final publicUrl = supabaseClient.storage
              .from('project_log_images')
              .getPublicUrl(filePath);
          imageUrls[i] = publicUrl;
        }
      } on StorageException catch (e) {
        throw ServerException(e.message);
      } catch (e) {
        throw ServerException(e.toString());
      }
    }
    return imageUrls;
  }

  @override
  Future<String> uploadProjectCoverImage({
    required File image,
    required ProjectModel project,
  }) async {
    try {
      await supabaseClient.storage
          .from('project_cover_images')
          .upload(project.id, image);
      return supabaseClient.storage
          .from('project_cover_images')
          .getPublicUrl(project.id);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProjectModel>> getAllProjects({required String userId}) async {
    try {
      final projects = await supabaseClient
          .from('projects')
          .select()
          .eq('creatorId', userId);

      return projects.map((project) => ProjectModel.fromJson(project)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
