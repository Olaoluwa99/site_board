import 'dart:io';

import 'package:flutter/material.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/activate_field_editor.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/pseudo_editor.dart';

import '../../../../core/common/widgets/gradient_button.dart';
import '../../../../core/utils/pick_image.dart';
import '../../domain/entities/project.dart';
import '../widgets/field_editor.dart';
import '../widgets/image_item_project.dart';
import '../widgets/project_security_item.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  //final TextEditingController _projectNameController = TextEditingController();
  String? selectedMode;
  bool dropdownOpen = false;
  final adminEmailList = [
    'olaol@mail.com',
    'germanW@mail.com',
    'gazeer@ymail.com',
  ];

  @override
  void initState() {
    super.initState();
    selectedMode = 'None'; //widget.project.
    //adminEmailList = widget.project.adminEmailList;
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void updateDetails() {
    /**/
    if (selectedMode == 'Password' && _passwordController.text.isEmpty) {
      showSnackBar(context, 'Password field cannot be empty');
    } else {
      //
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
                minLines: 5,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Current admins',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...List.of(adminEmailList).map((item) {
                return Row(
                  children: [
                    Text(item, style: TextStyle(fontSize: 16)),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        adminEmailList.remove(item);
                        setState(() {});
                      },
                      icon: Icon(Icons.cancel),
                    ),
                  ],
                );
              }),
              SizedBox(height: 8),
              ActivateFieldEditor(
                hintText: 'Add admin Email',
                controller: _emailController,
                onClick: () {
                  if (_emailController.text.isNotEmpty) {
                    adminEmailList.add(_emailController.text.trim());
                    _emailController.text = '';
                    setState(() {});
                  } else {
                    showSnackBar(
                      context,
                      'Input a value into field and try again.',
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Access type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              PseudoEditor(
                text: 'Security mode: $selectedMode',
                onTap: () {
                  setState(() {
                    dropdownOpen = !dropdownOpen;
                  });
                },
              ),
              SizedBox(height: 16),
              selectedMode == 'Password'
                  ? Column(
                    children: [
                      FieldEditor(
                        hintText: 'Input password',
                        controller: _passwordController,
                        textInputType: TextInputType.visiblePassword,
                      ),
                      SizedBox(height: 16),
                    ],
                  )
                  : SizedBox.shrink(),
              ProjectSecurityItem(
                dropdownOpen: dropdownOpen,
                onCompleted: (outputMode) {
                  setState(() {
                    selectedMode = outputMode;
                    dropdownOpen = false; // Close after selection
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'Pending access',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              GradientButton(onClick: updateDetails, text: 'Update'),
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
