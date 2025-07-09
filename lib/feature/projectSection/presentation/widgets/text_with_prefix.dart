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
    return RichText(
      text: TextSpan(
        //style: const TextStyle(fontSize: 16),
        children: [
          TextSpan(
            text: '$prefix: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: textSize),
          ),
          TextSpan(text: text, style: TextStyle(fontSize: textSize)),
        ],
      ),
    );
  }
}
