import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/loader.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/common/entities/user.dart';
import '../../../core/common/widgets/default_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../projectSection/domain/entities/Member.dart';
import '../../projectSection/domain/entities/project.dart';
import '../../projectSection/presentation/bloc/project_bloc.dart';
import '../../projectSection/presentation/pages/home_page.dart';
import '../../projectSection/presentation/pages/project_home_page.dart';
import '../../projectSection/presentation/widgets/admin_permission_notifier.dart';
import '../../projectSection/presentation/widgets/blocked_notifier.dart';
import '../../projectSection/presentation/widgets/project_list_item.dart';
import '../../projectSection/presentation/widgets/project_password.dart';
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
    _checkAccessAndNavigate(project);
  }

  Future<void> _checkAccessAndNavigate(Project project) async {
    bool isCreator = project.creatorId == widget.user.id;

    // If creator, proceed directly
    if (isCreator) {
      _proceedToProject(project);
      return;
    }

    // Check if I am a member
    Member? myMember;
    try {
      myMember = project.teamMembers.firstWhere(
            (m) => m.userId == widget.user.id,
      );
    } catch (e) {
      myMember = null;
    }

    // If I am a member in the list
    if (myMember != null) {
      // 1. Check if blocked
      if (myMember.isBlocked) {
        showDialog(
          context: context,
          builder: (context) => BlockedNotifier(
            onCompleted: () => Navigator.pop(context),
          ),
        );
        return;
      }

      // 2. Check if accepted
      if (!myMember.isAccepted) {
        showDialog(
          context: context,
          builder: (context) => AdminPermissionNotifier(
            onCompleted: () => Navigator.pop(context),
          ),
        );
        return;
      }

      // 3. Update Last Viewed (Optional, keeps data fresh)
      // If everything is fine, proceed.
      // We could update 'lastViewed' here but to keep UI snappy we proceed.
      _proceedToProject(project);
      return;
    }

    // If not a member (unlikely in AccountPage since it lists "Joined Projects",
    // but possible if logic changes or data is stale)
    // We should treat it as a fresh join attempt or access request.

    if (project.projectSecurityType == Constants.securityPassword) {
      final String? passwordText = await showDialog<String>(
        context: context,
        builder: (context) => ProjectPasswordDialog(
          onCompleted: (passwordText) {
            Navigator.pop(context, passwordText);
          },
        ),
      );

      if (passwordText == null) return;

      if (passwordText == project.projectPassword) {
        _joinProjectAndProceed(project, true); // Join as accepted
      } else {
        showSnackBar(context, 'Incorrect Password.');
      }
    } else if (project.projectSecurityType == Constants.securityApproval) {
      // Join as pending
      _joinProjectAndProceed(project, false);
      // Notify user
      showDialog(
        context: context,
        builder: (context) => AdminPermissionNotifier(
          onCompleted: () => Navigator.pop(context),
        ),
      );
    } else {
      // No security
      _joinProjectAndProceed(project, true);
    }
  }

  void _joinProjectAndProceed(Project project, bool isAccepted) {
    Member uploadMember = Member(
      id: const Uuid().v4(),
      projectId: project.id,
      name: widget.user.name,
      email: widget.user.email,
      userId: widget.user.id,
      isAccepted: isAccepted,
      isBlocked: false,
      isAdmin: false,
      hasLeft: false,
      lastViewed: DateTime.now(),
    );

    context.read<ProjectBloc>().add(
      UpdateMemberEvent(
        project: project,
        member: uploadMember,
        isCreateMember: true,
      ),
    );

    // If automatically accepted, navigate. Otherwise wait (handled by Bloc listener in HomePage usually,
    // but here we might need to rely on the user tapping again or a listener)
    // For AccountPage, typically the user is ALREADY a member if they see the project.
    // So this block is a fallback.
    if (isAccepted) {
      _proceedToProject(project);
    }
  }

  void _proceedToProject(Project project) {
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
      builder:
          (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
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
            }
            if (state is AuthInitial) {
              Navigator.pushAndRemoveUntil(
                context,
                HomePage.route(false),
                    (route) => false,
              );
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
                            state is ProjectFailure ||
                            state is ProjectMemberUpdateSuccess) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }

                        if (state is ProjectMemberUpdateSuccess) {
                          // If we just joined a project (rare case for AccountPage), navigate
                          if (state.member.isAccepted && !state.member.isBlocked) {
                            _proceedToProject(state.project);
                          }
                        }
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
                          final createdProjects =
                          state.projects
                              .where((p) => p.creatorId == widget.user.id)
                              .toList();
                          final joinedProjects =
                          state.projects
                              .where((p) => p.creatorId != widget.user.id)
                              .toList();

                          return TabBarView(
                            children: [
                              // Created Projects List
                              createdProjects.isEmpty
                                  ? Center(child: Text("No created projects."))
                                  : ListView.builder(
                                itemCount: createdProjects.length,
                                itemBuilder: (context, index) {
                                  return ProjectListItem(
                                    projectName:
                                    createdProjects[index].projectName,
                                    onClicked:
                                        () => _handleProjectClick(
                                      createdProjects[index],
                                    ),
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
                                    projectName:
                                    joinedProjects[index].projectName,
                                    onClicked:
                                        () => _handleProjectClick(
                                      joinedProjects[index],
                                    ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
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