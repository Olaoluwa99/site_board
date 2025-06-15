import 'package:flutter/material.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:site_board/feature/main/projectSection/domain/DailyLog.dart';
import 'package:site_board/feature/main/projectSection/presentation/pages/create_log_page.dart';
import 'package:site_board/feature/main/projectSection/presentation/pages/view_log_page.dart';
import 'package:site_board/feature/main/projectSection/presentation/widgets/log_list_item.dart';

import '../../../../../core/utils/show_rounded_bottom_sheet.dart';

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
  final sampleLog = DailyLog(
    id: '1234',
    dateTime: DateTime.now(),
    numberOfWorkers: 5,
    weatherCondition: 'Rainy',
    materialsAvailable: [
      'A Bag of Cement',
      'One Pound of 2mm rod',
      '2 Gallons of water.',
    ],
    plannedTasks: [
      LogTask(plannedTask: 'Clearing of the Site', status: 'Done'),
      LogTask(plannedTask: 'Packing of Debris', status: 'Not started'),
      LogTask(plannedTask: 'Incineration of content', status: 'Not started'),
      LogTask(plannedTask: 'Setting out', status: 'Not started'),
      LogTask(
        plannedTask: 'Excavation of the 25mm surface soil',
        status: 'Not started',
      ),
    ],
    startingImageUrl: [
      'https://i.postimg.cc/52b5NS67/Screenshot-from-2025-04-21-21-42-35.png',
      'https://i.postimg.cc/52b5NS67/Screenshot-from-2025-04-21-21-42-35.png',
      'https://i.postimg.cc/52b5NS67/Screenshot-from-2025-04-21-21-42-35.png',
      'https://i.postimg.cc/52b5NS67/Screenshot-from-2025-04-21-21-42-35.png',
      '',
    ],
    endingImageUrl: [
      'https://i.postimg.cc/D0CWvLDD/Screenshot-from-2025-06-13-19-30-22.png',
      'https://i.postimg.cc/D0CWvLDD/Screenshot-from-2025-06-13-19-30-22.png',
      'https://i.postimg.cc/D0CWvLDD/Screenshot-from-2025-06-13-19-30-22.png',
      'https://i.postimg.cc/D0CWvLDD/Screenshot-from-2025-06-13-19-30-22.png',
      'https://i.postimg.cc/D0CWvLDD/Screenshot-from-2025-06-13-19-30-22.png',
    ],
    observations:
        'At 12:30 PM, it was observed that the formwork for the second-floor slab was not properly supported on the western edge. Immediate reinforcement was instructed to prevent potential collapse or misalignment. Additionally, site cleanliness around the mixing area needs improvement to avoid safety hazards.\n'
        'The bricklaying team completed 70% of the ground floor internal walls. However, some mortar joints on the eastern partition wall appear uneven and will require correction during inspection. Supervisor notified for follow-up.\n'
        'Rainfall started around 2:45 PM and interrupted concreting works on the external columns. Tarpaulin covers were quickly deployed, but some areas may need surface retouching. Work is scheduled to resume once weather permits.',
  );

  List<DailyLog> dailyLogsList = [];

  @override
  void initState() {
    super.initState();
    dailyLogsList.add(sampleLog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titleText)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showRoundedBottomSheet(
            context: context,
            backgroundColor: AppPalette.backgroundColor,
            builder:
                (context) => SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: CreateLogPage(
                    isEdit: false,
                    onClose: () => Navigator.pop(context),
                    onCompleted: (retrievedLog) {
                      dailyLogsList.add(retrievedLog);
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ),
          );
        },
        label: const Text('Create Log'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 20),
            dailyLogsList.isNotEmpty
                ? ListView.builder(
                  itemCount: dailyLogsList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = dailyLogsList[index];
                    return LogListItem(
                      log: item,
                      isEditable: true,
                      onEdit: () {},
                      onDelete: () {},
                      onConfirm: () {},
                      onOpen: () {
                        showRoundedBottomSheet(
                          context: context,
                          backgroundColor: AppPalette.backgroundColor,
                          builder:
                              (context) => SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: ViewLogPage(
                                  log: item,
                                  onClose: () => Navigator.pop(context),
                                ),
                              ),
                        );
                      },
                    );
                  },
                )
                : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      'Project Logs are currently empty. Click \'Create Log\' to Start a Log for the Day',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
