import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/project_security_item.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../widgets/field_editor.dart';

class CreateProjectDialog extends StatefulWidget {
  final void Function(Project project) onCompleted;
  const CreateProjectDialog({required this.onCompleted, super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final TextEditingController _projectPasswordController =
      TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  String? selectedMode;

  bool dropdownOpen = false;
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Project!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FieldEditor(
            hintText: 'Enter a Project name',
            controller: _projectNameController,
          ),
          SizedBox(height: 16),
          FieldEditor(
            hintText: 'Enter a Project description',
            controller: _projectDescriptionController,
            minLines: 3,
          ),
          SizedBox(height: 16),

          /// Choose Mode Button with Dropdown
          GestureDetector(
            onTap: () {
              setState(() {
                dropdownOpen = !dropdownOpen;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedMode ?? 'Choose Mode',
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    dropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),
          Divider(),

          /*ProjectSecurityItem(
            inputDropdownOpen: dropdownOpen,
            onCompleted: (outputMode) {
              selectedMode = outputMode;
            },
          ),*/
          ProjectSecurityItem(
            dropdownOpen: dropdownOpen,
            onCompleted: (outputMode) {
              setState(() {
                selectedMode = outputMode;
                dropdownOpen = false; // Close after selection
              });
            },
          ),

          selectedMode == 'Password'
              ? Column(
                children: [
                  SizedBox(height: 16),
                  FieldEditor(
                    hintText: 'Input Password',
                    controller: _projectNameController,
                  ),
                ],
              )
              : SizedBox.shrink(),

          SizedBox(height: 20),

          /// Create Button
          GradientButton(
            onClick: () {
              // Close dropdown if open
              if (dropdownOpen) {
                setState(() {
                  dropdownOpen = false;
                });
              } else {
                // Close dialog
                if (_projectNameController.text.isNotEmpty &&
                    _projectDescriptionController.text.isNotEmpty &&
                    selectedMode != null) {
                  widget.onCompleted(
                    Project(
                      projectName: _projectNameController.text,
                      creatorId: userId,
                      createdDate: DateTime.now(),
                      endDate: null,
                      lastUpdated: DateTime.now(),
                      isActive: true,
                      dailyLogs: [],
                      location: '',
                      coverPhotoUrl: '',
                      teamMembers: [],
                      description: _projectDescriptionController.text,
                      projectLink:
                          'https://site-board.com/${const Uuid().v4()}/',
                      projectSecurityType: selectedMode ?? 'None',
                      projectPassword:
                          selectedMode == 'Password'
                              ? _projectPasswordController.text.trim()
                              : '',
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  showSnackBar(
                    context,
                    'Ensure a fields are filled and Try again',
                  );
                }
              }
            },
            text: 'Create Project',
          ),
        ],
      ),
    );
  }
}

//
//  Name of Project
//  Join Group type - None, Password, Approval by Admin
//  If password, Field to Input password - Field to Confirm password
