import 'package:flutter/material.dart';

class ProjectListItem extends StatelessWidget {
  final String projectName;
  final VoidCallback onClicked;
  const ProjectListItem({
    required this.projectName,
    required this.onClicked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClicked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Text(projectName),
          SizedBox(height: 8),
          Divider(),
        ],
      ),
    );
    ;
  }
}
