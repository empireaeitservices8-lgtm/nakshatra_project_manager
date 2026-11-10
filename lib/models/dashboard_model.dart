// =============================================================================
//  DashboardModel — summary data returned by /dashboard
// =============================================================================

class DashboardModel {
  final int totalBoards;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final List<dynamic> recentActivity;

  const DashboardModel({
    required this.totalBoards,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.recentActivity,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalBoards: json['total_boards'] as int? ?? 0,
      totalTasks: json['total_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      pendingTasks: json['pending_tasks'] as int? ?? 0,
      overdueTasks: json['overdue_tasks'] as int? ?? 0,
      recentActivity: json['recent_activity'] as List? ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_boards': totalBoards,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'pending_tasks': pendingTasks,
        'overdue_tasks': overdueTasks,
        'recent_activity': recentActivity,
      };
}
