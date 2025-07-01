import 'dart:math';

import 'domain/entities/daily_log.dart';
import 'domain/entities/project.dart';

List<Project> getDummyProjects() {
  final now = DateTime.now();

  List<LogTask> makeTasks() {
    return [
      LogTask(
        id: '',
        dailyLogId: '',
        plannedTask: 'Excavation',
        percentCompleted: Random().nextDouble(),
      ),
      LogTask(
        id: '',
        dailyLogId: '',
        plannedTask: 'Rebar Installation',
        percentCompleted: Random().nextDouble(),
      ),
      LogTask(
        id: '',
        dailyLogId: '',
        plannedTask: 'Concrete Pouring',
        percentCompleted: Random().nextDouble(),
      ),
      LogTask(
        id: '',
        dailyLogId: '',
        plannedTask: 'Formwork',
        percentCompleted: Random().nextDouble(),
      ),
    ];
  }

  List<DailyLog> makeDailyLogs(int days) {
    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: i));
      return DailyLog(
        id: 'log_$i',
        projectId: 'project_$i',
        dateTimeList: [date],
        numberOfWorkers: 5 + i,
        weatherCondition: (i % 2 == 0) ? 'Sunny' : 'Cloudy',
        materialsAvailable: ['Cement', 'Rebar', 'Sand', 'Gravel'],
        plannedTasks: makeTasks(),
        startingImageUrl: ['https://example.com/start_img_$i.jpg'],
        endingImageUrl: ['https://example.com/end_img_$i.jpg'],
        observations: 'Work progressing well on day ${i + 1}.',
        isConfirmed: i % 3 == 0,
        workScore: 50 + Random().nextDouble() * 50,
        generatedSummary:
            'Summary of work performed on ${date.toLocal().toString().split(' ')[0]}.',
      );
    });
  }

  return [
    Project(
      id: 'project_1',
      projectName: 'Bridge Construction',
      creatorId: 'user_123',
      projectLink: 'https://example.com/projects/1',
      description: 'Construction of a highway bridge across the river',
      teamMemberIds: ['user_123', 'user_456', 'user_789'],
      createdDate: now.subtract(const Duration(days: 30)),
      endDate: now.add(const Duration(days: 60)),
      dailyLogs: makeDailyLogs(10),
      location: 'Location A',
      isActive: true,
      lastUpdated: now,
      coverPhotoUrl: 'https://example.com/cover_1.png',
    ),
    Project(
      id: 'project_2',
      projectName: 'Office Complex',
      creatorId: 'user_456',
      projectLink: 'https://example.com/projects/2',
      description: 'Construction of a multi-story office complex',
      teamMemberIds: ['user_456', 'user_101', 'user_202'],
      createdDate: now.subtract(const Duration(days: 60)),
      endDate: now.add(const Duration(days: 90)),
      dailyLogs: makeDailyLogs(10),
      location: 'Location B',
      isActive: true,
      lastUpdated: now,
      coverPhotoUrl: 'https://example.com/cover_2.png',
    ),
    Project(
      id: 'project_3',
      projectName: 'Residential Housing Development',
      creatorId: 'user_789',
      projectLink: 'https://example.com/projects/3',
      description: 'Development of a residential housing area',
      teamMemberIds: ['user_789', 'user_101', 'user_303', 'user_404'],
      createdDate: now.subtract(const Duration(days: 90)),
      endDate: now.add(const Duration(days: 120)),
      dailyLogs: makeDailyLogs(10),
      location: 'Location C',
      isActive: false,
      lastUpdated: now,
      coverPhotoUrl: 'https://example.com/cover_3.png',
    ),
  ];
}
