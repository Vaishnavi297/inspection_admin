class DashboardStats {
  final int totalStations;
  final int activeStations;
  final int totalInspectors;
  final int todayInspections;
  final int passedInspections;
  final int failedInspections;
  final int totalAppointments;
  final int scheduledAppointments;
  final int completedAppointments;
  final int totalVehicles;
  final int activeStickers;
  final int totalUsers;

  const DashboardStats({
    this.totalStations = 0,
    this.activeStations = 0,
    this.totalInspectors = 0,
    this.todayInspections = 0,
    this.passedInspections = 0,
    this.failedInspections = 0,
    this.totalAppointments = 0,
    this.scheduledAppointments = 0,
    this.completedAppointments = 0,
    this.totalVehicles = 0,
    this.activeStickers = 0,
    this.totalUsers = 0,
  });
}

class DashboardActivity {
  final String title;
  final String time;
  final String subtitle;
  final String user;
  final String status; // 'pass' or 'fail'

  const DashboardActivity({required this.title, required this.time, required this.subtitle, required this.user, required this.status});
}

class DashboardTopStation {
  final String name;
  final String meta;
  final String value;

  const DashboardTopStation({required this.name, required this.meta, required this.value});
}
