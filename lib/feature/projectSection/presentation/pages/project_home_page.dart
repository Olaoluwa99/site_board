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
import 'package:site_board/init_dependencies.dart';

import '../../../../../core/utils/show_rounded_bottom_sheet.dart';
import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/project.dart';
import '../bloc/project_bloc.dart';
import '../bloc/summary_bloc.dart';
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

  Project _getCurrentProject() {
    final state = context.read<ProjectBloc>().state;
    if (state is ProjectRetrieveSuccess) {
      try {
        return state.projects.firstWhere((p) => p.id == widget.project.id);
      } catch (e) {
        return widget.project;
      }
    }
    return widget.project;
  }

  bool _canEdit(Project project) {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn) {
      final userId = userState.user.id;
      if (project.creatorId == userId) return true;
      for (final member in project.teamMembers) {
        if (member.userId == userId && member.isAdmin) {
          return true;
        }
      }
    }
    return false;
  }

  List<double> _getChartData(Project project) {
    final confirmedLogs = project.dailyLogs.where((log) => log.isConfirmed).toList();
    // Sort by date descending
    confirmedLogs.sort((a, b) => b.dateTimeList.first.compareTo(a.dateTimeList.first));

    // Take last 7 days (or fewer)
    final recentLogs = confirmedLogs.take(7).toList();

    // Reverse to show oldest to newest left to right
    return recentLogs.reversed.map((log) => log.workScore * 10).toList();
    // Assuming workScore is 0-10, chart expects roughly 0-100? Or raw score.
    // ShowBarChart max dummy is 100, so if workScore is 0.0-10.0, multiply by 10.
  }

  @override
  Widget build(BuildContext context) {
    final currentProject = _getCurrentProject();
    final canEdit = _canEdit(currentProject);
    final chartValues = _getChartData(currentProject);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.projectName),
        actions: [
          widget.isLocal
              ? SizedBox.shrink()
              : IconButton(
            onPressed: () {
              final currentProject = _getCurrentProject();

              showRoundedBottomSheet(
                context: context,
                backgroundColor: AppPalette.backgroundColor,
                builder:
                    (context) => BlocProvider(
                  create: (context) => serviceLocator<SummaryBloc>(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ProjectSummarizer(
                      project: currentProject,
                      onClose: () => Navigator.pop(context),
                      onCompleted: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              );
            },
            icon: Icon(Icons.note),
          ),
          (widget.isLocal || !canEdit)
              ? SizedBox.shrink()
              : IconButton(
            onPressed: () {
              final currentProject = _getCurrentProject();

              showRoundedBottomSheet(
                context: context,
                backgroundColor: AppPalette.backgroundColor,
                builder:
                    (context) => SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ProjectSettings(
                    project: currentProject,
                    onClose: () => Navigator.pop(context),
                    onCompleted: () {
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
      floatingActionButton:
      widget.isLocal
          ? SizedBox.shrink()
          : FloatingActionButton.extended(
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
                  Navigator.pop(context);
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
            // Check if user was removed from project
            if(!state.projects.any((p) => p.id == widget.project.id)) {
              Navigator.of(context).pop(); // Go back to Home/Account
              showSnackBar(context, "Project unavailable or deleted.");
            } else {
              setState(() {});
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '7-day Performance',
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
                  child: chartValues.isEmpty
                      ? Center(child: Text("No confirmed logs yet"))
                      : ShowBarChart(values: chartValues),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'About Project',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AboutProjectCard(
                project: currentProject,
                isLocal: widget.isLocal,
                canEdit: canEdit,
                onViewClicked: () {
                  final currentProject = _getCurrentProject();
                  showRoundedBottomSheet(
                    context: context,
                    backgroundColor: AppPalette.backgroundColor,
                    builder:
                        (context) => SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ViewProjectDetail(
                        project: currentProject,
                        onClose: () => Navigator.pop(context),
                        onCompleted: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                onEditClicked: () {
                  final currentProject = _getCurrentProject();
                  showRoundedBottomSheet(
                    context: context,
                    backgroundColor: AppPalette.backgroundColor,
                    builder:
                        (context) => SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: EditProjectDetail(
                        project: currentProject,
                        onClose: () => Navigator.pop(context),
                        onCompleted: () {
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
                    Project projectToShow;
                    try {
                      projectToShow = state.projects.firstWhere((p) => p.id == widget.project.id);
                    } catch(e) {
                      projectToShow = state.projects.isNotEmpty ? state.projects[0] : widget.project;
                    }

                    final logs = projectToShow.dailyLogs;

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
                          // If confirmed, not editable. If local, not editable.
                          isEditable: !item.isConfirmed && !widget.isLocal,
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