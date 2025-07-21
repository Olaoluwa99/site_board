import 'package:flutter/material.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/image_item_project.dart';

import '../../../../core/utils/format_date.dart';
import '../widgets/text_with_prefix.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              ImageItemProject(
                imageAsFile: null,
                imageAsLink: project.coverPhotoUrl ?? '',
                onSelect: () {},
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Project name',
                text: project.projectName,
                textSize: 16,
              ),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Creator',
                text: project.creatorId,
                textSize: 16,
              ),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Created on',
                text: formatDateDDMMYYYYHHMM(project.createdDate),
                textSize: 16,
              ),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Last updated',
                text: formatDateDDMMYYYYHHMM(project.lastUpdated),
                textSize: 16,
              ),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Location',
                text: project.location ?? '',
                textSize: 16,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Description',
                text: project.description ?? '',
                textSize: 16,
              ),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Access Link',
                text: project.projectLink ?? '',
                textSize: 16,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              TextWithPrefix(prefix: 'Team members', text: '', textSize: 16),
              Text('   * Aaron'),
              SizedBox(height: 4),
              Text('   * Shamgar'),
              SizedBox(height: 4),
              Text('   * Dancer'),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'End date',
                text:
                    project.endDate == null
                        ? 'Not at End'
                        : formatDateDDMMYYYYHHMM(project.endDate!),
                textSize: 16,
              ),
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
