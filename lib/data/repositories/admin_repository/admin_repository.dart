import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data_structure/models/admin.dart';
import '../../services/firebase_service/firestore_service.dart';
import '../../services/local_storage_services/local_storage_services.dart';

class AdminRepository {
  AdminRepository._privateConstructor();

  static final AdminRepository instance = AdminRepository._privateConstructor();

  final _firestoreService = FirestoreService.instance;
  final _localStorageService = LocalStorageService.instance;
  final String _collectionPath = 'admin';
  bool _isLogin = false;
  bool _isAdminLogout = false;
  String? _aid;
  String? _aName;
  AdminModel? _adminData;

  bool get isLogin => _isLogin;
  bool get isAdminLogout => _isAdminLogout;

  String? get aid => _aid;

  String? get aName => _aName;

  AdminModel? get adminData => _adminData;

  // -------------------- Create --------------------

  /// Adds a admin and returns the created DocumentReference
  Future<DocumentReference> addAdmin(AdminModel admin) async {
    final data = admin.toJson();
    // data.remove('id');

    final ref = await _firestoreService.addDocument<Map<String, dynamic>>(_collectionPath, toFirestore: (m) => m, data: data);

    // Update a_id in Firestore
    // await ref.update({'id': ref.id});

    return ref;
  }

  Future<void> setAdmin(String id, AdminModel admin, {bool merge = false}) async {
    final data = admin.toJson();
    await _firestoreService.setDocument<Map<String, dynamic>>('$_collectionPath/$id', toFirestore: (m) => m, data: data, merge: merge);
  }

  // -------------------- Read --------------------

  /// Get admin by firestore document id
  Future<AdminModel?> getAdminById(String id) async {
    final doc = await _firestoreService.getDocumentOnce<AdminModel>(
      '$_collectionPath/$id',
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        return AdminModel.fromJson(map);
      },
    );
    return doc;
  }

  /// Get admin by Firebase Auth UID (stored in the 'id' field)
  Future<AdminModel?> getAdminByAuthUid(String authUid) async {
    final admins = await _firestoreService.getCollectionOnce<AdminModel>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        return AdminModel.fromJson(map);
      },
      queryBuilder: (collection) => collection.where('id', isEqualTo: authUid).limit(1),
    );
    return admins.isNotEmpty ? admins.first : null;
  }

  /// Get admin by email
  Future<AdminModel?> getAdminByEmail(String email) async {
    final admins = await _firestoreService.getCollectionOnce<AdminModel>(
      _collectionPath,
      fromFirestore: (data, docId) {
        final map = Map<String, dynamic>.from(data);
        return AdminModel.fromJson(map);
      },
      queryBuilder: (collection) => collection.where('email', isEqualTo: email).limit(1),
    );
    return admins.isNotEmpty ? admins.first : null;
  }

  /// Store admin data locally on device
  Future manageAdminDataLocally(AdminModel admin) async {
    _localStorageService.spWriteBool(LocalStorageService.kisLogin, true);
    _isLogin = true;

    _localStorageService.spWriteString(LocalStorageService.kAID, admin.id);
    _aid = admin.id;
  
    _localStorageService.spWriteString(LocalStorageService.kAName, admin.name);
    _aName = admin.name;
      final localAdminJson = {
      'id': admin.id,
      'email': admin.email,
      'name': admin.name,
      'role': admin.role,
      'isAdminLogout': admin.isAdminLogout ?? false,
      'createdAt': admin.createdAt.toDate().toIso8601String(),
      'updatedAt': admin.updatedAt.toDate().toIso8601String(),
    };
    _localStorageService.spWriteJson(LocalStorageService.kAdminData, localAdminJson);
    _isAdminLogout = false;
    _adminData = admin;
  }

  /// get admin data from locally on device
  Future getAdminData() async {
    _isLogin = (await _localStorageService.spReadBool(LocalStorageService.kisLogin)) ?? false;
    try {
      if (_isLogin) {
        _aid = await _localStorageService.spReadString(LocalStorageService.kAID);
        AdminModel? admin = await getAdminById(_aid!);
        if (admin != null) {
          _isAdminLogout = true;
          if (!(admin.isAdminLogout ?? false)) {
            await manageAdminDataLocally(admin);
            _isAdminLogout = false;
          }
        } else {
          _isAdminLogout = true;
        }
      }
    } catch (e) {
      _isAdminLogout = true;
    }
  }
}
