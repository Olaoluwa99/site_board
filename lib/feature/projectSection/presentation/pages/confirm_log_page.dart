import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';

import '../../../../../core/utils/pick_image.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/daily_log.dart';
import '../bloc/project_bloc.dart';
import '../widgets/confirm_status_list_item.dart';
import '../widgets/field_editor.dart';
import '../widgets/image_item.dart';

class ConfirmLogPage extends StatefulWidget {
  final String projectId;
  final DailyLog log;
  final VoidCallback onClose;
  final VoidCallback onCompleted;
  const ConfirmLogPage({
    required this.projectId,
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
  List<LogTask> updatedTaskList = [];

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
    updatedTaskList = dailyLog.plannedTasks;
    _observationsController.text = dailyLog.observations;
  }

  void uploadDailyLog() {
    double sum = 0.0;
    for (LogTask value in updatedTaskList) {
      sum += value.percentCompleted;
    }
    dailyLog = dailyLog.copyWith(
      isConfirmed: true,
      workScore: sum / updatedTaskList.length,
      observations: _observationsController.text,
    );

    context.read<ProjectBloc>().add(
      DailyLogUpdate(
        projectId: widget.projectId,
        dailyLog: dailyLog,
        isCurrentTaskModified: true,
        currentTasks: updatedTaskList,
        startingTaskImageList: List.filled(5, null),
        endingTaskImageList: images,
      ),
    );
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
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectLoading) {
            showLoaderDialog(context);
          }
          if (state is DailyLogUploadFailure) {
            Navigator.of(context, rootNavigator: true).pop();
            showSnackBar(context, state.error);
          }
          if (state is DailyLogUploadSuccess) {
            Navigator.of(context, rootNavigator: true).pop();
            showSnackBar(context, 'File has been saved!');
            widget.onCompleted();
          }
        },
        child: SingleChildScrollView(
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
                    ...List.generate(updatedTaskList.length, (index) {
                      final selectedTask = updatedTaskList[index];
                      return ConfirmStatusListItem(
                        index: index,
                        task: selectedTask,
                        onEditCompleted: (outputTask) {
                          for (LogTask nTask in dailyLog.plannedTasks) {
                            if (nTask.id == selectedTask.id) {
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                        return ImageItem(
                          index: index,
                          imageAsFile: image,
                          imageAsLink: widget.log.endingImageUrl[index],
                          onSelect: () => selectImage(index),
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
                    GradientButton(onClick: uploadDailyLog, text: 'Upload'),
                    SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
