import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/default_button.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../domain/entities/project.dart';

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

  void _acceptMember(String userId) {
    // Logic to accept user
    final member = widget.project.teamMembers.firstWhere((m) => m.userId == userId);
    final updatedMember = member.copyWith(isAccepted: true);

    context.read<ProjectBloc>().add(
      UpdateMemberEvent(
        project: widget.project,
        member: updatedMember,
        isCreateMember: false,
      ),
    );
  }

  void _completeProject() {
    // Mark as inactive (completed)
    final updatedProject = widget.project.copyWith(isActive: false, endDate: DateTime.now());
    context.read<ProjectBloc>().add(
        ProjectUpdate(project: updatedProject, coverImage: null)
    );
    Navigator.pop(context);
  }

  void _deleteProject() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Project"),
          content: Text("Are you sure you want to delete this project? This cannot be undone."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.read<ProjectBloc>().add(ProjectDeleteEvent(projectId: widget.project.id));
                  Navigator.pop(context); // Close settings
                },
                child: Text("Delete", style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  void _leaveProject(String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Leave Project"),
          content: Text("Are you sure you want to leave this project?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ProjectBloc>().add(ProjectLeaveEvent(projectId: widget.project.id, userId: userId));
                  Navigator.pop(context);
                },
                child: Text("Leave", style: TextStyle(color: Colors.red))
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingMembers = widget.project.teamMembers.where((m) => !m.isAccepted).toList();
    final userState = context.read<AppUserCubit>().state;
    String currentUserId = '';
    if (userState is AppUserLoggedIn) {
      currentUserId = userState.user.id;
    }
    final isCreator = widget.project.creatorId == currentUserId;

    return Scaffold(
      appBar: AppBar(title: Text('Project settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCreator) ...[
              Text(
                'Pending Access Requests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              pendingMembers.isEmpty
                  ? Text("No pending requests.", style: TextStyle(color: Colors.grey))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pendingMembers.length,
                itemBuilder: (context, index) {
                  final member = pendingMembers[index];
                  return ListTile(
                    title: Text(member.name),
                    subtitle: Text(member.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptMember(member.userId),
                        ),
                      ],
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
              Text('Mark this project as completed. It will become read-only.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              DefaultButton(onClick: _completeProject, text: 'Complete Project'),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),

              Text(
                'Delete Project',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              SizedBox(height: 16),
              Text('This will permanently delete the project and all its data.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              DefaultButton(onClick: _deleteProject, text: 'Delete Project'),
            ] else ...[
              Text(
                'Leave Project',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              SizedBox(height: 16),
              Text('Remove yourself from this project.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              DefaultButton(onClick: () => _leaveProject(currentUserId), text: 'Leave Project'),
            ],
          ],
        ),
      ),
    );
  }
}