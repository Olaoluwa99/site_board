import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/default_button.dart';

import '../../../core/common/entities/user.dart';
import '../../projectSection/presentation/bloc/project_bloc.dart';
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
  //bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          /*IconButton(
            onPressed: () {
              if (isEditMode) {
              } else {}
            },
            icon: isEditMode ? Icon(Icons.done) : Icon(Icons.edit),
          ),*/
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is account page', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
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
            Text(
              'Created Projects',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                if (state is ProjectFailure) {
                  debugPrint(state.error);
                  return Text(
                    state.error,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  );
                }
                if (state is ProjectLoading) {
                  return SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is ProjectRetrieveSuccess) {
                  return state.projects.isEmpty
                      ? SizedBox(
                        height: 120,
                        child: Center(child: Text("No projects found.")),
                      )
                      : Column(
                        children:
                            state.projects.map((project) {
                              return Text(project.projectName);
                            }).toList(),
                      );
                }
                /*if (state is ProjectRetrieveSuccessInit) {
                    return Column(
                      children:
                          state.projects.map((project) {
                            return Text(project.projectName);
                          }).toList(),
                    );
                  }*/
                return SizedBox.shrink();
              },
            ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Sign Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('To sign-out ...', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            DefaultButton(onClick: () {}, text: 'Sign out'),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Delete Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Deleting this account ...', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            DefaultButton(onClick: () {}, text: 'Delete'),
          ],
        ),
      ),
    );
  }
}

/**
 * 1. View My Created Projects in Profile
 * 2. What is added to recent and Why it should be added
 * 3. What should be added to Offline and what should not
 * 4. Setting up everything to work well
 * 5. ---
 * **/
