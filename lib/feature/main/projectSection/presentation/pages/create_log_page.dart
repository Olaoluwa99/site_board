import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/feature/main/home/presentation/widgets/pseudo_editor.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/pick_image.dart';
import '../../../home/presentation/widgets/field_editor.dart';

class CreateLogPage extends StatefulWidget {
  final VoidCallback onClose;
  const CreateLogPage({required this.onClose, super.key});

  @override
  State<CreateLogPage> createState() => _CreateLogPageState();
}

class _CreateLogPageState extends State<CreateLogPage> {
  final TextEditingController _textController = TextEditingController();
  //File? image;
  // Example variables you need in your state:
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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Log'),
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
                  SizedBox(height: 24),
                  PseudoEditor(hintText: 'Date & Time', onTap: () {}),
                  SizedBox(height: 16),
                  FieldEditor(
                    hintText: 'Number of Workers',
                    controller: _textController,
                    textInputType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  PseudoEditor(hintText: 'Weather Condition', onTap: () {}),
                  SizedBox(height: 16),
                  FieldEditor(
                    hintText: 'Materials Available',
                    controller: _textController,
                    minLines: 5,
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  PseudoEditor(
                    hintText: 'Scheduling Planned tasks',
                    onTap: () {},
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
                                      child: Container(
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
                  SizedBox(height: 16),
                  FieldEditor(
                    hintText: 'Observation & Notes',
                    controller: _textController,
                    minLines: 5,
                  ),
                  SizedBox(height: 24),
                  GradientButton(onClick: () {}, text: 'Upload'),
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
