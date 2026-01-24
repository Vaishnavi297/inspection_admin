// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:inspection_station/data/data_structure/models/admin.dart';
import 'package:inspection_station/utils/common/responsive_widget.dart';

import '../../components/app_text_style/app_text_style.dart';
// import '../../data/repositories/admin_repository/admin_auth_repositories.dart';
import '../../data/repositories/admin_repository/admin_repository.dart';
import '/../utils/common/decoration.dart';
import '/../utils/extensions/widget_extensions.dart';
import '../../utils/constants/app_dimension.dart';
import '../../utils/constants/app_strings.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart' show AppRoutes;
import '../../utils/validators.dart';

import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_button/app_button.dart';
import 'bloc/sign_in_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  void _login({bool useDemoCredentials = false}) {
    if (useDemoCredentials) {
      emailTextController.text = 'demo@inspectionwv.com';
      passwordTextController.text = '12345678';
      // Trigger validation after setting demo credentials
      formKey.currentState?.validate();
    }

    if (formKey.currentState?.validate() ?? false) {
      // Dispatch login event to bloc
      context.read<SignInBloc>().add(SignInWithEmailEvent(email: emailTextController.text.trim(), password: passwordTextController.text.trim()));
    }
  }

  // Future<void> _registerAdmin({bool useDemoCredentials = false}) async {
  //   if (useDemoCredentials) {
  //     emailTextController.text = 'demo@inspectionwv.com';
  //     passwordTextController.text = '12345678';
  //   }

  //   if (!(formKey.currentState?.validate() ?? false)) return;

  //   final now = DateTime.now().toIso8601String();

  //   final admin = AdminModel(
  //     id: '',
  //     email: emailTextController.text.trim(),
  //     password: passwordTextController.text.trim(),
  //     name: 'Admin',
  //     role: 'admin',
  //     createdAt: Timestamp.fromDate(DateTime.parse(now)),
  //     isAdminLogout: false,
  //     updatedAt: Timestamp.fromDate(DateTime.parse(now)),
  //   );

  //   await AdminAuthRepository.instance.registerWithEmailPassword(email: admin.email, password: admin.password, adminData: admin);
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listenWhen: (previous, current) {
        // Only listen to authenticated or error states, not loading
        return current is SignInEmailAuthenticated || current is SignInError;
      },
      listener: (context, state) {
        if (state is SignInEmailAuthenticated) {
          // Persist admin data locally for sidebar/profile display
          AdminRepository.instance.manageAdminDataLocally(state.loginAdmin);
          // Navigate to home on successful login
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        } else if (state is SignInError) {
          // Show error message
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Login failed. Please check your credentials.'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
        }
      },
      child: Scaffold(
        body: Container(
          width: ResponsiveWidget.isSmallScreen(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.3,
          margin: EdgeInsets.all(s.s16),
          decoration: boxDecorationRoundedWithShadow(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appStrings.lblAdminLogin,
                            style: primaryTextStyle(size: s.s20, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: s.s8),
                          Text(
                            appStrings.lblBySigningInspectionWV,
                            style: secondaryTextStyle(size: s.s14, fontWeight: FontWeight.w200),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),

                      Divider(height: 0, thickness: 0.2),
                      Column(
                        children: [
                          textField(
                            controller: emailTextController,
                            validator: (v) => Validators.validateRequired(v, fieldName: appStrings.lblUserName),
                            labelText: appStrings.lblUserName,
                            hintText: appStrings.lblEnterUserName,
                            prefixIcon: const Icon(Icons.person),
                          ),

                          textField(
                            controller: passwordTextController,
                            labelText: appStrings.lblPassword,
                            maxLines: 1,
                            hintText: appStrings.lblEnterPassword,
                            prefixIcon: const Icon(Icons.lock),
                            validator: Validators.validatePassword,
                            obscureText: true,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                    ],
                  ),
                ),
              ),
              SizedBox(height: s.s20),
              // Bottom Login Button
              BlocBuilder<SignInBloc, SignInState>(
                builder: (context, state) {
                  final isLoading = state is SignInLoading;
                  return Column(
                    spacing: 8,
                    children: [
                      AppButton(
                        strTitle: isLoading ? 'Signing In...' : appStrings.lblSignIn,
                        fontColor: appColors.textPrimaryColor,
                        backgroundColor: appColors.primaryColor,
                        isDisable: isLoading,
                        onTap: isLoading ? null : _login,
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () => _login(useDemoCredentials: true),
                        child: Text(
                          'Use Demo Credentials',
                          style: secondaryTextStyle(size: s.s14, fontWeight: FontWeight.w200).copyWith(color: appColors.primaryColor, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ).paddingOnly(left: 16, right: 16, bottom: 16);
                },
              ),
            ],
          ),
        ).center(),
      ),
    );
  }
}
