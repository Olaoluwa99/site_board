import 'package:flutter/material.dart';
import 'package:site_board/core/theme/app_palette.dart';

class PseudoEditor extends StatelessWidget {
  final String preText;
  final String text;
  final VoidCallback onTap;
  const PseudoEditor({
    this.preText = '',
    required this.text,
    required this.onTap,
    super.key,
  });

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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                preText != ''
                    ? Text(
                      preText,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    )
                    : SizedBox.shrink(),
                Text(
                  text,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
