import 'package:flutter/material.dart';

import '../../../../../core/utils/format_date.dart';
import '../../domain/entities/daily_log.dart';
import '../widgets/task_view_list_item.dart';
import '../widgets/text_list_item.dart';

class ViewLogPage extends StatelessWidget {
  final DailyLog log;
  final VoidCallback onClose;
  const ViewLogPage({required this.log, required this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View log')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Date/Time: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: formatDateDDMMYYYYHHMM(log.dateTimeList[0]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Number of Workers: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${log.numberOfWorkers}'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Weather Condition: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: log.weatherCondition),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Materials Available:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...log.materialsAvailable.asMap().entries.map((entry) {
                    final index = entry.key;
                    final material = entry.value;
                    return TextListItem(item: material, index: index);
                  }),

                  SizedBox(height: 16),
                  Text(
                    'Planned Tasks:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...log.plannedTasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    return TaskViewListItem(
                      taskText: task.plannedTask,
                      percentCompleted: task.percentCompleted,
                      index: index,
                    );
                  }),
                  SizedBox(height: 16),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Starting Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      log.startingImageUrl.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                          ), // spacing between images
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 120, // same as your image
                                    height: 120,
                                    color:
                                        Colors
                                            .grey
                                            .shade300, // fallback background
                                    child: const Icon(
                                      Icons
                                          .broken_image, // or Icons.image, Icons.photo, etc.
                                      size: 40,
                                      color:
                                          Colors
                                              .grey, // or another color that suits your theme
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ending Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      log.endingImageUrl.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                          ), // spacing between images
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 120, // same as your image
                                    height: 120,
                                    color:
                                        Colors
                                            .grey
                                            .shade300, // fallback background
                                    child: const Icon(
                                      Icons
                                          .broken_image, // or Icons.image, Icons.photo, etc.
                                      size: 40,
                                      color:
                                          Colors
                                              .grey, // or another color that suits your theme
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Observations and Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(log.observations, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
