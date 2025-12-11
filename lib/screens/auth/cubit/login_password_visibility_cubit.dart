import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPasswordVisibilityCubit extends Cubit<bool> {
  LoginPasswordVisibilityCubit() : super(true);
  void toggleVisibility() => emit(!state);
}
