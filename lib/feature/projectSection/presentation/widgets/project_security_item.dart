import 'package:flutter/material.dart';

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
    List<String> modes = ['None', 'Password', 'Approval by Admin'];

    return dropdownOpen
        ? Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  modes.map((mode) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(mode),
                      onTap: () {
                        onCompleted(mode);
                      },
                      trailing: mode != 'None' ? Icon(Icons.lock) : null,
                    );
                  }).toList(),
            ),
            Divider(),
          ],
        )
        : SizedBox.shrink();
  }
}
