import 'package:flutter/material.dart';

class TextListItem extends StatelessWidget {
  final String item;
  final int index;
  const TextListItem({required this.item, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${index + 1}.  ', style: TextStyle(fontSize: 16)),
            Text(item, style: TextStyle(fontSize: 16)),
          ],
        ),
        Divider(),
      ],
    );
  }
}
