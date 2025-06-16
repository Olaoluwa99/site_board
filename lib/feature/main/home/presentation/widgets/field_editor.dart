import 'package:flutter/material.dart';

class FieldEditor extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final int minLines;
  const FieldEditor({
    required this.hintText,
    required this.controller,
    this.textInputType = TextInputType.text,
    this.minLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: hintText),
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText is missing!';
        }
        return null;
      },
      controller: controller,
      maxLines: null,
      minLines: minLines,
      keyboardType: textInputType,
    );
  }
}
