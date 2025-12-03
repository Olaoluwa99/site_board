import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/activate_field_editor.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/pseudo_editor.dart';

import '../../../../core/common/widgets/gradient_button.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/pick_image.dart';
import '../../domain/entities/project.dart';
import '../bloc/project_bloc.dart';
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
  late TextEditingController _projectNameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _passwordController;
  final TextEditingController _emailController = TextEditingController();

  String? selectedMode;
  bool dropdownOpen = false;
  List<String> adminNames = [];

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController(text: widget.project.projectName);
    _locationController = TextEditingController(text: widget.project.location);
    _descriptionController = TextEditingController(text: widget.project.description);
    _passwordController = TextEditingController(text: widget.project.projectPassword);

    selectedMode = widget.project.projectSecurityType;

    adminNames = widget.project.teamMembers
        .where((m) => widget.project.teamAdminIds.contains(m.id) || m.isAdmin)
        .map((m) => m.name)
        .toList();
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
    if (selectedMode == Constants.securityPassword && _passwordController.text.isEmpty) {
      showSnackBar(context, 'Password field cannot be empty for Password Security mode');
      return;
    }

    final updatedProject = widget.project.copyWith(
      projectName: _projectNameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      projectSecurityType: selectedMode,
      projectPassword: selectedMode == Constants.securityPassword ? _passwordController.text.trim() : '',
    );

    context.read<ProjectBloc>().add(
      ProjectUpdate(
        project: updatedProject,
        coverImage: image,
      ),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project Details'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectLoading) {
            showLoaderDialog(context);
          }
          if (state is ProjectRetrieveSuccess) {
            Navigator.of(context, rootNavigator: true).pop();
            widget.onCompleted();
          }
          if (state is ProjectFailure) {
            Navigator.of(context, rootNavigator: true).pop();
            showSnackBar(context, state.error);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                Text(
                  'Current Admins',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                if (adminNames.isEmpty)
                  Text("No other admins assigned.", style: TextStyle(color: Colors.grey)),
                ...adminNames.map((name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text("• $name", style: TextStyle(fontSize: 16)),
                )),

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

                ProjectSecurityItem(
                  dropdownOpen: dropdownOpen,
                  onCompleted: (outputMode) {
                    setState(() {
                      selectedMode = outputMode;
                      dropdownOpen = false;
                    });
                  },
                ),

                if (selectedMode == Constants.securityPassword)
                  Column(
                    children: [
                      SizedBox(height: 16),
                      FieldEditor(
                        hintText: 'Input password',
                        controller: _passwordController,
                        textInputType: TextInputType.visiblePassword,
                      ),
                    ],
                  ),

                SizedBox(height: 24),
                GradientButton(onClick: updateDetails, text: 'Update Project'),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}