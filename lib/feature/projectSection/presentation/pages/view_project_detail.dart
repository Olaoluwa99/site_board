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
      appBar: AppBar(title: Text('Project Detail')),
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
                prefix: 'Creator ID',
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
                text: project.location ?? 'N/A',
                textSize: 16,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Description',
                text: project.description ?? 'No description.',
                textSize: 16,
              ),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'Access Link',
                text: project.projectLink ?? 'N/A',
                textSize: 16,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text('Team Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (project.teamMembers.isEmpty)
                Text("No members.", style: TextStyle(color: Colors.grey)),
              ...project.teamMembers.map((member) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(member.name, style: TextStyle(fontSize: 16)),
                      if (member.isAdmin)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Chip(label: Text("Admin", style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                        )
                    ],
                  ),
                );
              }),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              TextWithPrefix(
                prefix: 'End date',
                text:
                project.endDate == null
                    ? 'Ongoing'
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