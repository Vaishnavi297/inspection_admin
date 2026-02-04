import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data_structure/models/state_model.dart';
import '../../services/firebase_service/firestore_service.dart';

class StateRepository {
  StateRepository._privateConstructor();
  static final StateRepository instance = StateRepository._privateConstructor();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'state';

  Future<DocumentReference> addState(StateModel state) async {
    final ref = await _firestoreService.addDocument<StateModel>(
      _collectionPath,
      toFirestore: (s) => s.toJson(),
      data: state,
    );
    await ref.update({'state_id': ref.id});
    return ref;
  }

  Future<void> updateState(
    String id,
    StateModel state, {
    bool merge = true,
  }) async {
    await _firestoreService.setDocument<StateModel>(
      '$_collectionPath/$id',
      toFirestore: (s) => s.toJson(),
      data: state,
      merge: merge,
    );
  }

  Future<StateModel?> getStateById(String id) async {
    return await _firestoreService.getDocumentOnce<StateModel>(
      '$_collectionPath/$id',
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['state_id'] = docId;
        return StateModel.fromJson(map);
      },
    );
  }

  Future<List<StateModel>> getAllStates() async {
    final items = await _firestoreService.getCollectionOnce<StateModel>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['state_id'] = docId;
        return StateModel.fromJson(map);
      },
      queryBuilder: (collection) =>
          collection.orderBy('create_time', descending: false),
    );
    return items;
  }

  Future<void> deleteState(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }

  Stream<List<StateModel>> streamAllStates() {
    return _firestoreService.streamCollection<StateModel>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['state_id'] = docId;
        return StateModel.fromJson(map);
      },
      queryBuilder: (collection) =>
          collection.orderBy('create_time', descending: false),
    );
  }
}
