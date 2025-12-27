part of 'users_bloc.dart';

abstract class UsersEvent {}

class FetchUsersEvent extends UsersEvent {}

class AddUserEvent extends UsersEvent {
  final String name;
  final String email;
  final String? phone;
  final bool isActive;

  AddUserEvent({
    required this.name,
    required this.email,
    this.phone,
    this.isActive = true,
  });
}

class UpdateUserEvent extends UsersEvent {
  final AppUser user;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;

  UpdateUserEvent({
    required this.user,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
  });
}

class DeleteUserEvent extends UsersEvent {
  final String userId;
  DeleteUserEvent({required this.userId});
}
