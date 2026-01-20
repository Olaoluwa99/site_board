import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:site_board/feature/projectSection/domain/entities/project.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/pages/confirm_log_page.dart';
import 'package:site_board/feature/projectSection/presentation/pages/create_log_page.dart';
import 'package:site_board/feature/projectSection/presentation/pages/view_log_page.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/offline_toolbar.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/log_list_item.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';

class ProjectLogsPage extends StatefulWidget {
  final Project project;
  final bool isLocal;

  const ProjectLogsPage({
    super.key,
    required this.project,
    required this.isLocal,
  });

  @override
  State<ProjectLogsPage> createState() => _ProjectLogsPageState();
}

class _ProjectLogsPageState extends State<ProjectLogsPage> {
  Project _getCurrentProject() {
    final state = context.read<ProjectBloc>().state;
    if (state is ProjectRetrieveSuccess) {
      try {
        return state.projects.firstWhere((p) => p.id == widget.project.id);
      } catch (e) {
        return widget.project;
      }
    } else if (state is ProjectMemberUpdateSuccess) {
      if (state.project.id == widget.project.id) {
        return state.project;
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

  void _showDeleteConfirmation(BuildContext context, String logId) {
    final projectBloc = context.read<ProjectBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Log'),
            content: const Text(
              'Are you sure you want to delete this log? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  projectBloc.add(
                    DailyLogDelete(logId: logId, projectId: widget.project.id),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProject = _getCurrentProject();
    final canEdit = _canEdit(currentProject);

    return Scaffold(
      appBar: AppBar(title: const Text('Project Logs')),
      floatingActionButton:
          (widget.isLocal || !canEdit)
              ? null
              : FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateLogPage(
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
      body: Column(
        children: [
          const OfflineToolbar(),
          Expanded(
            child: BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                if (state is ProjectLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProjectRetrieveSuccess ||
                    state is ProjectMemberUpdateSuccess) {
                  Project projectToShow = widget.project;

                  if (state is ProjectRetrieveSuccess) {
                    try {
                      projectToShow = state.projects.firstWhere(
                        (p) => p.id == widget.project.id,
                      );
                    } catch (e) {
                      projectToShow =
                          state.projects.isNotEmpty
                              ? state.projects[0]
                              : widget.project;
                    }
                  } else if (state is ProjectMemberUpdateSuccess) {
                    projectToShow = state.project;
                  }

                  final logs = projectToShow.dailyLogs;

                  return logs.isNotEmpty
                      ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: logs.length,
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
                            isEditable:
                                canEdit && !item.isConfirmed && !widget.isLocal,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CreateLogPage(
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
                            onDelete:
                                () => _showDeleteConfirmation(context, item.id),
                            onConfirm: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ConfirmLogPage(
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ViewLogPage(
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
                      : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_edu,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Project Logs are currently empty.\nClick \'Create Log\' to Start.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                }

                return const Center(child: Text('Something went wrong'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
