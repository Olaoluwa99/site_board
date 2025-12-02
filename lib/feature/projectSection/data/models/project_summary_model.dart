import '../../domain/entities/project_summary.dart';

class ProjectSummaryModel extends ProjectSummary {
  ProjectSummaryModel({
    required super.title,
    required super.dateRange,
    required super.overview,
    required super.completedTasks,
    required super.issuesRaised,
    required super.upcomingPlans,
  });

  factory ProjectSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProjectSummaryModel(
      title: json['title'] ?? '',
      dateRange: json['date_range'] ?? '',
      overview: json['overview'] ?? '',
      completedTasks: List<String>.from(json['completed_tasks'] ?? []),
      issuesRaised: List<String>.from(json['issues_raised'] ?? []),
      upcomingPlans: json['upcoming_plans'] ?? '',
    );
  }
}