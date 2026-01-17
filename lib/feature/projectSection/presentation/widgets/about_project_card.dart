import 'package:flutter/material.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/text_with_prefix.dart';

import '../../../../core/utils/format_date.dart';

class AboutProjectCard extends StatelessWidget {
  final Project project;
  final bool isLocal;
  final bool canEdit;
  final VoidCallback onEditClicked;
  final VoidCallback onViewClicked;
  const AboutProjectCard({
    required this.project,
    required this.isLocal,
    required this.canEdit,
    required this.onEditClicked,
    required this.onViewClicked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.topRight,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onViewClicked,
          child: Container(
            width: double.infinity,
            //height: 240,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithPrefix(
                    prefix: 'Project name',
                    text: project.projectName,
                    textSize: 14,
                  ),
                  SizedBox(height: 6),
                  TextWithPrefix(
                    prefix: 'Location',
                    text: project.location ?? '',
                    textSize: 14,
                  ),
                  SizedBox(height: 6),
                  TextWithPrefix(
                    prefix: 'Start date',
                    text: formatDateDDMMYYYYHHMM(project.createdDate),
                    textSize: 14,
                  ),
                  SizedBox(height: 6),
                  Text(
                    '${project.description}\n',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                    //textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Show more...',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        (isLocal || !canEdit)
            ? SizedBox.shrink()
            : SizedBox(
              child: InkWell(
                onTap: onEditClicked,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          theme
                              .canvasColor, // Use canvas/scaffold bg for contrast against card
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12), // space around the icon
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
