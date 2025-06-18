import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:site_board/feature/projectSection/presentation/pages/view_log_page.dart';

import '../../../../../core/utils/show_rounded_bottom_sheet.dart';
import '../../domain/entities/daily_log.dart';
import '../widgets/log_list_item.dart';
import 'confirm_log_page.dart';
import 'create_log_page.dart';

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
    dateTimeList: [DateTime.now()],
    numberOfWorkers: 5,
    weatherCondition: 'Cloudy',
    materialsAvailable: [
      'A Bag of Cement',
      'One Pound of 2mm rod',
      '2 Gallons of water.',
    ],
    plannedTasks: [
      LogTask(plannedTask: 'Clearing of the Site', percentCompleted: 20),
      LogTask(plannedTask: 'Packing of Debris', percentCompleted: 35),
      LogTask(plannedTask: 'Incineration of content', percentCompleted: 80),
      LogTask(plannedTask: 'Setting out', percentCompleted: 70),
      LogTask(
        plannedTask: 'Excavation of the 25mm surface soil',
        percentCompleted: 100,
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
    isConfirmed: false,
  );

  final barWidth = 15.0;

  List<DailyLog> dailyLogsList = [];

  @override
  void initState() {
    super.initState();
    dailyLogsList.add(sampleLog);
    dailyLogsList.add(sampleLog);
    dailyLogsList.add(sampleLog);
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
            Text(
              '7-day Log chart',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: AppPalette.borderColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(
                      border: const Border(
                        top: BorderSide.none,
                        right: BorderSide.none,
                        left: BorderSide(
                          width: 3,
                          color: AppPalette.whiteColor,
                        ),
                        bottom: BorderSide(
                          width: 3,
                          color: AppPalette.whiteColor,
                        ),
                      ),
                    ),
                    groupsSpace: 10,
                    barGroups: [
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: 30,
                            width: barWidth,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: 70,
                            width: barWidth,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: 80,
                            width: barWidth,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: 20,
                            width: barWidth,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 5,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: 100,
                            width: barWidth,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 6,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: 40,
                            width: barWidth,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 7,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: 60,
                            width: barWidth,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                    IconData weatherIcon;
                    if (item.weatherCondition == 'Rainy') {
                      weatherIcon = Icons.thunderstorm;
                    } else if (item.weatherCondition == 'Cloudy') {
                      weatherIcon = Icons.cloud;
                    } else {
                      weatherIcon = Icons.sunny;
                    }
                    return LogListItem(
                      log: item,
                      isEditable: !item.isConfirmed,
                      onEdit: () {
                        showRoundedBottomSheet(
                          context: context,
                          backgroundColor: AppPalette.backgroundColor,
                          builder:
                              (context) => SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: CreateLogPage(
                                  log: item,
                                  onCompleted: (retrievedLog) {
                                    dailyLogsList.add(retrievedLog);
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  onClose: () => Navigator.pop(context),
                                ),
                              ),
                        );
                      },
                      onDelete: () {},
                      onConfirm: () {
                        showRoundedBottomSheet(
                          context: context,
                          backgroundColor: AppPalette.backgroundColor,
                          builder:
                              (context) => SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: ConfirmLogPage(
                                  log: item,
                                  onCompleted: (retrievedLog) {
                                    dailyLogsList.add(retrievedLog);
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  onClose: () => Navigator.pop(context),
                                ),
                              ),
                        );
                      },
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
                      weatherIcon: weatherIcon,
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

//  Project settings - Change Security, Accept user, Delete Project, Transfer Project
//
