import 'package:hive/hive.dart';
import 'package:site_board/feature/projectSection/data/models/project_model.dart';

abstract interface class ProjectLocalDataSource {
  void uploadLocalProjects({required List<ProjectModel> projects});
  List<ProjectModel> loadProjects();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final Box box;
  ProjectLocalDataSourceImpl(this.box);

  @override
  List<ProjectModel> loadProjects() {
    List<ProjectModel> projects = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.get(i.toString());
      if (data != null) {
        projects.add(ProjectModel.fromJson(Map<String, dynamic>.from(data)));
      } else {}
    }
    return projects;
  }

  @override
  void uploadLocalProjects({required List<ProjectModel> projects}) {
    box.clear();
    for (int i = 0; i < projects.length; i++) {
      box.put(i.toString(), projects[i].toCompleteJson());
    }
  }
}
