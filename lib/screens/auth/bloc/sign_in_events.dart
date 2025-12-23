
part of 'sign_in_bloc.dart';


//create sign_in event
@immutable
class SignInEvent {}

class SignInWithEmailEvent extends SignInEvent {
  final String email;
  final String password;

  SignInWithEmailEvent({required this.email, required this.password});
}

class SignInGoogleLoginEvent extends SignInEvent {}

class ManageSignInNavigation extends SignInEvent {
  final AdminModel adminData;

  ManageSignInNavigation(this.adminData);
}
