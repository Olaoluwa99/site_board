import 'package:flutter/material.dart';
import 'package:site_board/core/theme/app_palette.dart';

class ActivateFieldEditor extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onClick;

  const ActivateFieldEditor({
    required this.hintText,
    required this.controller,
    required this.onClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      12,
    ); // Adjust to match the TextFormField's default

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(borderRadius: borderRadius),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return '$hintText is missing!';
              }
              return null;
            },
            controller: controller,
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: onClick,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: EdgeInsets.symmetric(horizontal: 20),
              backgroundColor: AppPalette.gradient1,
            ),
            child: const Icon(Icons.check),
          ),
        ),
      ],
    );
  }
}
