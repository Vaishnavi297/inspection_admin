import 'package:firebase_auth/firebase_auth.dart';
import 'package:inspection_station/data/data_structure/models/admin.dart';

import '../../services/firebase_service/firebase_authentication_services.dart';
import 'admin_repository.dart';

// customer_auth_repository.dart
// Repository that coordinates Firebase Authentication and Customer Firestore repository.

class AdminAuthRepository {
  AdminAuthRepository._privateConstructor();

  static final AdminAuthRepository instance = AdminAuthRepository._privateConstructor();

  final _adminRepo = AdminRepository.instance;
  final _authService = AuthService.instance;

  /// 1) Register a new user with email & password using Firebase Auth.
  ///    On success, create the customer document in Firestore via CustomerRepository.
  ///    Returns true if both operations succeed, false otherwise.
  ///
  /// Throws FirebaseAuthException from the AuthService (rethrows) so callers can
  /// handle authentication-specific errors. Any Firestore errors are rethrown as-is.
  Future<AdminModel?> registerWithEmailPassword({required String email, required String password, required AdminModel adminData}) async {
    try {
      // Create user in Firebase Auth
      final String? uid = await _authService.createUserWithEmail(email: email, password: password);

      if (uid == null || uid.isEmpty) {
        // Unexpected: Auth created a user but no uid returned
        return null;
      }

      // Build a new Customer instance that includes the authentication token (uid)
      final AdminModel adminToSave = AdminModel(
        id: uid,
        email: adminData.email,
        password: adminData.password,
        name: adminData.name,
        role: adminData.role,
        createdAt: adminData.createdAt,
        updatedAt: adminData.updatedAt,
      );

      // Add customer document to Firestore. CustomerRepository will write the generated
      // document id back into the c_id field of the document.
      var _ref = await _adminRepo.addAdmin(adminToSave);

      return adminToSave.copyWith(id: _ref.id);
    } on FirebaseAuthException catch (e) {
      // Re-throw FirebaseAuthException so caller can handle specific sign_up errors
      rethrow;
    } catch (e) {
      // For any other errors (e.g., Firestore), rethrow to let caller handle it.
      rethrow;
    }
  }

  /// 2) Authenticate a user with email & password using Firebase Auth.
  ///    On success, fetch the corresponding Customer document by email using CustomerRepository
  ///    and return the Customer model. Returns null if no matching customer found.
  ///
  /// Throws FirebaseAuthException from the AuthService (rethrows) so callers can
  /// handle authentication-specific errors. Any Firestore errors are rethrown as-is.
  Future<AdminModel?> authenticateWithEmailPassword({required String email, required String password}) async {
    try {
      final UserCredential cred = await _authService.signInWithEmail(email: email, password: password);

      final String? uid = cred.user?.uid;
      if (uid == null || uid.isEmpty) {
        // Auth succeeded but no uid — treat as failure
        return null;
      }

      // Fetch admin by Firebase Auth UID from Firestore
      // The UID is stored in the 'id' field, not as the document ID
      final AdminModel? admin = await _adminRepo.getAdminByAuthUid(uid);

      return admin;
    } on FirebaseAuthException catch (e) {
      // Re-throw so caller can handle specific sign_up errors
      rethrow;
    } catch (e) {
      // Log or print the error for debugging
      print('Error in authenticateWithEmailPassword: $e');

      // Re-throw other errors (Firestore, parsing, etc.)
      rethrow;
    }
  }

}
