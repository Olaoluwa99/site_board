import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/default_button.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../domain/entities/project.dart';
import 'home_page.dart';

class ProjectSettings extends StatefulWidget {
  final Project project;
  final VoidCallback onClose;
  final VoidCallback onCompleted;
  const ProjectSettings({
    required this.project,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<ProjectSettings> createState() => _ProjectSettingsState();
}

class _ProjectSettingsState extends State<ProjectSettings> {
  // Accept a pending member
  void _acceptMember(Project currentProject, String userId) {
    final member = currentProject.teamMembers.firstWhere(
          (m) => m.userId == userId,
    );
    final updatedMember = member.copyWith(isAccepted: true);

    context.read<ProjectBloc>().add(
      UpdateMemberEvent(
        project: currentProject,
        member: updatedMember,
        isCreateMember: false,
      ),
    );
  }

  // Reject (Block) a pending member or Block an existing member
  void _blockMember(Project currentProject, String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text("Block Member"),
        content: Text(
          "Are you sure you want to block this member? They will lose access to the project.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final member = currentProject.teamMembers.firstWhere(
                    (m) => m.userId == userId,
              );
              final updatedMember = member.copyWith(
                isBlocked: true,
                isAccepted: false,
              );

              context.read<ProjectBloc>().add(
                UpdateMemberEvent(
                  project: currentProject,
                  member: updatedMember,
                  isCreateMember: false,
                ),
              );
            },
            child: Text("Block", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Unblock a member
  void _unblockMember(Project currentProject, String userId) {
    final member = currentProject.teamMembers.firstWhere(
          (m) => m.userId == userId,
    );
    // When unblocking, we set isBlocked to false and isAccepted to true
    final updatedMember = member.copyWith(isBlocked: false, isAccepted: true);

    context.read<ProjectBloc>().add(
      UpdateMemberEvent(
        project: currentProject,
        member: updatedMember,
        isCreateMember: false,
      ),
    );
  }

  // Toggle Admin Status (Creator Only)
  void _toggleAdmin(Project currentProject, String userId) {
    final member = currentProject.teamMembers.firstWhere(
          (m) => m.userId == userId,
    );
    final updatedMember = member.copyWith(isAdmin: !member.isAdmin);

    context.read<ProjectBloc>().add(
      UpdateMemberEvent(
        project: currentProject,
        member: updatedMember,
        isCreateMember: false,
      ),
    );
  }

  void _completeProject(Project currentProject) {
    final updatedProject = currentProject.copyWith(
      isActive: false,
      endDate: DateTime.now(),
    );
    context.read<ProjectBloc>().add(
      ProjectUpdate(project: updatedProject, coverImage: null),
    );
    Navigator.pop(context);
  }

  void _deleteProject(Project currentProject) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text("Delete Project"),
        content: Text(
          "Are you sure you want to delete this project? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProjectBloc>().add(
                ProjectDeleteEvent(projectId: currentProject.id),
              );
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _leaveProject(Project currentProject, String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text("Leave Project"),
        content: Text("Are you sure you want to leave this project?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Send event but don't manually pop settings yet.
              // Let the Listener handle navigation on success.
              context.read<ProjectBloc>().add(
                ProjectLeaveEvent(
                  projectId: currentProject.id,
                  userId: userId,
                ),
              );
            },
            child: Text("Leave", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AppUserCubit>().state;
    String currentUserId = '';
    if (userState is AppUserLoggedIn) {
      currentUserId = userState.user.id;
    }

    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectLoading) {
          showLoaderDialog(context);
        }

        // Handle Failure States
        if (state is ProjectMemberUpdateFailure) {
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loader
          showSnackBar(context, state.error);
        }

        if (state is ProjectFailure) {
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loader
          showSnackBar(context, state.error);
        }

        // Handle Success States
        if (state is ProjectMemberUpdateSuccess) {
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loader
          showSnackBar(context, "Member updated successfully");
        }

        if (state is ProjectRetrieveSuccess) {
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loader

          // Check if this success was due to a LEAVE or DELETE event
          // If the current project is no longer in the list OR user is marked as left
          bool projectExists = state.projects.any((p) => p.id == widget.project.id);

          if (!projectExists) {
            // Project deleted or access lost
            Navigator.of(context).pushAndRemoveUntil(
                HomePage.route(true),
                    (route) => false
            );
            return;
          }

          final p = state.projects.firstWhere((p) => p.id == widget.project.id);
          // Check if I am still a member (not left)
          try {
            // Note: Our remote source filters out 'has_left' members from getProjectById
            // So if I am missing from teamMembers list, or I am there but has_left is true
            // (though backend shouldn't return me if filtering is on, but let's be safe)
            bool isMember = p.teamMembers.any((m) => m.userId == currentUserId && !m.hasLeft);
            if (!isMember && p.creatorId != currentUserId) {
              // I have left the project
              Navigator.of(context).pushAndRemoveUntil(
                  HomePage.route(true),
                      (route) => false
              );
            }
          } catch(e) {
            // Error checking member status
          }
        }
      },
      builder: (context, state) {
        // Use the updated project from state if available, otherwise use widget.project
        Project currentProject = widget.project;
        if (state is ProjectRetrieveSuccess) {
          try {
            currentProject = state.projects.firstWhere(
                  (p) => p.id == widget.project.id,
            );
          } catch (e) {
            // Fallback if project not found
          }
        } else if (state is ProjectMemberUpdateSuccess) {
          currentProject = state.project;
        }

        final isCreator = currentProject.creatorId == currentUserId;
        bool isAdmin = false;

        // Check Admin Status
        try {
          final me = currentProject.teamMembers.firstWhere(
                (m) => m.userId == currentUserId,
          );
          isAdmin = me.isAdmin;
        } catch (e) {
          isAdmin = false;
        }
        // Creator is super admin
        if (isCreator) isAdmin = true;

        // Pending Members (Not accepted, Not blocked, Not left)
        final pendingMembers =
        currentProject.teamMembers
            .where((m) => !m.isAccepted && !m.isBlocked && !m.hasLeft)
            .toList();

        // Active Team Members (Accepted, Not Blocked, Not Left)
        final teamMembers =
        currentProject.teamMembers
            .where((m) => m.isAccepted && !m.isBlocked && !m.hasLeft)
            .toList();

        // Blocked Members
        final blockedMembers =
        currentProject.teamMembers.where((m) => m.isBlocked).toList();

        // Previous Members (Has Left)
        final previousMembers =
        currentProject.teamMembers.where((m) => m.hasLeft).toList();

        return Scaffold(
          appBar: AppBar(title: Text('Project settings')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAdmin) ...[
                  Text(
                    'Pending Access Requests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  pendingMembers.isEmpty
                      ? Text(
                    "No pending requests.",
                    style: TextStyle(color: Colors.grey),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pendingMembers.length,
                    itemBuilder: (context, index) {
                      final member = pendingMembers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(member.name),
                        subtitle: Text(member.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed:
                                  () => _acceptMember(
                                currentProject,
                                member.userId,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed:
                                  () => _blockMember(
                                currentProject,
                                member.userId,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  // Team Members List
                  Text(
                    'Team Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  teamMembers.isEmpty
                      ? Text(
                    "No other team members.",
                    style: TextStyle(color: Colors.grey),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      final member = teamMembers[index];
                      final bool isTargetCreator =
                          member.userId == currentProject.creatorId;
                      final bool isTargetAdmin = member.isAdmin;

                      bool canBlock = false;
                      if (isCreator &&
                          !isTargetCreator &&
                          member.userId != currentUserId) {
                        canBlock = true;
                      } else if (isAdmin && !isCreator) {
                        if (!isTargetCreator &&
                            !isTargetAdmin &&
                            member.userId != currentUserId) {
                          canBlock = true;
                        }
                      }

                      bool canManageAdmin =
                          isCreator &&
                              !isTargetCreator &&
                              member.userId != currentUserId;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(member.name),
                        subtitle: Text(
                          isTargetCreator
                              ? 'Creator'
                              : (isTargetAdmin ? 'Admin' : 'Member'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canManageAdmin)
                              IconButton(
                                icon: Icon(
                                  member.isAdmin
                                      ? Icons.remove_moderator
                                      : Icons.add_moderator,
                                  color:
                                  member.isAdmin
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                                tooltip:
                                member.isAdmin
                                    ? "Remove Admin"
                                    : "Make Admin",
                                onPressed:
                                    () => _toggleAdmin(
                                  currentProject,
                                  member.userId,
                                ),
                              ),
                            if (canBlock)
                              IconButton(
                                icon: Icon(Icons.block, color: Colors.red),
                                tooltip: "Block Member",
                                onPressed:
                                    () => _blockMember(
                                  currentProject,
                                  member.userId,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  // Blocked Users Section
                  Text(
                    'Blocked Users',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  blockedMembers.isEmpty
                      ? Text(
                    "No blocked users.",
                    style: TextStyle(color: Colors.grey),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: blockedMembers.length,
                    itemBuilder: (context, index) {
                      final member = blockedMembers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          member.name,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        subtitle: Text(member.email),
                        trailing: IconButton(
                          icon: Icon(Icons.refresh, color: Colors.green),
                          tooltip: "Unblock User",
                          onPressed:
                              () => _unblockMember(
                            currentProject,
                            member.userId,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  // Previous Members Section
                  Text(
                    'Previous Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  previousMembers.isEmpty
                      ? Text(
                    "No previous members.",
                    style: TextStyle(color: Colors.grey),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: previousMembers.length,
                    itemBuilder: (context, index) {
                      final member = previousMembers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          member.name,
                          style: TextStyle(color: Colors.grey),
                        ),
                        subtitle: Text(member.email),
                        trailing: Text(
                          "Left",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  Text(
                    'Complete Project',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mark this project as completed. It will become read-only.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  DefaultButton(
                    onClick: () => _completeProject(currentProject),
                    text: 'Complete Project',
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  Text(
                    'Delete Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This will permanently delete the project and all its data.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  DefaultButton(
                    onClick: () => _deleteProject(currentProject),
                    text: 'Delete Project',
                  ),
                ],

                // Leave Project (Visible to everyone except Creator)
                if (!isCreator) ...[
                  if (isAdmin) ...[
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 16),
                  ],
                  Text(
                    'Leave Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Remove yourself from this project.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  DefaultButton(
                    onClick:
                        () => _leaveProject(currentProject, currentUserId),
                    text: 'Leave Project',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}