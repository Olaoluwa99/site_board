import 'package:flutter/material.dart';

class TaskViewListItem extends StatelessWidget {
  final String taskText;
  final String taskStatus;
  final int index;
  const TaskViewListItem({
    required this.taskText,
    required this.taskStatus,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}.  ', style: TextStyle(fontSize: 16)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(taskText, style: TextStyle(fontSize: 16)),
                Text('Status: $taskStatus', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),

        Divider(),
      ],
    );
  }
}
