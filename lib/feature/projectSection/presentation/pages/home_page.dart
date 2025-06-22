import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/auth/presentation/pages/login_page.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/pages/project_home_page.dart';

import '../../../../core/common/widgets/loader.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/project.dart';
import '../widgets/activate_field_editor.dart';
import 'create_project.dart';

class HomePage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomePage());
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController linkController = TextEditingController();
  bool showExtra = false;

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(ProjectGetAllProjects(userId: '12345'));
    setState(() {});
  }

  void _showCustomDialog() {
    showDialog(
      context: context,
      builder:
          (context) => CreateProjectDialog(
            onCompleted: (Project project) {
              linkController.text = project.projectLink ?? '';
            },
          ),
    );
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
              Navigator.push(context, LoginPage.route());
            },
            icon: Icon(Icons.account_circle),
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
              onClick: () {
                /*Navigator.push(
                  context,
                  ProjectHomePage.route(),
                );*/
              },
              hintText: 'Input a link',
              controller: linkController,
            ),

            //
            showExtra ? Divider() : SizedBox.shrink(),
            showExtra ? SizedBox(height: 8) : SizedBox.shrink(),

            //
            BlocConsumer<ProjectBloc, ProjectState>(
              listener: (context, state) {
                if (state is ProjectFailure) {
                  showSnackBar(context, state.error);
                }
                if (state is ProjectRetrieveSuccess) {
                  if (state.projects.isEmpty) {
                    showExtra = false;
                  } else {
                    showExtra = true;
                  }
                }
              },
              builder: (context, state) {
                if (state is ProjectLoading) {
                  return const Loader();
                }

                if (state is ProjectRetrieveSuccess) {
                  return Column(
                    children:
                        state.projects.map((project) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                ProjectHomePage.route(project),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 0.0,
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
                  /*return SizedBox(
                    child: ListView.builder(
                      itemCount: state.projects.length,
                      itemBuilder: (context, index) {
                        final project = state.projects[index];
                        return Column(
                          children: [
                            Text(project.projectName),
                            SizedBox(height: 8),
                            Divider(),
                            SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  );*/
                }

                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
