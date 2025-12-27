import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/inspector.dart';
import '../../services/firebase_service/firestore_service.dart';

class InspectorRepository {
  InspectorRepository._privateConstructor();
  static final InspectorRepository instance = InspectorRepository._privateConstructor();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'inspectors';

  Future<DocumentReference> addInspector(Inspector inspector) async {
    final ref = await _firestoreService.addDocument<Inspector>(_collectionPath, toFirestore: (i) => i.toJson(), data: inspector);
    await ref.update({'inspector_id': ref.id});
    return ref;
  }

  Future<void> setInspector(String id, Inspector inspector, {bool merge = false}) async {
    await _firestoreService.setDocument<Inspector>('$_collectionPath/$id', toFirestore: (i) => i.toJson(), data: inspector, merge: merge);
  }

  Future<List<Inspector>> getAllInspectors() async {
    final items = await _firestoreService.getCollectionOnce<Inspector>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['inspector_id'] = docId;
        return Inspector.fromJson(map);
      },
      queryBuilder: (collection) => collection.orderBy('created_at', descending: false),
    );
    return items;
  }

  Future<void> deleteInspector(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _firestoreService.updateDocument('$_collectionPath/$id', {'is_active': isActive, 'updated_at': Timestamp.now()});
  }
}
