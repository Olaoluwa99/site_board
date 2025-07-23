import 'package:hive/hive.dart';
import 'package:site_board/feature/projectSection/data/models/project_model.dart';

abstract interface class ProjectLocalDataSource {
  void uploadLocalProjects({required List<ProjectModel> projects});
  void uploadRecentProject({required ProjectModel project});
  void uploadOfflineProject({required ProjectModel project});
  List<ProjectModel> loadRecentProjects();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final Box recentBox;
  final Box offlineBox;
  ProjectLocalDataSourceImpl(this.recentBox, this.offlineBox);

  @override
  List<ProjectModel> loadRecentProjects() {
    List<ProjectModel> projects = [];
    for (int i = 0; i < recentBox.length; i++) {
      final data = recentBox.get(i.toString());
      if (data != null) {
        projects.add(ProjectModel.fromJson(Map<String, dynamic>.from(data)));
      } else {}
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

    // Add or update the project
    recentBox.put(key, project.toCompleteJson());

    // Check if the box exceeds 5 items
    if (recentBox.length > 5) {
      // Get all keys sorted by insertion order (Hive preserves order)
      final keys = recentBox.keys.toList();

      // Delete the oldest key (first inserted)
      final oldestKey = keys.first;
      recentBox.delete(oldestKey);
    }
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
}
