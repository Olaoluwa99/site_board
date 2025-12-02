import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:site_board/feature/projectSection/data/models/member_model.dart';
import 'package:site_board/feature/projectSection/data/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/daily_log_model.dart';

abstract interface class ProjectRemoteDataSource {
  Future<ProjectModel> createProject(ProjectModel project);
  Future<ProjectModel> updateProject(ProjectModel project);

  Future<DailyLogModel> createDailyLog(DailyLogModel dailyLog);
  Future<DailyLogModel> updateDailyLog(DailyLogModel dailyLog);

  Future<MemberModel> createMember(MemberModel member);
  Future<MemberModel> updateMember(MemberModel member);

  Future<void> syncLogTasks({
    required String dailyLogId,
    required List<LogTaskModel> currentTasks,
  });

  Future<ProjectModel> getProjectByLink({required String projectLink});

  Future<ProjectModel> getProjectById({required String projectId});

  Future<List<ProjectModel>> getAllProjects({required String userId});

  Future<String> uploadProjectCoverImage({
    required File image,
    required ProjectModel project,
  });
  Future<List<String>> uploadDailyLogImages({
    required isEndingImages,
    required List<File?> images,
    required DailyLogModel dailyLogModel,
  });
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final SupabaseClient supabaseClient;
  ProjectRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
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
  Future<DailyLogModel> createDailyLog(DailyLogModel dailyLog) async {
    try {
      final dailyLogData =
      await supabaseClient
          .from('daily_logs')
          .insert(dailyLog.toJson())
          .select();
      return DailyLogModel.fromJson(dailyLogData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DailyLogModel> updateDailyLog(DailyLogModel dailyLog) async {
    try {
      final updatedDailyLogData =
      await supabaseClient
          .from('daily_logs')
          .update(dailyLog.toJson())
          .eq('id', dailyLog.id)
          .select();

      return DailyLogModel.fromJson(updatedDailyLogData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Helper method for Upsert Logic
  Future<MemberModel> _upsertMember(MemberModel member) async {
    try {
      // FIX ISSUE D: Check existence by Composite Key (project_id + user_id)
      final existingMember = await supabaseClient
          .from('members')
          .select()
          .eq('project_id', member.projectId)
          .eq('user_id', member.userId)
          .maybeSingle();

      if (existingMember != null) {
        // Update existing
        final updatedData = await supabaseClient
            .from('members')
            .update(member.toJson())
            .eq('id', existingMember['id']) // Use the REAL DB ID
            .select()
            .single();
        return MemberModel.fromJson(updatedData);
      } else {
        // Insert new
        final newData = await supabaseClient
            .from('members')
            .insert(member.toJson())
            .select()
            .single();
        return MemberModel.fromJson(newData);
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MemberModel> createMember(MemberModel member) async {
    // Redirect to Upsert Logic
    return _upsertMember(member);
  }

  @override
  Future<MemberModel> updateMember(MemberModel member) async {
    // Redirect to Upsert Logic
    return _upsertMember(member);
  }

  @override
  Future<List<String>> uploadDailyLogImages({
    required isEndingImages,
    required List<File?> images,
    required DailyLogModel dailyLogModel,
  }) async {
    List<String> imageUrls = List.filled(images.length, '');

    for (int i = 0; i < images.length; i++) {
      try {
        String filePath = '';
        if (isEndingImages) {
          filePath = '${dailyLogModel.id}_end_${i + 1}';
        } else {
          filePath = '${dailyLogModel.id}_start_${i + 1}';
        }

        if (images[i] != null) {
          await supabaseClient.storage
              .from('daily_log_images')
              .upload(
            filePath,
            images[i]!,
            fileOptions: const FileOptions(upsert: true),
          );
          final publicUrl = supabaseClient.storage
              .from('daily_log_images')
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
          .from('project_images')
          .upload(project.id, image);
      return supabaseClient.storage
          .from('project_images')
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
      final response = await supabaseClient
          .from('projects')
      //.select('*, daily_logs(*, log_tasks(*))')
          .select('*, daily_logs(*, log_tasks(*)), members(*)')
          .eq('creator_id', userId);

      // Parse into ProjectModel
      return (response as List<dynamic>)
          .map((project) => ProjectModel.fromJson(project))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProjectModel> getProjectById({required String projectId}) async {
    try {
      final response =
      await supabaseClient
          .from('projects')
          .select('*, daily_logs(*, log_tasks(*)), members(*)')
          .eq('id', projectId)
          .maybeSingle();

      if (response == null) {
        throw ServerException('Project not found for id: $projectId');
      }

      return ProjectModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProjectModel> getProjectByLink({required String projectLink}) async {
    try {
      final response =
      await supabaseClient
          .from('projects')
          .select('*, daily_logs(*, log_tasks(*)), members(*)')
          .eq('project_link', projectLink)
          .maybeSingle();

      if (response == null) {
        throw ServerException('Project not found for link: $projectLink');
      }

      return ProjectModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> syncLogTasks({
    required String dailyLogId,
    required List<LogTaskModel> currentTasks,
  }) async {
    try {
      // 1. Fetch existing tasks from DB
      final response = await supabaseClient
          .from('log_tasks')
          .select()
          .eq('daily_log_id', dailyLogId);

      final existingTasks =
      (response as List<dynamic>)
          .map((e) => LogTaskModel.fromJson(e))
          .toList();

      // 2. Create maps for easy comparison
      final existingMap = {for (var t in existingTasks) t.id: t};
      final currentMap = {for (var t in currentTasks) t.id: t};

      // 3. Find tasks to delete
      final tasksToDelete =
      existingTasks
          .where((t) => !currentMap.containsKey(t.id))
          .map((t) => t.id)
          .toList();

      // 4. Find tasks to insert (new ones without ID or empty UUID)
      final tasksToInsert =
      currentTasks
          .where((t) => t.id.isEmpty || !existingMap.containsKey(t.id))
          .toList();

      // 5. Find tasks to update (ID exists in both, but content changed)
      final tasksToUpdate =
      currentTasks.where((t) {
        final existing = existingMap[t.id];
        return existing != null &&
            existing != t; // Override equality if needed
      }).toList();

      // 6. Perform deletes
      if (tasksToDelete.isNotEmpty) {
        await supabaseClient
            .from('log_tasks')
            .delete()
            .inFilter('id', tasksToDelete);
      }

      // 7. Perform inserts
      if (tasksToInsert.isNotEmpty) {
        await supabaseClient
            .from('log_tasks')
            .insert(tasksToInsert.map((e) => e.toJson()).toList());
      }

      // 8. Perform updates
      for (final task in tasksToUpdate) {
        await supabaseClient
            .from('log_tasks')
            .update(task.toJson())
            .eq('id', task.id);
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}