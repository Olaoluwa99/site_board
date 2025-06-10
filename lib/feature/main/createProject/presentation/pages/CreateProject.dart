import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/core/utils/show_snackbar.dart';

import '../../../home/presentation/widgets/field_editor.dart';

class CreateProjectDialog extends StatefulWidget {
  final void Function(String selectedName, String outputModes) onCompleted;
  const CreateProjectDialog({required this.onCompleted, super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final TextEditingController _textController = TextEditingController();
  String? selectedMode;

  List<String> modes = ['None', 'Password', 'Approval by Admin'];
  bool dropdownOpen = false;

  @override
  void dispose() {
    _textController.dispose();
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
            controller: _textController,
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

          /// Dropdown (Visible only when dropdownOpen is true)
          if (dropdownOpen)
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      modes.map((mode) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(mode),
                          onTap: () {
                            setState(() {
                              selectedMode = mode;
                              dropdownOpen = false;
                            });
                          },
                          trailing: mode != 'None' ? Icon(Icons.lock) : null,
                        );
                      }).toList(),
                ),
                Divider(),
              ],
            ),

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
                if (_textController.text.isNotEmpty && selectedMode != null) {
                  widget.onCompleted(_textController.text, selectedMode!);
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
