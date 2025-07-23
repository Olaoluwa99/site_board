import 'package:flutter/material.dart';

import '../../../../core/common/widgets/gradient_button.dart';

class MainAlertDialog extends StatelessWidget {
  final String title;
  final String text;
  final VoidCallback onDismiss;
  const MainAlertDialog({
    required this.title,
    required this.text,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Text(text, style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          GradientButton(onClick: onDismiss, text: 'Dismiss'),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
