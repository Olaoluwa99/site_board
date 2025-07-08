import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';

class EditProjectDetail extends StatefulWidget {
  final Project project;
  final VoidCallback onClose;
  final VoidCallback onCompleted;
  const EditProjectDetail({
    required this.project,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<EditProjectDetail> createState() => _EditProjectDetailState();
}

class _EditProjectDetailState extends State<EditProjectDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project detail')),
      body: const Center(child: Text('Edit Project detail')),
    );
  }
}
