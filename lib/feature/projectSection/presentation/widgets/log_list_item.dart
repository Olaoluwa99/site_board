import 'package:flutter/material.dart';
import 'package:site_board/core/theme/app_palette.dart';

import '../../../../../core/utils/format_date.dart';
import '../../domain/DailyLog.dart';

class LogListItem extends StatelessWidget {
  final DailyLog log;
  final bool isEditable;
  final IconData weatherIcon;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  const LogListItem({
    required this.log,
    required this.isEditable,
    required this.weatherIcon,
    required this.onEdit,
    required this.onConfirm,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            color: AppPalette.borderColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDateDDMMYYYYHHMM(log.dateTimeList[0]),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(weatherIcon),
                  ],
                ),
                //Text(log.weatherCondition),
                Divider(),
                Text(
                  log.observations,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Divider(),
                isEditable
                    ? Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        LogListItemButton(
                          text: 'Confirm',
                          iconData: Icons.check,
                          onClick: onConfirm,
                        ),
                        LogListItemButton(
                          text: 'Modify',
                          iconData: Icons.edit,
                          onClick: onEdit,
                        ),
                        LogListItemButton(
                          text: 'Delete',
                          iconData: Icons.delete,
                          onClick: onDelete,
                        ),
                      ],
                    )
                    : Text(
                      'Score: ${log.workScore}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogListItemButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final VoidCallback onClick;
  const LogListItemButton({
    required this.text,
    required this.iconData,
    required this.onClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onClick,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: 16),
              SizedBox(width: 4),
              Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
