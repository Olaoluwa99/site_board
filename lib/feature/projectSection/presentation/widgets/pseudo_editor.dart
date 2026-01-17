import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final border =
        theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
        theme.dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 3),
          color: theme.inputDecorationTheme.fillColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                preText != ''
                    ? Text(
                      preText,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    )
                    : SizedBox.shrink(),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
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
