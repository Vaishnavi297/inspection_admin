part of 'users_bloc.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<AppUser> users;
  UsersLoaded({required this.users});
}

class UsersError extends UsersState {
  final String errorMessage;
  UsersError({required this.errorMessage});
}
