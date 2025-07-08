import 'package:flutter/material.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';

class ViewProjectDetail extends StatelessWidget {
  final Project project;
  final VoidCallback onClose;
  final VoidCallback onCompleted;
  const ViewProjectDetail({
    required this.project,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project detail')),
      body: const Center(child: Text('View Project detail')),
    );
  }
}
