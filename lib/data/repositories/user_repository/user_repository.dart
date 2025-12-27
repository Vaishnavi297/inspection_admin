import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/user.dart';
import '../../services/firebase_service/firestore_service.dart';

class UserRepository {
  UserRepository._privateConstructor();
  static final UserRepository instance = UserRepository._privateConstructor();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'customers';

  Future<DocumentReference> addUser(AppUser user) async {
    final ref = await _firestoreService.addDocument<AppUser>(_collectionPath, toFirestore: (u) => u.toJson(), data: user);
    await ref.update({'user_id': ref.id});
    return ref;
  }

  Future<void> setUser(String id, AppUser user, {bool merge = false}) async {
    await _firestoreService.setDocument<AppUser>('$_collectionPath/$id', toFirestore: (u) => u.toJson(), data: user, merge: merge);
  }

  Future<AppUser?> getUserById(String id) async {
    return await _firestoreService.getDocumentOnce<AppUser>(
      '$_collectionPath/$id',
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['user_id'] = docId;
        return AppUser.fromJson(map);
      },
    );
  }

  Future<List<AppUser>> getAllUsers() async {
    final items = await _firestoreService.getCollectionOnce<AppUser>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['user_id'] = docId;
        return AppUser.fromJson(map);
      },
      queryBuilder: (collection) => collection.orderBy('create_time', descending: false),
    );
    return items;
  }

  Future<void> deleteUser(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }
}
