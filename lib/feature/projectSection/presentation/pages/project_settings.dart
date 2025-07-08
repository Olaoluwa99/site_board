import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';

class ProjectSettings extends StatefulWidget {
  final Project project;
  final VoidCallback onClose;
  final VoidCallback onCompleted;
  const ProjectSettings({
    required this.project,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<ProjectSettings> createState() => _ProjectSettingsState();
}

class _ProjectSettingsState extends State<ProjectSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project settings')),
      body: const Center(child: Text('Edit Project settings')),
    );
  }
}
