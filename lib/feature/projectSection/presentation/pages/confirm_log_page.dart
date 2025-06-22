import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/pick_image.dart';
import '../../domain/entities/daily_log.dart';
import '../widgets/confirm_status_list_item.dart';
import '../widgets/field_editor.dart';

class ConfirmLogPage extends StatefulWidget {
  final DailyLog log;
  final VoidCallback onClose;
  final void Function(DailyLog dailyLog) onCompleted;
  const ConfirmLogPage({
    required this.log,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<ConfirmLogPage> createState() => _ConfirmLogPageState();
}

class _ConfirmLogPageState extends State<ConfirmLogPage> {
  final TextEditingController _observationsController = TextEditingController();

  late DailyLog dailyLog;
  List<File?> images = List.filled(5, null);

  Future<void> selectImage(int index) async {
    final pickedFile = await pickImage();
    if (pickedFile != null) {
      setState(() {
        images[index] = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dailyLog = widget.log;
    _observationsController.text = dailyLog.observations;
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirm log')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Select the percentage of the completed tasks.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  //Divider(),
                  SizedBox(height: 8),
                  ...List.generate(dailyLog.plannedTasks.length, (index) {
                    final selectedTask = dailyLog.plannedTasks[index];
                    return ConfirmStatusListItem(
                      index: index,
                      task: selectedTask,
                      onEditCompleted: (outputTask) {
                        List<LogTask> updatedTaskList = [];
                        for (LogTask nTask in dailyLog.plannedTasks) {
                          if (nTask == selectedTask) {
                            updatedTaskList.add(outputTask);
                          } else {
                            updatedTaskList.add(nTask);
                          }
                        }
                        dailyLog = dailyLog.copyWith(
                          plannedTasks: updatedTaskList,
                        );
                      },
                    );
                  }),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Select post-work Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SizedBox(
                height: 150, // Square height
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      final image = images[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () => selectImage(index),
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child:
                                image != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        image,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        color: AppPalette.borderColor,
                                        dashPattern: [10, 5],
                                        strokeWidth: 2,
                                        padding: EdgeInsets.all(0),
                                        radius: Radius.circular(12),
                                        strokeCap: StrokeCap.round,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.folder_open, size: 44),
                                            SizedBox(height: 15),
                                            Text(
                                              'Select\nimage ${index + 1}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 16),
                  FieldEditor(
                    hintText: 'Observation & Notes',
                    controller: _observationsController,
                    minLines: 5,
                  ),
                  SizedBox(height: 24),
                  GradientButton(
                    onClick: () {
                      double sum = 0.0;
                      for (LogTask value in dailyLog.plannedTasks) {
                        sum += value.percentCompleted;
                      }
                      dailyLog = dailyLog.copyWith(
                        isConfirmed: true,
                        workScore: sum / dailyLog.plannedTasks.length,
                      );
                      widget.onCompleted(dailyLog);
                    },
                    text: 'Upload',
                  ),
                  SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
