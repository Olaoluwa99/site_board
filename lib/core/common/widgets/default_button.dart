import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final VoidCallback onClick;
  final String text;
  final Color? textColor;
  const DefaultButton({
    required this.onClick,
    required this.text,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor:
              textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
    );
  }
}
