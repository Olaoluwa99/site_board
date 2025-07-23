import 'package:flutter/material.dart';
import 'package:site_board/core/common/widgets/default_button.dart';

import '../../../../core/common/widgets/gradient_button.dart';

class OfflineDialog extends StatelessWidget {
  final VoidCallback onCompleted;
  final VoidCallback onDismiss;
  const OfflineDialog({
    required this.onCompleted,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('No Internet Connection!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Text(
            'You\'re currently offline. Please check your internet connection and try again, or continue viewing this project in offline mode if available.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          GradientButton(onClick: onCompleted, text: 'View Offline'),
          SizedBox(height: 16),
          DefaultButton(onClick: onDismiss, text: 'Dismiss'),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
