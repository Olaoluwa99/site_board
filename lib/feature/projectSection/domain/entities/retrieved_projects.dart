import 'package:site_board/feature/projectSection/domain/entities/project.dart';

class RetrievedProjects {
  final bool isLocal;
  final List<Project> projects;

  RetrievedProjects({this.isLocal = false, required this.projects});
}
