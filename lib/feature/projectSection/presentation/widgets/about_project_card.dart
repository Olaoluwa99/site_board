import 'package:flutter/material.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/text_with_prefix.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/format_date.dart';

class AboutProjectCard extends StatelessWidget {
  final Project project;
  const AboutProjectCard({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      //height: 240,
      decoration: BoxDecoration(
        color: AppPalette.borderColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWithPrefix(prefix: 'Project name: ', text: project.projectName),
            SizedBox(height: 6),
            TextWithPrefix(prefix: 'Location: ', text: project.location ?? ''),
            SizedBox(height: 6),
            TextWithPrefix(
              prefix: 'Start date: ',
              text: formatDateDDMMYYYYHHMM(project.createdDate),
            ),
            SizedBox(height: 6),
            Text(
              '${project.description}\n' ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              //textAlign: TextAlign.justify,
            ),
            SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Show more...'),
            ),
          ],
        ),
      ),
    );
  }
}
