import 'package:flutter/material.dart';

import '../../../../core/common/widgets/gradient_button.dart';

class AdminPermissionNotifier extends StatelessWidget {
  final VoidCallback onCompleted;
  const AdminPermissionNotifier({required this.onCompleted, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Access Pending!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Text(
            'This project is restricted and requires admin approval to view. A request has already been sent to the project administrator. You’ll gain access as soon as it is approved.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          GradientButton(onClick: onCompleted, text: 'Got it'),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
