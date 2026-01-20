import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/auth/presentation/bloc/auth_bloc.dart';

import '../../../core/common/entities/user.dart';
import '../../../core/common/widgets/default_button.dart';
import '../../projectSection/presentation/bloc/project_bloc.dart';
import '../../projectSection/presentation/pages/home_page.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/offline_toolbar.dart';
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

  Widget _buildCountItem(BuildContext context, String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
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
        body: Column(
          children: [
            const OfflineToolbar(),
            Expanded(
              child: BlocListener<AuthBloc, AuthState>(
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
                        const SizedBox(height: 20),
                        TextWithPrefix(
                          prefix: 'Name',
                          text: widget.user.name,
                          textSize: 16,
                        ),
                        const SizedBox(height: 16),
                        TextWithPrefix(
                          prefix: 'Email',
                          text: widget.user.email,
                          textSize: 16,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        BlocConsumer<ProjectBloc, ProjectState>(
                          listener: (context, state) {
                            if (state is ProjectLoading) {
                              // optional: show loading
                            }
                            if (state is ProjectRetrieveSuccess ||
                                state is ProjectFailure) {
                              // No action needed for navigation here
                            }
                          },
                          builder: (context, state) {
                            if (state is ProjectFailure) {
                              return Center(
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<ProjectBloc>().add(
                                      ProjectGetAllProjects(
                                        userId: widget.user.id,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24.0,
                                    ),
                                    child: Text(
                                      'Not connected. Tap to retry.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is ProjectRetrieveSuccess) {
                              final createdCount =
                                  state.projects
                                      .where(
                                        (p) => p.creatorId == widget.user.id,
                                      )
                                      .length;
                              final joinedCount =
                                  state.projects
                                      .where(
                                        (p) => p.creatorId != widget.user.id,
                                      )
                                      .length;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildCountItem(
                                    context,
                                    'Created Projects',
                                    createdCount.toString(),
                                  ),
                                  _buildCountItem(
                                    context,
                                    'Joined Projects',
                                    joinedCount.toString(),
                                  ),
                                ],
                              );
                            }

                            return SizedBox.shrink();
                          },
                        ),

                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 16),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                        DefaultButton(
                          onClick: _deleteAccount,
                          text: 'Delete',
                          textColor: Colors.redAccent,
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
