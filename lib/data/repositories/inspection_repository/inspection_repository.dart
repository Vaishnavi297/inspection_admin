import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/inspection.dart';
import '../../services/firebase_service/firestore_service.dart';

class InspectionRepository {
  InspectionRepository._();
  static final InspectionRepository instance = InspectionRepository._();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'inspection_appointment';

  Future<DocumentReference> addInspection(Inspection inspection) async {
    try {
      final ref = await _firestoreService.addDocument<Inspection>(
        _collectionPath,
        toFirestore: (s) => s.toJson(),
        data: inspection,
      );
      return ref;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInspection(
    String id,
    Inspection inspection, {
    bool merge = false,
  }) async {
    await _firestoreService.setDocument<Inspection>(
      '$_collectionPath/$id',
      toFirestore: (s) => s.toJson(),
      data: inspection,
      merge: merge,
    );
  }

  Future<List<Inspection>> getAllInspections() async {
    final items = await _firestoreService.getCollectionOnce<Inspection>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        // data usually doesn't have the ID inside if it's from the doc source,
        // but here the model has appointment_id which seems to be the ID.
        // However, I'll rely on what the model expects.
        // The model has appointment_id field.
        // I will map docId to appointment_id if it's missing or consistent.
        // Actually, the sample data has "appointment_id".
        return Inspection.fromJson(map);
      },
      queryBuilder: (collection) =>
          collection.orderBy('create_time', descending: true),
    );
    return items;
  }

  Future<void> deleteInspection(String id) async {
    await _firestoreService.deleteDocument('$_collectionPath/$id');
  }
}
