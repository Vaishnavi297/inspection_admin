part of 'sign_in_bloc.dart';

@immutable
sealed class SignInState {}

final class SignInInitial extends SignInState {}
final class SignInLoading extends SignInState {
}

final class SignInError extends SignInState {
  final String? errorMessage;

  SignInError(this.errorMessage);
}

final class SignInEmailAuthenticated extends SignInState {
  final AdminModel loginAdmin;
  SignInEmailAuthenticated(this.loginAdmin);
}


