import 'package:hive/hive.dart';
import 'package:site_board/core/enums/sync_status.dart';
import 'package:site_board/feature/projectSection/data/models/project_model.dart';

abstract interface class ProjectLocalDataSource {
  void uploadLocalProjects({required List<ProjectModel> projects});
  void uploadRecentProject({required ProjectModel project});
  void uploadOfflineProject({required ProjectModel project});
  List<ProjectModel> loadRecentProjects();
  List<ProjectModel> getProjectsByStatus(SyncStatus status);
  Stream<int> getUnsyncedCountStream();
  void deleteProject(String projectId);
  void clearData();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final Box recentBox;
  final Box offlineBox;
  ProjectLocalDataSourceImpl(this.recentBox, this.offlineBox);

  @override
  List<ProjectModel> loadRecentProjects() {
    List<ProjectModel> projects = [];

    for (var key in recentBox.keys) {
      final data = recentBox.get(key);
      if (data != null) {
        projects.add(ProjectModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }

    return projects;
  }

  @override
  void uploadLocalProjects({required List<ProjectModel> projects}) {
    recentBox.clear();
    for (int i = 0; i < projects.length; i++) {
      final key = projects[i].id;
      recentBox.put(key, projects[i].toCompleteJson());
    }
  }

  @override
  void uploadRecentProject({required ProjectModel project}) {
    final key = project.id;
    recentBox.put(key, project.toCompleteJson());
  }

  @override
  List<ProjectModel> getProjectsByStatus(SyncStatus status) {
    return loadRecentProjects().where((p) => p.syncStatus == status).toList();
  }

  @override
  Stream<int> getUnsyncedCountStream() {
    return recentBox.watch().map((event) {
      // Re-calculate count on any change
      int count = 0;
      final projects = loadRecentProjects();
      for (var p in projects) {
        if (p.syncStatus != SyncStatus.synced && p.syncStatus != null) {
          count++;
        } else {
          // Check if any log inside satisfied the condition
          final unsyncedLogs = p.dailyLogs.where(
            (l) => l.syncStatus != SyncStatus.synced && l.syncStatus != null,
          );
          if (unsyncedLogs.isNotEmpty) {
            count += unsyncedLogs.length;
          }
        }
      }
      return count;
    });
  }

  @override
  void deleteProject(String projectId) {
    recentBox.delete(projectId);
  }

  @override
  void uploadOfflineProject({required ProjectModel project}) {
    final key = project.id;

    // Add or update the project
    offlineBox.put(key, project.toCompleteJson());

    // Check if the box exceeds 5 items
    if (offlineBox.length > 5) {
      // Get all keys sorted by insertion order (Hive preserves order)
      final keys = offlineBox.keys.toList();

      // Delete the oldest key (first inserted)
      final oldestKey = keys.first;
      offlineBox.delete(oldestKey);
    }
  }

  @override
  void clearData() {
    recentBox.clear();
    offlineBox.clear();
  }
}
