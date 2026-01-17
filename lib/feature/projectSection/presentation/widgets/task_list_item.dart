import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';

class TaskListItem extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final VoidCallback onRemove;
  final bool isRemovable;
  const TaskListItem({
    required this.index,
    required this.controller,
    required this.onRemove,
    required this.isRemovable,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderColor =
        theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
        theme.dividerColor;

    border([Color? color]) => UnderlineInputBorder(
      borderSide: BorderSide(color: color ?? defaultBorderColor, width: 3),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            maxLines: null,
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              //prefixText: '${index + 1}.  ',
              prefix: Text('${index + 1}.  '),
              border: border(),
              enabledBorder: border(),
              focusedBorder: border(AppPalette.gradient2),
              errorBorder: border(AppPalette.errorColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (isRemovable)
          IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: onRemove,
          ),
      ],
    );
  }
}
