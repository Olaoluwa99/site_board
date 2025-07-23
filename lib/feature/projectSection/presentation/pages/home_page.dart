import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/accountSection/presentation/account_page.dart';
import 'package:site_board/feature/auth/presentation/pages/login_page.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_home_page.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/admin_permission_notifier.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/project_password.dart';
import 'package:uuid/uuid.dart';

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

  void _showCustomDialog() {
    showDialog(
      context: context,
      builder:
          (context) => CreateProjectDialog(
            onCompleted: (Project project) {
              context.read<ProjectBloc>().add(ProjectCreate(project: project));
              linkController.text = project.projectLink ?? '';
            },
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

  void _uploadCreatorStatus(Project currentProject, bool isLocal, int index) {
    Member? uploadMember = Member(
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

    context.read<ProjectBloc>().add(
      UpdateMemberEvent(
        projectId: currentProject.id,
        member: uploadMember,
        isCreateMember: true,
      ),
    );
    Navigator.pop(context);
  }

  void _uploadMemberStatus(Project currentProject, bool isLocal, int index) {
    if (!isLocal) {
      bool isOldUser = false;
      Member? soughtMember;
      currentProject.teamMembers.map((member) {
        if (member.userId == retrievedUser!.id) {
          isOldUser = true;
          soughtMember = member;
        }
      });

      Member? uploadMember;
      if (isOldUser) {
        uploadMember = soughtMember!.copyWith(lastViewed: DateTime.now());
      } else {
        if (currentProject.projectSecurityType == Constants.securityApproval) {
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
          showDialog(
            context: context,
            builder:
                (context) => ProjectPasswordDialog(
                  onCompleted: (String passwordText) {
                    debugPrint('------------------------------------------');
                    debugPrint(passwordText);
                    debugPrint(currentProject.projectPassword);
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

                      Navigator.pop(context);
                    } else {
                      showSnackBar(
                        context,
                        'The password you entered is incorrect. Please check with the project administrator and try again.',
                      );
                    }
                  },
                ),
          );
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
            projectId: currentProject.id,
            member: uploadMember!,
            isCreateMember: !isOldUser,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        // shadowColor: Colors.grey,
        // elevation: 10,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              widget.isLoggedIn
                  ? Navigator.push(
                    context,
                    AccountPage.route(user: retrievedUser!),
                  )
                  : Navigator.push(context, LoginPage.route());
            },
            icon:
                widget.isLoggedIn
                    ? Icon(Icons.account_circle)
                    : Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      floatingActionButton:
          widget.isLoggedIn
              ? FloatingActionButton.extended(
                onPressed: _showCustomDialog,
                label: const Text('Create Project'),
                icon: const Icon(Icons.add),
              )
              : SizedBox.shrink(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ActivateFieldEditor(
              onClick: _getProjectByLink,
              hintText: 'Input a link',
              controller: linkController,
            ),

            //
            showExtra ? Divider() : SizedBox.shrink(),
            showExtra ? SizedBox(height: 8) : SizedBox.shrink(),

            BlocListener<AppUserCubit, AppUserState>(
              listener: (context, state) {
                if (state is AppUserLoggedIn) {
                  retrievedUser = state.user;
                  context.read<ProjectBloc>().add(ProjectGetRecentProjects());
                }
              },
              child: BlocConsumer<ProjectBloc, ProjectState>(
                listener: (context, state) {
                  if (state is ProjectFailure) {
                    debugPrint(state.error);
                    showSnackBar(context, state.error);
                  }
                  if (state is ProjectMemberUpdateFailure) {
                    debugPrint(state.error);
                    showSnackBar(context, state.error);
                  }
                  /*if (state is ProjectRetrieveSuccessInit---) {
                    if (state.projects.isEmpty) {
                      showExtra = false;
                    } else {
                      showExtra = true;
                    }
                    showSnackBar(
                      context,
                      state.isLocal == true
                          ? 'Starting App in Offline mode'
                          : 'Starting App in Normal mode',
                    );
                  }*/
                  if (state is ProjectRetrieveRecentSuccess) {
                    if (state.projects.isEmpty) {
                      showExtra = false;
                    } else {
                      showExtra = true;
                    }
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
                      Navigator.push(
                        context,
                        ProjectHomePage.route(
                          project: state.project,
                          projectIndex: state.projects.indexOf(state.project),
                          isLocal: false,
                        ),
                      );
                    }
                  }
                  if (state is ProjectRetrieveSuccessSingle) {
                    _uploadMemberStatus(
                      state.project,
                      false,
                      state.projects.indexOf(state.project),
                    );
                  }
                  if (state is ProjectCreateSuccess) {
                    _uploadCreatorStatus(
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

                  if (state is ProjectRetrieveRecentSuccess) {
                    return Column(
                      children:
                          state.projects.asMap().entries.map((entry) {
                            final index = entry.key;
                            final project = entry.value;

                            return GestureDetector(
                              onTap: () {
                                context.read<ProjectBloc>().add(
                                  ProjectGetProjectById(projectId: project.id),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text(project.projectName),
                                  SizedBox(height: 8),
                                  Divider(),
                                ],
                              ),
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
    );
  }
}
