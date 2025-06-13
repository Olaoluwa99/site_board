import 'package:flutter/material.dart';

Future<T?> showRoundedBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool showDragHandle = true,
  bool isDismissible = false,
  bool useSafeArea = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    isDismissible: isDismissible,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor ?? Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
    ),
    builder: builder,
  );
}
