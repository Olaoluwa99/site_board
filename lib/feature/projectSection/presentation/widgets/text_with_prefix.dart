import 'package:flutter/material.dart';

class TextWithPrefix extends StatelessWidget {
  final String prefix;
  final String text;
  final double textSize;
  const TextWithPrefix({
    required this.prefix,
    required this.text,
    required this.textSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: textSize),
        children: [
          TextSpan(
            text: '$prefix: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}
