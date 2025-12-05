import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/loader.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/auth/presentation/bloc/auth_bloc.dart';

import '../../../core/common/entities/user.dart';
import '../../../core/common/widgets/default_button.dart';
import '../../../core/theme/app_palette.dart';
import '../../projectSection/domain/entities/Member.dart';
import '../../projectSection/domain/entities/project.dart';
import '../../projectSection/presentation/bloc/project_bloc.dart';
import '../../projectSection/presentation/pages/project_home_page.dart';
import '../../projectSection/presentation/widgets/main_alert_dialog.dart';
import '../../projectSection/presentation/widgets/project_list_item.dart';
import '../../projectSection/presentation/widgets/text_with_prefix.dart';

class AccountPage extends StatefulWidget {
  final User user;
  static route({required User user}) =>
      MaterialPageRoute(builder: (context) => AccountPage(user: user));
  const AccountPage({required this.user, super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    context.read<ProjectBloc>().add(
      ProjectGetAllProjects(userId: widget.user.id),
    );
    super.initState();
  }

  void _handleProjectClick(Project project) {
    // Navigate directly, ProjectHomePage will handle refresh logic if needed
    Navigator.push(
      context,
      ProjectHomePage.route(
        project: project,
        projectIndex: 0,
        isLocal: false,
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthDeleteAccount());
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message);
              // Handle post-deletion navigation if needed
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  TextWithPrefix(
                    prefix: 'Name',
                    text: widget.user.name,
                    textSize: 16,
                  ),
                  SizedBox(height: 16),
                  TextWithPrefix(
                    prefix: 'Email',
                    text: widget.user.email,
                    textSize: 16,
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 8),

                  // Tabs
                  TabBar(
                    tabs: [
                      Tab(text: "Created Projects"),
                      Tab(text: "Joined Projects"),
                    ],
                    indicatorColor: AppPalette.gradient2,
                    labelColor: AppPalette.whiteColor,
                    unselectedLabelColor: AppPalette.greyColor,
                  ),
                  SizedBox(height: 16),

                  SizedBox(
                    height: 300, // Fixed height for lists within scrollview
                    child: BlocConsumer<ProjectBloc, ProjectState>(
                      listener: (context, state) {
                        if (state is ProjectLoading) {
                          showLoaderDialog(context);
                        }
                        if (state is ProjectRetrieveSuccess ||
                            state is ProjectFailure) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        // Handle other specific states if necessary
                      },
                      builder: (context, state) {
                        if (state is ProjectFailure) {
                          return Center(
                            child: GestureDetector(
                              onTap: () {
                                context.read<ProjectBloc>().add(
                                  ProjectGetAllProjects(userId: widget.user.id),
                                );
                              },
                              child: Text(
                                'Not connected. Click to retry.',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        if (state is ProjectRetrieveSuccess) {
                          final createdProjects = state.projects.where((p) => p.creatorId == widget.user.id).toList();
                          final joinedProjects = state.projects.where((p) => p.creatorId != widget.user.id).toList();

                          return TabBarView(
                            children: [
                              // Created Projects List
                              createdProjects.isEmpty
                                  ? Center(child: Text("No created projects."))
                                  : ListView.builder(
                                itemCount: createdProjects.length,
                                itemBuilder: (context, index) {
                                  return ProjectListItem(
                                    projectName: createdProjects[index].projectName,
                                    onClicked: () => _handleProjectClick(createdProjects[index]),
                                  );
                                },
                              ),

                              // Joined Projects List
                              joinedProjects.isEmpty
                                  ? Center(child: Text("No joined projects."))
                                  : ListView.builder(
                                itemCount: joinedProjects.length,
                                itemBuilder: (context, index) {
                                  return ProjectListItem(
                                    projectName: joinedProjects[index].projectName,
                                    onClicked: () => _handleProjectClick(joinedProjects[index]),
                                  );
                                },
                              ),
                            ],
                          );
                        }

                        return SizedBox.shrink();
                      },
                    ),
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Signing out will remove your data from this device.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  DefaultButton(
                    onClick: () {
                      context.read<AuthBloc>().add(AuthLogout());
                    },
                    text: 'Sign out',
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Delete Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Deleting your account will permanently remove your data.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  DefaultButton(onClick: _deleteAccount, text: 'Delete'),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}