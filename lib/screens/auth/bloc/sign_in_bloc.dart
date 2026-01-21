import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_structure/models/admin.dart';
import '../../../data/repositories/admin_repository/admin_auth_repositories.dart';
import '../../../data/repositories/admin_repository/admin_repository.dart';
import '../../../data/services/firebase_service/firebase_authentication_services.dart';

part 'sign_in_events.dart';
part 'sign_in_states.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AdminAuthRepository _adminAuthRepo;
  SignInBloc()
    : _adminAuthRepo = AdminAuthRepository.instance,
      super(SignInInitial()) {
    // Email register (create firebase user + create firestore customer)
    // on<AuthEmailRegisterEvent>((event, emit) async {
    //   emit(AuthLoading());
    //   try {
    //     final customerTemplate = Customer(
    //       cName: event.name ?? event.email.split('@').first,
    //       cActivationStatus: true,
    //       cEmail: event.email,
    //       cMobileNo: event.phone,
    //     );

    //     final customer = await _customerAuthRepo.registerWithEmailPassword(
    //       email: event.email,
    //       password: event.password,
    //       customerData: customerTemplate,
    //     );

    //     if (customer!=null) {
    //       emit(AuthEmailAuthenticated(customer));
    //     } else {
    //       emit(AuthError('Registration failed: unexpected result.'));
    //     }
    //   } on FirebaseAuthException catch (e) {
    //     final message = AuthErrorMessages.getMessage(e.code);
    //     emit(AuthError(message));
    //   } catch (e) {
    //     emit(AuthError(e.toString()));
    //   }
    // });

    // Email login (authenticate + fetch Admin)
    on<SignInWithEmailEvent>((event, emit) async {
      emit(SignInLoading());
      try {
        final admin = await _adminAuthRepo.authenticateWithEmailPassword(
          email: event.email,
          password: event.password,
        );

        if (admin != null) {
          await AdminRepository.instance.manageAdminDataLocally(admin);
          emit(SignInEmailAuthenticated(admin));
        } else {
          emit(
            SignInError('Authentication succeeded but no admin record found.'),
          );
        }
      } on FirebaseAuthException catch (e) {
        final message = AuthErrorMessages.getMessage(e.code);
        emit(SignInError(message));
      } catch (e) {
        emit(SignInError(e.toString()));
      }
    });
  }
}
