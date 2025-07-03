import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

class ImageItem extends StatelessWidget {
  final int index;
  final File? imageAsFile;
  final String imageAsLink;
  final VoidCallback onSelect;

  const ImageItem({
    required this.index,
    required this.imageAsFile,
    required this.imageAsLink,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageAsFile != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          imageAsFile!,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
        ),
      );
    } else if (imageAsLink.trim().isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageAsLink,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultPlaceholder();
          },
        ),
      );
    } else {
      imageWidget = _buildDefaultPlaceholder();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: onSelect,
        child: SizedBox(width: 150, height: 150, child: imageWidget),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: AppPalette.borderColor,
        dashPattern: [10, 5],
        strokeWidth: 2,
        padding: EdgeInsets.zero,
        radius: Radius.circular(12),
        strokeCap: StrokeCap.round,
      ),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 44),
            SizedBox(height: 15),
            Text(
              'Select\nimage ${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
