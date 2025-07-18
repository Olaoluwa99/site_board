import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/core/utils/show_snackbar.dart';

import 'field_editor.dart';

class ProjectPasswordDialog extends StatefulWidget {
  final void Function(String passwordText) onCompleted;
  const ProjectPasswordDialog({required this.onCompleted, super.key});

  @override
  State<ProjectPasswordDialog> createState() => _ProjectPasswordDialogState();
}

class _ProjectPasswordDialogState extends State<ProjectPasswordDialog> {
  final TextEditingController _projectPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _projectPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Project Password!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Text(
            'This project is protected for security reasons. To continue and view the contents of this project, please enter the correct password. If you don’t have the password, kindly contact the project owner or administrator for access.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          FieldEditor(
            hintText: 'Input Password',
            controller: _projectPasswordController,
          ),
          SizedBox(height: 20),
          GradientButton(
            onClick: () {
              if (_projectPasswordController.text.isNotEmpty) {
                widget.onCompleted(_projectPasswordController.text.trim());
              } else {
                showSnackBar(
                  context,
                  'Ensure a password field is filled and Try again',
                );
              }
            },
            text: 'Submit',
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
