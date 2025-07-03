import 'package:flutter/material.dart';

class TextWithPrefix extends StatelessWidget {
  final String prefix;
  final String text;
  const TextWithPrefix({required this.prefix, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        //style: const TextStyle(fontSize: 16),
        children: [
          TextSpan(
            text: prefix,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}
