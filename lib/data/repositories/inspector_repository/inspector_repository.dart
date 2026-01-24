import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/inspector.dart';
import '../../services/firebase_service/firestore_service.dart';

class InspectorRepository {
  InspectorRepository._privateConstructor();
  static final InspectorRepository instance =
      InspectorRepository._privateConstructor();

  final _firestoreService = FirestoreService.instance;
  final String _collectionPath = 'inspectors';
  final String _stationCollectionPath = 'inspection_stations';

  Future<void> createInspector(Inspector inspector) async {
    final stationId = inspector.stationId;
    if (stationId == null || stationId.isEmpty) {
      throw Exception('Inspector must be assigned to a station');
    }

    final firestore = FirebaseFirestore.instance;
    final stationRef = firestore
        .collection(_stationCollectionPath)
        .doc(stationId);
    final inspectorRef = firestore.collection(_collectionPath).doc();

    await firestore.runTransaction((transaction) async {
      // 1. Validate Station
      final stationSnapshot = await transaction.get(stationRef);
      if (!stationSnapshot.exists) {
        throw Exception('Target station does not exist');
      }

      final stationData = stationSnapshot.data() as Map<String, dynamic>;

      // Optional: Check if station is active (based on previous prompt requirements)
      // "New station is inactive" -> Prevent update.
      // Assuming 'station_activation_status' is the boolean flag based on InspactionStation model.
      final isActive = stationData['station_activation_status'] == true;
      if (!isActive) {
        throw Exception('Target station is inactive');
      }

      final currentCount = (stationData['inspactors'] as num?)?.toInt() ?? 0;

      // 2. Create Inspector
      // We set the ID in the object to match the generated ref ID
      final newInspector = inspector.copyWith(inspectorId: inspectorRef.id);

      // Note: we must convert to JSON.
      // Ensure the 'inspector_id' field is present in the document.
      transaction.set(inspectorRef, newInspector.toJson());

      // 3. Increment Station Count
      transaction.update(stationRef, {'inspactors': currentCount + 1});
    });
  }
  Future<void> updateInspectorTransaction(Inspector newInspector) async {
    final inspectorId = newInspector.inspectorId;
    if (inspectorId == null) {
      throw Exception('Inspector ID is required for update');
    }

    final firestore = FirebaseFirestore.instance;
    final inspectorRef = firestore.collection(_collectionPath).doc(inspectorId);

    await firestore.runTransaction((transaction) async {
      // 1. Get current inspector to check for station change
      final currentInspectorSnap = await transaction.get(inspectorRef);
      if (!currentInspectorSnap.exists) {
        throw Exception('Inspector not found');
      }

      final currentInspectorData = currentInspectorSnap.data()!;
      final currentStationId = currentInspectorData['station_id'] as String?;
      final newStationId = newInspector.stationId;

      // Check if station changed
      if (currentStationId != newStationId) {
        // Handle Move
        if (newStationId == null) {
          throw Exception('Cannot move inspector to null station');
        }

        final newStationRef = firestore
            .collection(_stationCollectionPath)
            .doc(newStationId);

        // Read New Station
        final newStationSnap = await transaction.get(newStationRef);
        if (!newStationSnap.exists) {
          throw Exception('New station does not exist');
        }

        final newStationData = newStationSnap.data() as Map<String, dynamic>;
        if (newStationData['station_activation_status'] != true) {
          throw Exception('New station is inactive');
        }

        // Handle Old Station (if it existed)
        if (currentStationId != null) {
          final oldStationRef = firestore
              .collection(_stationCollectionPath)
              .doc(currentStationId);
          final oldStationSnap = await transaction.get(oldStationRef);

          if (oldStationSnap.exists) {
            final oldStationData =
                oldStationSnap.data() as Map<String, dynamic>;
            final oldCount =
                (oldStationData['inspactors'] as num?)?.toInt() ?? 0;
            if (oldCount > 0) {
              transaction.update(oldStationRef, {'inspactors': oldCount - 1});
            }
          }
        }

        // Increment New
        final newCount = (newStationData['inspactors'] as num?)?.toInt() ?? 0;
        transaction.update(newStationRef, {'inspactors': newCount + 1});
      }

      // 2. Update Inspector Data
      transaction.update(inspectorRef, newInspector.toJson());
    });
  }

  /// Deletes an inspector and atomically decrements the station's count.
  /// "Ensure count never goes below zero" -> Handled by check.
  /// "If station update fails -> abort inspector deletion" -> Transaction atomicity handles this.
  Future<void> deleteInspectorTransaction(String inspectorId) async {
    final firestore = FirebaseFirestore.instance;
    final inspectorRef = firestore.collection(_collectionPath).doc(inspectorId);

    await firestore.runTransaction((transaction) async {
      // 1. Get Inspector to find station
      final inspectorSnap = await transaction.get(inspectorRef);
      if (!inspectorSnap.exists) {
        throw Exception('Inspector already deleted or not found');
      }

      final inspectorData = inspectorSnap.data()!;
      final stationId = inspectorData['station_id'] as String?;

      if (stationId != null) {
        final stationRef = firestore
            .collection(_stationCollectionPath)
            .doc(stationId);
        final stationSnap = await transaction.get(stationRef);

        if (stationSnap.exists) {
          final stationData = stationSnap.data() as Map<String, dynamic>;
          final currentCount =
              (stationData['inspactors'] as num?)?.toInt() ?? 0;

          if (currentCount > 0) {
            transaction.update(stationRef, {'inspactors': currentCount - 1});
          }
        }
      }

      // 2. Delete Inspector
      transaction.delete(inspectorRef);
    });
  }

  Future<List<Inspector>> getAllInspectors() async {
    final items = await _firestoreService.getCollectionOnce<Inspector>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        map['inspector_id'] = docId;
        return Inspector.fromJson(map);
      },
      queryBuilder: (collection) =>
          collection.orderBy('created_at', descending: false),
    );
    return items;
  }


  Future<void> toggleActive(String id, bool isActive) async {
    await _firestoreService.updateDocument('$_collectionPath/$id', {
      'is_active': isActive,
      'updated_at': Timestamp.now(),
    });
  }
}
