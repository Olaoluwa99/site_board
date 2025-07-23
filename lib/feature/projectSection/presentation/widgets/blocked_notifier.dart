import 'package:flutter/material.dart';

import '../../../../core/common/widgets/gradient_button.dart';

class BlockedNotifier extends StatelessWidget {
  final VoidCallback onCompleted;
  const BlockedNotifier({required this.onCompleted, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Access Denied!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Text(
            'You have been blocked from viewing this project. Please contact the project administrator if you believe this was a mistake or need further assistance.',
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
