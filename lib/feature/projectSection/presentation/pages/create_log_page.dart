import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/pick_image.dart';
import '../../domain/entities/daily_log.dart';
import '../widgets/field_editor.dart';
import '../widgets/pseudo_editor.dart';
import '../widgets/task_list_item.dart';

class CreateLogPage extends StatefulWidget {
  final DailyLog? log;
  final VoidCallback onClose;
  final void Function(DailyLog dailyLog) onCompleted;
  const CreateLogPage({
    this.log,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<CreateLogPage> createState() => _CreateLogPageState();
}

class _CreateLogPageState extends State<CreateLogPage> {
  final TextEditingController _numberOfWorkersController =
      TextEditingController();
  final TextEditingController _weatherConditionController =
      TextEditingController();
  final TextEditingController _observationsController = TextEditingController();

  List<File?> images = List.filled(5, null);
  String weatherShowText = 'Weather Condition';

  Future<void> selectImage(int index) async {
    final pickedFile = await pickImage();
    if (pickedFile != null) {
      setState(() {
        images[index] = File(pickedFile.path);
      });
    }
  }

  List<TextEditingController> plannedTasksControllers = [];
  List<TextEditingController> materialsControllers = [];

  List<WeatherItem> weatherModes = [
    WeatherItem(tag: 'Rainy', iconData: Icons.thunderstorm_rounded),
    WeatherItem(tag: 'Sunny', iconData: Icons.sunny),
    WeatherItem(tag: 'Cloudy', iconData: Icons.cloud),
  ];
  bool dropdownOpen = false;

  @override
  void initState() {
    super.initState();
    addNewTask(' ');
    addNewMaterial(' ');
    final log = widget.log;
    if (log != null) {
      _weatherConditionController.text =
          'Weather Condition : ${log.weatherCondition}';
      weatherShowText = _weatherConditionController.text;
      _numberOfWorkersController.text = log.numberOfWorkers.toString();
      _observationsController.text = log.observations;
      log.materialsAvailable.map((material) {
        addNewMaterial(material);
      });
      log.plannedTasks.map((task) {
        addNewTask(task.plannedTask);
      });
      setState(() {});
    }
  }

  void addNewTask(String task) {
    plannedTasksControllers.add(TextEditingController(text: task));
    setState(() {});
  }

  void addNewMaterial(String material) {
    materialsControllers.add(TextEditingController(text: material));
    setState(() {});
  }

  void removeTask(int index) {
    if (plannedTasksControllers.length > 1) {
      plannedTasksControllers.removeAt(index);
      setState(() {});
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('At least one task is required.')));
    }
  }

  void removeMaterial(int index) {
    if (materialsControllers.length > 1) {
      materialsControllers.removeAt(index);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('At least one material is required.')),
      );
    }
  }

  @override
  void dispose() {
    _numberOfWorkersController.dispose();
    _weatherConditionController.dispose();
    _observationsController.dispose();
    plannedTasksControllers.clear();
    materialsControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.log != null ? 'Edit Log' : 'Create Log'),
        automaticallyImplyLeading: false,
        leading: null,
        actions: [
          IconButton(onPressed: widget.onClose, icon: Icon(Icons.close)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Input the required details into the fields.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  widget.log != null ? SizedBox(height: 24) : SizedBox.shrink(),
                  SizedBox(height: 16),
                  FieldEditor(
                    hintText: 'Number of Workers',
                    controller: _numberOfWorkersController,
                    textInputType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  PseudoEditor(
                    hintText: weatherShowText,
                    onTap: () {
                      setState(() {
                        dropdownOpen = !dropdownOpen;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  /// Dropdown (Visible only when dropdownOpen is true)
                  if (dropdownOpen)
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              weatherModes.map((mode) {
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  title: Text(mode.tag),
                                  onTap: () {
                                    setState(() {
                                      _weatherConditionController.text =
                                          mode.tag;
                                      weatherShowText =
                                          'Weather Condition : ${mode.tag}';
                                      dropdownOpen = false;
                                    });
                                  },
                                  trailing: Icon(mode.iconData),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Materials Available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...List.generate(materialsControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskListItem(
                        index: index,
                        controller: materialsControllers[index],
                        isRemovable: materialsControllers.length > 1,
                        onRemove: () => removeMaterial(index),
                      ),
                    );
                  }),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      addNewMaterial(' ');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppPalette.borderColor,
                          width: 3,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          'Add another material',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Scheduling Planned tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...List.generate(plannedTasksControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskListItem(
                        index: index,
                        controller: plannedTasksControllers[index],
                        isRemovable: plannedTasksControllers.length > 1,
                        onRemove: () => removeTask(index),
                      ),
                    );
                  }),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      addNewTask(' ');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppPalette.borderColor,
                          width: 3,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          'Add another task',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Select pre-work Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
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

            SizedBox(height: 16),
            Divider(indent: 16, endIndent: 16),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //SizedBox(height: 16),
                  FieldEditor(
                    hintText: 'Observation & Notes',
                    controller: _observationsController,
                    minLines: 5,
                  ),
                  SizedBox(height: 24),
                  GradientButton(
                    onClick: () {
                      //final dateTimeInput = DateTime.now();
                      final List<DateTime> newDateTimeInputList = [];
                      if (widget.log == null) {
                        newDateTimeInputList.add(DateTime.now());
                      } else {
                        newDateTimeInputList.addAll(widget.log!.dateTimeList);
                      }
                      widget.onCompleted(
                        DailyLog(
                          id: newDateTimeInputList[0].toIso8601String(),
                          dateTimeList: newDateTimeInputList,
                          numberOfWorkers: int.parse(
                            _numberOfWorkersController.text.trim(),
                          ),
                          weatherCondition:
                              _weatherConditionController.text.trim(),
                          materialsAvailable:
                              materialsControllers
                                  .map((controller) => controller.text)
                                  .toList(),
                          plannedTasks:
                              plannedTasksControllers
                                  .map(
                                    (controller) => LogTask(
                                      plannedTask: controller.text,
                                      percentCompleted: 0.0,
                                    ),
                                  )
                                  .toList(),
                          startingImageUrl: ['', '', '', '', ''],
                          endingImageUrl: ['', '', '', '', ''],
                          observations: '${_observationsController.text}\n\n\n',
                          isConfirmed: false,
                        ),
                      );
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

class WeatherItem {
  final String tag;
  final IconData iconData;

  const WeatherItem({required this.tag, required this.iconData});
}

//  Pre-Work
//  1. Date & Time of Opening Log
//  2. Number of Workers Present
//  2. Weather Condition - Popup
//  5. Materials Available
//  3. Scheduling Planned tasks - Task | Assigned to | (Add Task is a Popup)
//  9. Site Photos - Before
//  0. Notes or Observations
//  6.

//  Post-Work
//  1. Date & Time of Closing Log
//  3. Number of Workers at Completion
//  2. Select Status of Each task
//  4. Materials Used
//  5. Challenges/Issues Faced
//  9. Site Photos - After
//  0. Notes or Observations
//  6.

//  Panned Task
//  1. Name of task
//  2. Assigned to
//  3.
