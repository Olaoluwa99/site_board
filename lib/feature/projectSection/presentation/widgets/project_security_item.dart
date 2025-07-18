import 'package:flutter/material.dart';
import 'package:site_board/core/constants/constants.dart';

class ProjectSecurityItem extends StatelessWidget {
  final bool dropdownOpen;
  final void Function(String securityState) onCompleted;

  const ProjectSecurityItem({
    required this.dropdownOpen,
    required this.onCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return dropdownOpen
        ? Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  Constants.securityModes.map((mode) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(mode),
                      onTap: () {
                        onCompleted(mode);
                      },
                      trailing:
                          mode != Constants.securityNone
                              ? Icon(Icons.lock)
                              : null,
                    );
                  }).toList(),
            ),
            Divider(),
          ],
        )
        : SizedBox.shrink();
  }
}
