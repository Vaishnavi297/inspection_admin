import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/country.dart';
import '../../services/firebase_service/firestore_service.dart';

class CountyRepository {
  CountyRepository._privateConstructor();
  static final CountyRepository instance = CountyRepository._privateConstructor();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'county';

  Future<DocumentReference> addCounty(County county) async {
    final ref = await _firestoreService.addDocument<County>(_collectionPath, toFirestore: (c) => c.toJson(), data: county);
    await ref.update({'county_id': ref.id});
    return ref;
  }

  Future<void> setCounty(String id, County county, {bool merge = false}) async {
    await _firestoreService.setDocument<County>('$_collectionPath/$id', toFirestore: (c) => c.toJson(), data: county, merge: merge);
  }

  Future<County?> getCountyById(String id) async {
    return await _firestoreService.getDocumentOnce<County>(
      '$_collectionPath/$id',
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['county_id'] = docId;
        return County.fromJson(map);
      },
    );
  }

  Future<List<County>> getAllCounties() async {
    final items = await _firestoreService.getCollectionOnce<County>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['county_id'] = docId;
        return County.fromJson(map);
      },
      queryBuilder: (collection) => collection.orderBy('create_time', descending: false),
    );
    return items;
  }

  Future<void> deleteCounty(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }
}
