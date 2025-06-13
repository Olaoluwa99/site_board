import 'package:flutter/material.dart';
import 'package:site_board/core/theme/app_palette.dart';

class PseudoEditor extends StatelessWidget {
  final String hintText;
  final VoidCallback onTap;
  const PseudoEditor({required this.hintText, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.borderColor, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(hintText, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
