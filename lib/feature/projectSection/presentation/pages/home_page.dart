import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:site_board/feature/accountSection/presentation/account_page.dart';
import 'package:site_board/feature/auth/presentation/pages/login_page.dart';
import 'package:site_board/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_home_page.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/admin_permission_notifier.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/main_alert_dialog.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/project_list_item.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/offline_toolbar.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/project_password.dart';
import 'package:uuid/uuid.dart';
import 'package:site_board/feature/settings/presentation/pages/settings_page.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entities/user.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/Member.dart';
import '../../domain/entities/project.dart';
import '../widgets/activate_field_editor.dart';
import '../widgets/blocked_notifier.dart';
import 'create_project.dart';

class HomePage extends StatefulWidget {
  final bool isLoggedIn;
  static route(bool isLoggedIn) =>
      MaterialPageRoute(builder: (context) => HomePage(isLoggedIn: isLoggedIn));
  const HomePage({required this.isLoggedIn, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController linkController = TextEditingController();
  bool showExtra = false;
  User? retrievedUser;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.wifi];
  late final dynamic _subscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    // Issue 1 Fix: Initialize retrievedUser immediately from current state
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn) {
      retrievedUser = userState.user;
      context.read<ProjectBloc>().add(
        ProjectGetAllProjects(userId: retrievedUser!.id),
      );
    }
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
        _connectionStatus = result;
      });
    }
  }

  void _showCustomDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateProjectPage(
              onCompleted: (Project project, File? coverImage) {
                context.read<ProjectBloc>().add(
                  ProjectCreate(project: project, coverImage: coverImage),
                );
                linkController.text = project.projectLink ?? '';
              },
            ),
      ),
    );
  }

  void _getProjectByLink() {
    if (linkController.text.isNotEmpty) {
      if (retrievedUser != null) {
        context.read<ProjectBloc>().add(
          ProjectGetProjectByLink(projectLink: linkController.text),
        );
      }
    } else {
      showSnackBar(
        context,
        'The project link is not valid. Enter a correct link and try again.',
      );
    }
  }

  Future<void> _uploadMemberStatus(
    Project currentProject,
    bool isLocal,
    int index,
  ) async {
    if (!isLocal) {
      // Logic Change: Check connectivity first
      // Suppress membership update error when offline
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _proceedToProject(currentProject, index, isLocal);
        return;
      }

      bool isOldUser = false;
      Member? soughtMember;

      for (final member in currentProject.teamMembers) {
        if (member.userId == retrievedUser!.id) {
          isOldUser = true;
          soughtMember = member;
          break;
        }
      }

      bool isCreator = currentProject.creatorId == retrievedUser!.id;

      Member? uploadMember;
      if (isOldUser) {
        // Issue 2 Fix: Check if they are actually accepted, even if they are in the list
        if (soughtMember != null &&
            !soughtMember.isAccepted &&
            !soughtMember.isBlocked) {
          showDialog(
            context: context,
            builder:
                (context) => AdminPermissionNotifier(
                  onCompleted: () {
                    Navigator.pop(context);
                  },
                ),
          );
          return;
        }

        if (soughtMember != null && soughtMember.isBlocked) {
          showDialog(
            context: context,
            builder:
                (context) => BlockedNotifier(
                  onCompleted: () {
                    Navigator.pop(context);
                  },
                ),
          );
          return;
        }

        final timeDiff = DateTime.now().difference(soughtMember!.lastViewed);
        if (timeDiff.inMinutes > 5) {
          uploadMember = soughtMember.copyWith(lastViewed: DateTime.now());
        } else {
          _proceedToProject(currentProject, index, isLocal);
          return;
        }
      } else {
        if (isCreator) {
          uploadMember = Member(
            id: const Uuid().v4(),
            projectId: currentProject.id,
            name: retrievedUser!.name,
            email: retrievedUser!.email,
            userId: retrievedUser!.id,
            isAccepted: true,
            isBlocked: false,
            isAdmin: true,
            hasLeft: false,
            lastViewed: DateTime.now(),
          );
        } else if (currentProject.projectSecurityType ==
            Constants.securityApproval) {
          uploadMember = Member(
            id: const Uuid().v4(),
            projectId: currentProject.id,
            name: retrievedUser!.name,
            email: retrievedUser!.email,
            userId: retrievedUser!.id,
            isAccepted: false,
            isBlocked: false,
            isAdmin: false,
            hasLeft: false,
            lastViewed: DateTime.now(),
          );
        } else if (currentProject.projectSecurityType ==
            Constants.securityPassword) {
          final String? passwordText = await showDialog<String>(
            context: context,
            builder:
                (context) => ProjectPasswordDialog(
                  onCompleted: (passwordText) {
                    Navigator.pop(context, passwordText);
                  },
                ),
          );

          if (passwordText == null) {
            return;
          }

          if (passwordText == currentProject.projectPassword) {
            uploadMember = Member(
              id: const Uuid().v4(),
              projectId: currentProject.id,
              name: retrievedUser!.name,
              email: retrievedUser!.email,
              userId: retrievedUser!.id,
              isAccepted: true,
              isBlocked: false,
              isAdmin: false,
              hasLeft: false,
              lastViewed: DateTime.now(),
            );
          } else {
            showSnackBar(
              context,
              'The password you entered is incorrect. Please check with the project administrator and try again.',
            );
            return;
          }
        } else {
          uploadMember = Member(
            id: const Uuid().v4(),
            projectId: currentProject.id,
            name: retrievedUser!.name,
            email: retrievedUser!.email,
            userId: retrievedUser!.id,
            isAccepted: true,
            isBlocked: false,
            isAdmin: false,
            hasLeft: false,
            lastViewed: DateTime.now(),
          );
        }
      }

      if (uploadMember != null) {
        context.read<ProjectBloc>().add(
          UpdateMemberEvent(
            project: currentProject,
            member: uploadMember,
            isCreateMember: !isOldUser,
          ),
        );
      }
    } else {
      _proceedToProject(currentProject, index, isLocal);
    }
  }

  void _proceedToProject(Project project, int index, bool isLocal) {
    Navigator.push(
      context,
      ProjectHomePage.route(
        project: project,
        projectIndex: index,
        isLocal: isLocal,
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Dispose subscription
    linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = _connectionStatus.contains(ConnectivityResult.none);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SiteBoard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, SettingsPage.route());
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                onPressed: () {
                  retrievedUser != null
                      ? Navigator.push(
                        context,
                        AccountPage.route(user: retrievedUser!),
                      )
                      : Navigator.push(context, LoginPage.route());
                },
                icon:
                    retrievedUser != null
                        ? CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person, size: 18),
                        )
                        : const Icon(Icons.account_circle_outlined),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton:
          (widget.isLoggedIn && !isOffline)
              ? FloatingActionButton.extended(
                onPressed: _showCustomDialog,
                label: const Text('Create Project'),
                icon: const Icon(Icons.add),
              )
              : SizedBox.shrink(),
      body: Column(
        children: [
          const OfflineToolbar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActivateFieldEditor(
                    onClick: _getProjectByLink,
                    hintText: 'Input a link',
                    controller: linkController,
                  ),

                  showExtra ? Divider() : SizedBox.shrink(),
                  showExtra ? SizedBox(height: 8) : SizedBox.shrink(),

                  BlocListener<AppUserCubit, AppUserState>(
                    listener: (context, state) {
                      if (state is AppUserLoggedIn) {
                        setState(() {
                          retrievedUser = state.user;
                        });
                        context.read<ProjectBloc>().add(
                          ProjectGetAllProjects(userId: state.user.id),
                        );
                      }
                    },
                    child: BlocConsumer<ProjectBloc, ProjectState>(
                      listener: (context, state) {
                        if (state is ProjectFailure) {
                          debugPrint(state.error);
                          showSnackBar(context, state.error);
                        }
                        if (state is ProjectRetrieveByIdFailure) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => MainAlertDialog(
                                  title: 'Error Loading Project',
                                  text:
                                      '${state.error}\n\nWe could not find this project locally or online.',
                                  onDismiss: () {
                                    Navigator.pop(context);
                                  },
                                ),
                          );
                        }
                        if (state is ProjectRetrieveByLinkFailure) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => MainAlertDialog(
                                  title: 'Error Loading Project',
                                  text:
                                      '${state.error}\n\nWe encountered an error while trying to retrieve data from this project link. Please verify that the link is correct and check your internet connection. If the issue continues, contact the project administrator for assistance.',
                                  onDismiss: () {
                                    Navigator.pop(context);
                                  },
                                ),
                          );
                        }
                        // Check generic success to show divider
                        if (state is ProjectRetrieveSuccess) {
                          setState(() {
                            showExtra = state.projects.isNotEmpty;
                          });
                        }
                        if (state is ProjectMemberUpdateFailure) {
                          // Graceful Fallback: If member update fails (e.g. offline), proceed anyway.
                          showSnackBar(
                            context,
                            "Could not update membership status. Proceeding in offline mode.",
                          );
                          _proceedToProject(
                            state.project,
                            state.projects.indexOf(state.project),
                            false,
                          );
                        }
                        if (state is ProjectMemberUpdateSuccess) {
                          if (state.member.isBlocked) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => BlockedNotifier(
                                    onCompleted: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                            );
                          } else if (!state.member.isAccepted) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AdminPermissionNotifier(
                                    onCompleted: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                            );
                          } else {
                            _proceedToProject(
                              state.project,
                              state.projects.indexOf(state.project),
                              false,
                            );
                          }
                        }
                        if (state is ProjectRetrieveSuccessLink) {
                          _uploadMemberStatus(
                            state.project,
                            false,
                            state.projects.indexOf(state.project),
                          );
                        }
                        if (state is ProjectRetrieveSuccessId) {
                          _uploadMemberStatus(
                            state.project,
                            false,
                            state.projects.indexOf(state.project),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is ProjectLoading) {
                          return const Loader();
                        }

                        if (state is ProjectRetrieveSuccess) {
                          return state.projects.isEmpty
                              ? const SizedBox()
                              : Column(
                                children:
                                    state.projects.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final project = entry.value;

                                      return ProjectListItem(
                                        projectName: project.projectName,
                                        onClicked: () {
                                          context.read<ProjectBloc>().add(
                                            ProjectGetProjectById(
                                              project: project,
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                              );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
