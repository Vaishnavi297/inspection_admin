import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/inspaction_station.dart';
import '../../services/firebase_service/firestore_service.dart';

class InspactionStationRepository {
  InspactionStationRepository._();
  static final InspactionStationRepository instance = InspactionStationRepository._();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'inspection_stations';

  Future<DocumentReference> addStation(InspactionStation station) async {
    final ref = await _firestoreService.addDocument<InspactionStation>(_collectionPath, toFirestore: (s) => s.toJson(), data: station);
    await ref.update({'sId': ref.id});
    return ref;
  }

  Future<void> setStation(String id, InspactionStation station, {bool merge = false}) async {
    await _firestoreService.setDocument<InspactionStation>('$_collectionPath/$id', toFirestore: (s) => s.toJson(), data: station, merge: merge);
  }

  Future<List<InspactionStation>> getAllStations() async {
    final items = await _firestoreService.getCollectionOnce<InspactionStation>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['sId'] = docId;
        return InspactionStation.fromJson(map);
      },
      queryBuilder: (collection) => collection.orderBy('create_time', descending: false),
    );
    return items;
  }

  Future<void> deleteStation(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }
}
