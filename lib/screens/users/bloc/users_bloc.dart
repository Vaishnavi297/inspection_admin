import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_structure/models/user.dart';
import '../../../data/repositories/user_repository/user_repository.dart';

part 'users_events.dart';
part 'users_states.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository _repo;

  UsersBloc() : _repo = UserRepository.instance, super(UsersInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<AddUserEvent>(_onAddUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final users = await _repo.getAllUsers();
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(UsersError(errorMessage: e.toString()));
    }
  }

  Future<void> _onAddUser(AddUserEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final user = AppUser(cId: '', cName: event.name, cEmail: event.email, cMobileNo: event.phone, cActivationStatus: event.isActive, createTime: DateTime.now(), updateTime: DateTime.now());
      await _repo.addUser(user);
      final users = await _repo.getAllUsers();
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(UsersError(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final updated = event.user.copyWith(cName: event.name, cEmail: event.email, cMobileNo: event.phone, cActivationStatus: event.isActive, updateTime: DateTime.now());
      await _repo.setUser(event.user.cId!, updated);
      final users = await _repo.getAllUsers();
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(UsersError(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUserEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      await _repo.deleteUser(event.userId);
      final users = await _repo.getAllUsers();
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(UsersError(errorMessage: e.toString()));
    }
  }
}
