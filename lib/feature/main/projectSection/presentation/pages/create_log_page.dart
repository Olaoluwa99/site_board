import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/feature/main/home/presentation/widgets/pseudo_editor.dart';

import '../../../home/presentation/widgets/field_editor.dart';

class CreateLogPage extends StatefulWidget {
  final VoidCallback onClose;
  const CreateLogPage({required this.onClose, super.key});

  @override
  State<CreateLogPage> createState() => _CreateLogPageState();
}

class _CreateLogPageState extends State<CreateLogPage> {
  final TextEditingController _textController = TextEditingController();

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
        child: Padding(
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
              PseudoEditor(hintText: 'Scheduling Planned tasks', onTap: () {}),
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
