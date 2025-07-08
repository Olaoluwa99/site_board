import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';

class ProjectSummarizer extends StatefulWidget {
  final Project project;
  final VoidCallback onClose;
  final VoidCallback onCompleted;
  const ProjectSummarizer({
    required this.project,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<ProjectSummarizer> createState() => _ProjectSummarizerState();
}

class _ProjectSummarizerState extends State<ProjectSummarizer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project summarizer')),
      body: const Center(child: Text('Project summarizer')),
    );
  }
}
