import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/inspection_station.dart';
import '../../services/firebase_service/firestore_service.dart';

class InspectionStationRepository {
  InspectionStationRepository._();
  static final InspectionStationRepository instance =
      InspectionStationRepository._();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'inspection_stations';

  Future<DocumentReference> addStation(InspectionStation station) async {
    print('=== REPOSITORY DEBUG: Adding station to Firestore... ===');
    print('=== REPOSITORY DEBUG: Station data: ${station.toJson()} ===');

    try {
      final ref = await _firestoreService.addDocument<InspectionStation>(
        _collectionPath,
        toFirestore: (s) => s.toJson(),
        data: station,
      );
      print(
        '=== REPOSITORY DEBUG: Station added successfully, ID: ${ref.id} ===',
      );
      await ref.update({'sId': ref.id});
      print('=== REPOSITORY DEBUG: Updated station with sId field ===');
      return ref;
    } catch (e, stackTrace) {
      print('=== REPOSITORY DEBUG: Error adding station: $e ===');
      print('=== REPOSITORY DEBUG: Stack trace: $stackTrace ===');
      rethrow;
    }
  }

  Future<void> setStation(
    String id,
    InspectionStation station, {
    bool merge = false,
  }) async {
    await _firestoreService.setDocument<InspectionStation>(
      '$_collectionPath/$id',
      toFirestore: (s) => s.toJson(),
      data: station,
      merge: merge,
    );
  }

  Future<List<InspectionStation>> getAllStations() async {
    final items = await _firestoreService.getCollectionOnce<InspectionStation>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['sId'] = docId;
        return InspectionStation.fromJson(map);
      },
      queryBuilder: (collection) =>
          collection.orderBy('create_time', descending: false),
    );
    return items;
  }

  Future<void> deleteStation(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }

  /// Checks if a phone number is already registered.
  /// Returns true if duplicate exists.
  Future<bool> isPhoneRegistered(String phone) async {
    final result = await _firestoreService.getCollectionOnce<InspectionStation>(
      _collectionPath,
      fromFirestore: (data, id) =>
          InspectionStation.fromJson({...data, 'sId': id}),
      queryBuilder: (query) =>
          query.where('station_contact_number', isEqualTo: phone).limit(1),
    );
    return result.isNotEmpty;
  }
}
