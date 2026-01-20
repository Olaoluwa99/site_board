import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_settings.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/about_project_card.dart';
import 'package:site_board/feature/projectSection/presentation/pages/view_project_detail.dart';
import 'package:site_board/feature/projectSection/presentation/pages/edit_project_detail.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_summarizer.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/show_bar_chart.dart';
import 'package:site_board/init_dependencies.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/offline_toolbar.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';

import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/project.dart';
import '../bloc/project_bloc.dart';
import '../bloc/summary_bloc.dart';

import 'inventory_manager_page.dart';
import 'material_analysis_page.dart';
import 'project_logs_page.dart';

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
  bool _isOffline = false;
  late final dynamic _subscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() {
        _isOffline = result.contains(ConnectivityResult.none);
      });
    }
  }

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

  List<double> _getChartData(Project project) {
    final confirmedLogs =
        project.dailyLogs.where((log) => log.isConfirmed).toList();
    // Sort by date descending
    confirmedLogs.sort(
      (a, b) => b.dateTimeList.first.compareTo(a.dateTimeList.first),
    );

    // Take last 7 days (or fewer)
    final recentLogs = confirmedLogs.take(7).toList();

    // Reverse to show oldest to newest left to right
    return recentLogs.reversed.map((log) => log.workScore).toList();
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
          (widget.isLocal || _isOffline)
              ? IconButton(
                onPressed: () {
                  showSnackBar(context, "No Network Connection");
                },
                icon: const Icon(Icons.wifi_off_rounded, color: Colors.grey),
                tooltip: "Offline Mode",
              )
              : (!canEdit)
              ? const SizedBox.shrink()
              : IconButton(
                onPressed: () {
                  final currentProject = _getCurrentProject();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProjectSettings(
                            project: currentProject,
                            onClose: () => Navigator.pop(context),
                            onCompleted: () => Navigator.pop(context),
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
        ],
      ),
      floatingActionButton: null,
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is DailyLogUploadFailure) {
            showSnackBar(context, state.error);
          }
          if (state is DailyLogUploadSuccess) {
            showSnackBar(context, "Log updated successfully");
          }
          if (state is ProjectRetrieveSuccess) {
            if (!state.projects.any((p) => p.id == widget.project.id)) {
              Navigator.of(context).pop();
              showSnackBar(context, "Project unavailable or deleted.");
            } else {
              setState(() {});
            }
          }
          if (state is ProjectFailure) {
            showSnackBar(context, state.error);
          }
        },
        child: Column(
          children: [
            const OfflineToolbar(),
            Expanded(
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
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child:
                            chartValues.isEmpty
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
                      canEdit: canEdit && !widget.isLocal && !_isOffline,
                      onViewClicked: () {
                        final currentProject = _getCurrentProject();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ViewProjectDetail(
                                  project: currentProject,
                                  onClose: () => Navigator.pop(context),
                                  onCompleted: () => Navigator.pop(context),
                                ),
                          ),
                        );
                      },
                      onEditClicked: () {
                        final currentProject = _getCurrentProject();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProjectDetail(
                                  project: currentProject,
                                  onClose: () => Navigator.pop(context),
                                  onCompleted: () => Navigator.pop(context),
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _ActionCard(
                          title: "Project Logs",
                          icon: Icons.history_edu,
                          color: Colors.blueAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProjectLogsPage(
                                      project: currentProject,
                                      isLocal: widget.isLocal,
                                    ),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: "Inventory Manager",
                          icon: Icons.inventory_2,
                          color: Colors.orangeAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => InventoryManagerPage(
                                      projectId: widget.project.id,
                                      isAdmin: canEdit,
                                    ),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: "AI Summarizer",
                          icon: Icons.auto_awesome,
                          color: Colors.purpleAccent,
                          onTap: () {
                            if (widget.isLocal || _isOffline) {
                              showSnackBar(
                                context,
                                "Not available for offline projects",
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BlocProvider(
                                      create:
                                          (context) =>
                                              serviceLocator<SummaryBloc>(),
                                      child: ProjectSummarizer(
                                        project: currentProject,
                                        onClose: () => Navigator.pop(context),
                                        onCompleted:
                                            () => Navigator.pop(context),
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: "Site ledger",
                          icon: Icons.analytics,
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MaterialAnalysisPage(
                                      projectId: widget.project.id,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
