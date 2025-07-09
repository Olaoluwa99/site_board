import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/pick_image.dart';
import '../../domain/entities/project.dart';
import '../widgets/field_editor.dart';
import '../widgets/image_item_project.dart';

class EditProjectDetail extends StatefulWidget {
  final Project project;
  final VoidCallback onClose;
  final VoidCallback onCompleted;
  const EditProjectDetail({
    required this.project,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<EditProjectDetail> createState() => _EditProjectDetailState();
}

class _EditProjectDetailState extends State<EditProjectDetail> {
  File? image;
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  //final TextEditingController _projectNameController = TextEditingController();

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project detail')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              ImageItemProject(
                imageAsFile: image,
                imageAsLink: widget.project.coverPhotoUrl ?? '',
                onSelect: selectImage,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              FieldEditor(
                hintText: 'Project name',
                controller: _projectNameController,
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 16),
              FieldEditor(
                hintText: 'Location',
                controller: _locationController,
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 16),
              FieldEditor(
                hintText: 'Description',
                controller: _descriptionController,
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 16),
              Text('Current admins'),
              SizedBox(height: 16),
              Text('Access type'),
              SizedBox(height: 16),
              Text('Pending access'),
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
