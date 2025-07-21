import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/default_button.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending access',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Complete Project',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('This would', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            DefaultButton(onClick: () {}, text: 'Complete Project'),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Delete Project',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('This would', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            DefaultButton(onClick: () {}, text: 'Delete Project'),
          ],
        ),
      ),
    );
  }
}
