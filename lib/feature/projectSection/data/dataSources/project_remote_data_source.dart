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

  Future<void> deleteProject(String projectId);
  Future<void> leaveProject(String projectId, String userId);
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
            .eq('id', existingMember['id'])
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
    return _upsertMember(member);
  }

  @override
  Future<MemberModel> updateMember(MemberModel member) async {
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
      // Use a consistent path for project images
      final filePath = 'covers/${project.id}';

      await supabaseClient.storage
          .from('project_images')
          .upload(filePath, image, fileOptions: const FileOptions(upsert: true));

      return supabaseClient.storage
          .from('project_images')
          .getPublicUrl(filePath);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProjectModel>> getAllProjects({required String userId}) async {
    try {
      // FIX: Fetch all projects where user is a member OR creator
      // We rely on the Members table. Since creators are added as members,
      // querying the Members table for the userId gives us all project IDs.

      final membersResponse = await supabaseClient
          .from('members')
          .select('project_id')
          .eq('user_id', userId);

      final projectIds = (membersResponse as List)
          .map((m) => m['project_id'] as String)
          .toList();

      if (projectIds.isEmpty) return [];

      final response = await supabaseClient
          .from('projects')
          .select('*, daily_logs(*, log_tasks(*)), members(*)')
          .inFilter('id', projectIds);

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
      final response = await supabaseClient
          .from('log_tasks')
          .select()
          .eq('daily_log_id', dailyLogId);

      final existingTasks =
      (response as List<dynamic>)
          .map((e) => LogTaskModel.fromJson(e))
          .toList();

      final existingMap = {for (var t in existingTasks) t.id: t};
      final currentMap = {for (var t in currentTasks) t.id: t};

      final tasksToDelete =
      existingTasks
          .where((t) => !currentMap.containsKey(t.id))
          .map((t) => t.id)
          .toList();

      final tasksToInsert =
      currentTasks
          .where((t) => t.id.isEmpty || !existingMap.containsKey(t.id))
          .toList();

      final tasksToUpdate =
      currentTasks.where((t) {
        final existing = existingMap[t.id];
        return existing != null &&
            existing != t;
      }).toList();

      if (tasksToDelete.isNotEmpty) {
        await supabaseClient
            .from('log_tasks')
            .delete()
            .inFilter('id', tasksToDelete);
      }

      if (tasksToInsert.isNotEmpty) {
        await supabaseClient
            .from('log_tasks')
            .insert(tasksToInsert.map((e) => e.toJson()).toList());
      }

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

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      // Requires Cascade Delete on DB or manual deletion of children.
      // Assuming Cascade is ON in Supabase for foreign keys.
      await supabaseClient.from('projects').delete().eq('id', projectId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveProject(String projectId, String userId) async {
    try {
      await supabaseClient
          .from('members')
          .delete()
          .eq('project_id', projectId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}