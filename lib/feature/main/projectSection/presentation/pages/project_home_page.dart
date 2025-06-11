import 'package:flutter/material.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:site_board/feature/main/projectSection/presentation/pages/create_log_page.dart';

class ProjectHomePage extends StatefulWidget {
  final String titleText;
  static route(String titleText) => MaterialPageRoute(
    builder: (context) => ProjectHomePage(titleText: titleText),
  );
  const ProjectHomePage({required this.titleText, super.key});

  @override
  State<ProjectHomePage> createState() => _ProjectHomePageState();
}

class _ProjectHomePageState extends State<ProjectHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titleText)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            isDismissible: false,
            useSafeArea: true,
            backgroundColor: AppPalette.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            builder: (context) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Expanded(
                      child: CreateLogPage(
                        onClose: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        label: const Text('Create Log'),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppPalette.gradient3,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Previous Logs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    'Project Logs are currently empty. Click \'Create Log\' to Start a Log for the Day',
                    style: TextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
