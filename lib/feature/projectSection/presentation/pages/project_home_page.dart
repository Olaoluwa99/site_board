import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:site_board/feature/projectSection/presentation/pages/edit_project_detail.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_settings.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_summarizer.dart';
import 'package:site_board/feature/projectSection/presentation/pages/view_log_page.dart';
import 'package:site_board/feature/projectSection/presentation/pages/view_project_detail.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/about_project_card.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/show_bar_chart.dart';

import '../../../../../core/utils/show_rounded_bottom_sheet.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/project.dart';
import '../bloc/project_bloc.dart';
import '../widgets/log_list_item.dart';
import 'confirm_log_page.dart';
import 'create_log_page.dart';

class ProjectHomePage extends StatefulWidget {
  final Project project;
  final int projectIndex;
  final bool isLocal;
  static route({
    required Project project,
    required int projectIndex,
    required bool isLocal,
  }) => MaterialPageRoute(
    builder:
        (context) => ProjectHomePage(
          project: project,
          projectIndex: projectIndex,
          isLocal: isLocal,
        ),
  );
  const ProjectHomePage({
    required this.project,
    required this.projectIndex,
    required this.isLocal,
    super.key,
  });

  @override
  State<ProjectHomePage> createState() => _ProjectHomePageState();
}

class _ProjectHomePageState extends State<ProjectHomePage> {
  //List<DailyLog> updatedDailyLogsList = [];

  @override
  void initState() {
    super.initState();
    //updatedDailyLogsList.addAll(widget.project.dailyLogs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.projectName),
        actions: [
          IconButton(
            onPressed: () {
              showRoundedBottomSheet(
                context: context,
                backgroundColor: AppPalette.backgroundColor,
                builder:
                    (context) => SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ProjectSummarizer(
                        project: widget.project,
                        onClose: () => Navigator.pop(context),
                        onCompleted: () {
                          //Do Something
                          Navigator.pop(context);
                        },
                      ),
                    ),
              );
            },
            icon: Icon(Icons.note),
          ),
          IconButton(
            onPressed: () {
              showRoundedBottomSheet(
                context: context,
                backgroundColor: AppPalette.backgroundColor,
                builder:
                    (context) => SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ProjectSettings(
                        project: widget.project,
                        onClose: () => Navigator.pop(context),
                        onCompleted: () {
                          //Do Something
                          Navigator.pop(context);
                        },
                      ),
                    ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showRoundedBottomSheet(
            context: context,
            backgroundColor: AppPalette.backgroundColor,
            builder:
                (context) => SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: CreateLogPage(
                    projectId: widget.project.id,
                    onClose: () => Navigator.pop(context),
                    onCompleted: () {
                      //dailyLogsList.add(retrievedLog);
                      Navigator.pop(context);
                      //setState(() {});
                    },
                  ),
                ),
          );
        },
        label: const Text('Create Log'),
        icon: const Icon(Icons.add),
      ),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectLoading) {
            showLoaderDialog(context);
          }
          if (state is DailyLogUploadFailure ||
              state is ProjectRetrieveSuccess) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (state is DailyLogUploadFailure) {
            showSnackBar(context, state.error);
          }
          if (state is ProjectRetrieveSuccess) {
            //showSnackBar(context, 'File has been saved!');
            //widget.onCompleted(finishedDailyLog!);
            //updatedDailyLogsList = state.projects[widget.projectIndex].dailyLogs;
            setState(() {});
          }
        },
        child: SingleChildScrollView(
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
                  child: ShowBarChart(values: [20, 50, 70, 48, 39, 100, 15]),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'About Project',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AboutProjectCard(
                project: widget.project,
                onViewClicked: () {
                  showRoundedBottomSheet(
                    context: context,
                    backgroundColor: AppPalette.backgroundColor,
                    builder:
                        (context) => SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: ViewProjectDetail(
                            project: widget.project,
                            onClose: () => Navigator.pop(context),
                            onCompleted: () {
                              //Do Something
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  );
                },
                onEditClicked: () {
                  showRoundedBottomSheet(
                    context: context,
                    backgroundColor: AppPalette.backgroundColor,
                    builder:
                        (context) => SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: EditProjectDetail(
                            project: widget.project,
                            onClose: () => Navigator.pop(context),
                            onCompleted: () {
                              //Do Something
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Previous Logs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return SizedBox(
                      height: 180,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is ProjectRetrieveSuccess) {
                    /*final matchingProject = state.projects.firstWhere(
                      (p) => p.id == widget.project.id,
                      orElse: () => widget.project,
                    );*/

                    final logs = state.projects[widget.projectIndex].dailyLogs;

                    return logs.isNotEmpty
                        ? ListView.builder(
                          itemCount: logs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = logs[index];
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
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: CreateLogPage(
                                          projectId: widget.project.id,
                                          log: item,
                                          onCompleted: () {
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
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: ConfirmLogPage(
                                          projectId: widget.project.id,
                                          log: item,
                                          onCompleted: () {
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
                                        height:
                                            MediaQuery.of(context).size.height,
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
                        : SizedBox(
                          height: 180,
                          child: Center(
                            child: Text(
                              'Project Logs are currently empty. Click \'Create Log\' to Start a Log for the Day',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                  }

                  return const Center(child: Text('Something went wrong'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  Project settings - Change Security, Accept user, Delete Project, Transfer Project
//
