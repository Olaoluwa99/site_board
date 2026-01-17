import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/core/utils/pick_image.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/image_item_project.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/project_security_item.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/pseudo_editor.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/field_editor.dart';

class CreateProjectPage extends StatefulWidget {
  final void Function(Project project, File? coverImage) onCompleted;
  const CreateProjectPage({required this.onCompleted, super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController _projectPasswordController =
      TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  String? selectedMode;

  File? image;
  bool dropdownOpen = false;
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
  }

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
    _locationController.dispose();
    _projectDescriptionController.dispose();
    _projectPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Project'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageItemProject(
                imageAsFile: image,
                imageAsLink: '',
                onSelect: selectImage,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              FieldEditor(
                hintText: 'Project Name',
                controller: _projectNameController,
              ),
              SizedBox(height: 16),
              FieldEditor(
                hintText: 'Location (Optional)',
                controller: _locationController,
              ),
              SizedBox(height: 16),
              FieldEditor(
                hintText: 'Description',
                controller: _projectDescriptionController,
                minLines: 3,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Access Type',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              PseudoEditor(
                text: selectedMode ?? 'Choose Security Mode',
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
                    dropdownOpen = false; // Close after selection
                  });
                },
              ),

              if (selectedMode == Constants.securityPassword)
                Column(
                  children: [
                    SizedBox(height: 16),
                    FieldEditor(
                      hintText: 'Input Password',
                      controller: _projectPasswordController,
                      textInputType: TextInputType.visiblePassword,
                    ),
                  ],
                ),

              SizedBox(height: 32),

              /// Create Button
              GradientButton(
                onClick: () {
                  // Close dropdown if open
                  if (dropdownOpen) {
                    setState(() {
                      dropdownOpen = false;
                    });
                  } else {
                    // Validation
                    if (_projectNameController.text.isNotEmpty &&
                        _projectDescriptionController.text.isNotEmpty &&
                        selectedMode != null) {
                      if (selectedMode == Constants.securityPassword &&
                          _projectPasswordController.text.isEmpty) {
                        showSnackBar(
                          context,
                          'Password is required for Password Security Mode',
                        );
                        return;
                      }

                      final projectId = const Uuid().v4();
                      final newProject = Project(
                        id: projectId,
                        projectName: _projectNameController.text.trim(),
                        creatorId: userId,
                        createdDate: DateTime.now(),
                        endDate: null,
                        lastUpdated: DateTime.now(),
                        isActive: true,
                        dailyLogs: [],
                        location: _locationController.text.trim(),
                        coverPhotoUrl:
                            '', // Will be handled by Bloc if image provided
                        teamAdminIds: [
                          projectId,
                        ], // Logic from existing code, verified?
                        teamMembers: [],
                        description: _projectDescriptionController.text.trim(),
                        projectLink: 'https://site-board.com/$projectId/',
                        projectSecurityType:
                            selectedMode ?? Constants.securityNone,
                        projectPassword:
                            selectedMode == Constants.securityPassword
                                ? _projectPasswordController.text.trim()
                                : '',
                      );

                      widget.onCompleted(newProject, image);
                      Navigator.of(context).pop();
                    } else {
                      showSnackBar(
                        context,
                        'Please fill in all required fields (Name, Description, Mode)',
                      );
                    }
                  }
                },
                text: 'Create Project',
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
