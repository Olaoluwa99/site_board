class ProjectSummary {
  final String title;
  final String dateRange;
  final String overview;
  final List<String> completedTasks;
  final List<String> issuesRaised;
  final String upcomingPlans;

  ProjectSummary({
    required this.title,
    required this.dateRange,
    required this.overview,
    required this.completedTasks,
    required this.issuesRaised,
    required this.upcomingPlans,
  });
}