import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/vehicle.dart';
import '../../services/firebase_service/firestore_service.dart';

class VehicleRepository {
  VehicleRepository._privateConstructor();
  static final VehicleRepository instance = VehicleRepository._privateConstructor();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'vehicles';

  Future<DocumentReference> addVehicle(Vehicle vehicle) async {
    final ref = await _firestoreService.addDocument<Vehicle>(_collectionPath, toFirestore: (v) => v.toJson(), data: vehicle);
    await ref.update({'v_id': ref.id});
    return ref;
  }

  Future<void> setVehicle(String id, Vehicle vehicle, {bool merge = false}) async {
    await _firestoreService.setDocument<Vehicle>('$_collectionPath/$id', toFirestore: (v) => v.toJson(), data: vehicle, merge: merge);
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final items = await _firestoreService.getCollectionOnce<Vehicle>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['v_id'] = docId;
        return Vehicle.fromJson(map);
      },
      queryBuilder: (collection) => collection.orderBy('create_time', descending: false),
    );
    return items;
  }

  Future<void> deleteVehicle(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }
}
