import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/accountSection/presentation/account_page.dart';
import 'package:site_board/feature/auth/presentation/pages/login_page.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_home_page.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/project.dart';
import '../widgets/activate_field_editor.dart';
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
      context.read<ProjectBloc>().add(
        ProjectGetProjectByLink(projectLink: linkController.text),
      );
    } else {
      showSnackBar(
        context,
        'The project link is not valid. Enter a correct link and try again.',
      );
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
        shadowColor: Colors.grey,
        elevation: 10,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              widget.isLoggedIn
                  ? Navigator.push(context, AccountPage.route())
                  : Navigator.push(context, LoginPage.route());
            },
            icon:
                widget.isLoggedIn
                    ? Icon(Icons.account_circle)
                    : Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCustomDialog,
        label: const Text('Create Project'),
        icon: const Icon(Icons.add),
      ),
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
                  context.read<ProjectBloc>().add(
                    ProjectGetAllProjects(userId: state.user.id),
                  );
                }
              },
              child: BlocConsumer<ProjectBloc, ProjectState>(
                listener: (context, state) {
                  if (state is ProjectFailure) {
                    showSnackBar(context, state.error);
                  }
                  if (state is ProjectRetrieveSuccessSingle) {
                    Navigator.push(
                      context,
                      ProjectHomePage.route(
                        project: state.project,
                        projectIndex: state.projects.indexOf(state.project),
                      ),
                    );
                  }
                  if (state is ProjectRetrieveSuccessInit) {
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
                  }
                },
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return const Loader();
                  }

                  if (state is ProjectRetrieveSuccessInit) {
                    return Column(
                      children:
                          state.projects.asMap().entries.map((entry) {
                            final index = entry.key;
                            final project = entry.value;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  ProjectHomePage.route(
                                    project: project,
                                    projectIndex: index,
                                  ),
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
