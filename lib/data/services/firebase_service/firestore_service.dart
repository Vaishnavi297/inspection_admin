import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef FromFirestore<T> = T Function(Map<String, dynamic> data, String id);
typedef ToFirestore<T> = Map<String, dynamic> Function(T model);

class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService instance = FirestoreService._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Optional: call this at app startup to configure settings
  Future<void> init({bool persistenceEnabled = true}) async {
    _db.settings = Settings(persistenceEnabled: persistenceEnabled);
  }

  // -------------------- Basic helpers --------------------

  CollectionReference _colRef(String path) => _db.collection(path);
  DocumentReference _docRef(String path) => _db.doc(path);

  // -------------------- Get / Stream single document --------------------

  Future<T?> getDocumentOnce<T>(
      String path, {
        required FromFirestore<T> fromFirestore,
      }) async {
    final snap = await _docRef(path).get();
    if (!snap.exists) return null;
    final data = snap.data() as Map<String, dynamic>;
    return fromFirestore(data, snap.id);
  }

  // -------------------- Get / Stream single document --------------------

  Future<int?> getDocumentCount<T>(
      String path, {
        Query Function(CollectionReference)? queryBuilder,
      }) async {
    Query query = _colRef(path);
    if (queryBuilder != null) query = queryBuilder(_colRef(path));
    final snap = await query.count().get();
    return snap.count;
  }

  Stream<T?> streamDocument<T>(
      String path, {
        required FromFirestore<T> fromFirestore,
      }) {
    return _docRef(path).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() as Map<String, dynamic>;
      return fromFirestore(data, snap.id);
    });
  }

  // -------------------- Collection operations --------------------

  /// Read collection once with optional query builder
  Future<List<T>> getCollectionOnce<T>(
      String path, {
        FromFirestore<T>? fromFirestore,
        Query Function(CollectionReference)? queryBuilder,
        int? limit,
      }) async {
    Query query = _colRef(path);
    if (queryBuilder != null) query = queryBuilder(_colRef(path));
    if (limit != null) query = query.limit(limit);

    final snap = await query.get();
    final docs = snap.docs;
    if (fromFirestore == null) {
      // return raw maps as T, cast at caller's risk
      return docs.map((d) => d.data() as T).toList();
    }
    return docs.map((d) => fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList();
  }

  /// Stream collection with optional query builder
  Stream<List<T>> streamCollection<T>(
      String path, {
        required FromFirestore<T> fromFirestore,
        Query Function(CollectionReference)? queryBuilder,
        int? limit,
      }) {
    Query query = _colRef(path);
    if (queryBuilder != null) query = queryBuilder(_colRef(path));
    if (limit != null) query = query.limit(limit);

    return query.snapshots().map((snap) => snap.docs
        .map((d) => fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  // -------------------- Create / Update / Delete --------------------

  /// Add document with auto-generated id
  Future<DocumentReference> addDocument<T>(
      String path, {
        required ToFirestore<T> toFirestore,
        required T data,
      }) async {
    print('=== FIRESTORE DEBUG: Adding document to path: $path ===');
    final map = toFirestore(data);
    print('=== FIRESTORE DEBUG: Document data: $map ===');
    
    try {
      final result = await _colRef(path).add(map);
      print('=== FIRESTORE DEBUG: Document added successfully, ID: ${result.id} ===');
      return result;
    } catch (e, stackTrace) {
      print('=== FIRESTORE DEBUG: Error adding document: $e ===');
      print('=== FIRESTORE DEBUG: Stack trace: $stackTrace ===');
      rethrow;
    }
  }

  /// Set document (create or replace) at given path
  Future<void> setDocument<T>(
      String path, {
        required ToFirestore<T> toFirestore,
        required T data,
        bool merge = false,
      }) async {
    final map = toFirestore(data);
    await _docRef(path).set(map, SetOptions(merge: merge));
  }

  /// Update fields of existing document
  Future<void> updateDocument(String path, Map<String, dynamic> updates) async {
    await _docRef(path).update(updates);
  }

  /// Delete a document
  Future<void> deleteDocument(String path) async {
    await _docRef(path).delete();
  }

  // -------------------- Batch & Transactions --------------------

  Future<void> runTransaction(Future<void> Function(Transaction tx) transactionHandler) async {
    await _db.runTransaction((tx) async {
      await transactionHandler(tx);
    });
  }

  Future<void> runBatch(Future<void> Function(WriteBatch batch) batchHandler) async {
    final batch = _db.batch();
    await batchHandler(batch);
    await batch.commit();
  }

  // -------------------- Pagination helper --------------------

  /// Returns a page of results and the lastDocument for next page
  Future<PaginatedResult<T>> getCollectionPage<T>(
      String path, {
        required FromFirestore<T> fromFirestore,
        Query Function(CollectionReference)? queryBuilder,
        DocumentSnapshot? startAfter,
        required int pageSize,
      }) async {
    Query query = _colRef(path);
    if (queryBuilder != null) query = queryBuilder(_colRef(path));
    query = query.limit(pageSize);
    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snap = await query.get();
    final items = snap.docs.map((d) => fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList();
    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
    return PaginatedResult(items: items, lastDocument: lastDoc);
  }

  // -------------------- Utility --------------------

  /// Convert DocumentSnapshot to Map (with id included)
  static Map<String, dynamic> docDataWithId(DocumentSnapshot snap) {
    final data = (snap.data() ?? {}) as Map<String, dynamic>;
    return {...data, 'id': snap.id};
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;

  PaginatedResult({required this.items, this.lastDocument});
}
