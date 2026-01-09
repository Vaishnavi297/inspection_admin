import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../data_structure/models/dashboard_models.dart';
import '../../services/firebase_service/firestore_service.dart';

class DashboardRepository {
  DashboardRepository._();
  static final DashboardRepository instance = DashboardRepository._();

  final _firestore = FirestoreService.instance;

  Future<DashboardStats> getStats() async {
    // 1. Fetch all counts in parallel using Future.wait
    try {
      final now = DateTime.now();
      final startOfDay = Timestamp.fromDate(
        DateTime(now.year, now.month, now.day),
      );

      final results = await Future.wait([
        // Stations [0, 1]
        _firestore.getDocumentCount('inspection_stations'),
        _firestore.getDocumentCount(
          'inspection_stations',
          queryBuilder: (q) =>
              q.where('station_activation_status', isEqualTo: true),
        ),

        // Inspectors [2]
        _firestore.getDocumentCount('inspectors'),

        // Inspections (Today) [3, 4, 5]
        _firestore.getDocumentCount(
          'inspections',
          queryBuilder: (q) =>
              q.where('create_time', isGreaterThanOrEqualTo: startOfDay),
        ),
        _firestore.getDocumentCount(
          'inspections',
          queryBuilder: (q) => q
              .where('create_time', isGreaterThanOrEqualTo: startOfDay)
              .where('status', isEqualTo: 'pass'),
        ),
        _firestore.getDocumentCount(
          'inspections',
          queryBuilder: (q) => q
              .where('create_time', isGreaterThanOrEqualTo: startOfDay)
              .where('status', isEqualTo: 'fail'),
        ),

        // Appointments [6, 7, 8]
        _firestore.getDocumentCount('appointments'),
        _firestore.getDocumentCount(
          'appointments',
          queryBuilder: (q) => q.where('status', isEqualTo: 'scheduled'),
        ),
        _firestore.getDocumentCount(
          'appointments',
          queryBuilder: (q) => q.where('status', isEqualTo: 'completed'),
        ),

        // Vehicles [9, 10]
        _firestore.getDocumentCount('vehicles'),
        _firestore.getDocumentCount(
          'vehicles',
          queryBuilder: (q) => q.where('status', isEqualTo: 'active'),
        ),

        // Users [11]
        _firestore.getDocumentCount('users'),
      ]);

      return DashboardStats(
        totalStations: results[0] ?? 0,
        activeStations: results[1] ?? 0,
        totalInspectors: results[2] ?? 0,
        todayInspections: results[3] ?? 0,
        passedInspections: results[4] ?? 0,
        failedInspections: results[5] ?? 0,
        totalAppointments: results[6] ?? 0,
        scheduledAppointments: results[7] ?? 0,
        completedAppointments: results[8] ?? 0,
        totalVehicles: results[9] ?? 0,
        activeStickers: results[10] ?? 0,
        totalUsers: results[11] ?? 0,
      );
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return const DashboardStats();
    }
  }

  Future<List<DashboardActivity>> getRecentActivities() async {
    try {
      return await _firestore.getCollectionOnce<DashboardActivity>(
        'inspections',
        queryBuilder: (q) =>
            q.orderBy('create_time', descending: true).limit(5),
        fromFirestore: (data, id) {
          final createdAt =
              (data['create_time'] as Timestamp?)?.toDate() ?? DateTime.now();
          final time = DateFormat('hh:mm a').format(createdAt);
          return DashboardActivity(
            title: data['vehicle_info'] ?? 'Unknown Vehicle',
            time: time,
            subtitle: data['station_name'] ?? 'Unknown Station',
            user: data['inspector_name'] ?? 'Unknown Inspector',
            status: data['status'] ?? 'pass',
          );
        },
      );
    } catch (e) {
      print('Error fetching recent activities: $e');
      return [];
    }
  }

  Future<List<DashboardTopStation>> getTopStations() async {
    // For now, fetching first 4 stations as we don't have aggregation for "top performing"
    try {
      return await _firestore.getCollectionOnce<DashboardTopStation>(
        'inspection_stations',
        limit: 4,
        fromFirestore: (data, id) {
          return DashboardTopStation(
            name: data['station_name'] ?? 'Unknown',
            meta:
                '${data['s_county_details']['county_name'] ?? 'Unknown County'} • ${(data['inspactors'] ?? 0)} Inspectors',
            value:
                '${(data['total_inspections'] ?? 0)}', // Assuming a counter exists, else 0
          );
        },
      );
    } catch (e) {
      return [];
    }
  }
}
