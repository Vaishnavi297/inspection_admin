import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspection_station/utils/common/responsive_widget.dart';
import '../../components/app_text_style/app_text_style.dart';
import '/../utils/common/decoration.dart';
import '/../utils/extensions/widget_extensions.dart';
import '../../utils/constants/app_dimension.dart';
import '../../utils/constants/app_strings.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart' show AppRoutes;
import '../../utils/validators.dart';

import '../../components/app_text_field/app_textfield.dart';
import '../../components/app_button/app_button.dart';
import 'cubit/login_password_visibility_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: ResponsiveWidget.isSmallScreen(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.3,
        margin: EdgeInsets.all(s.s16),
        decoration: boxDecorationRoundedWithShadow(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocProvider(
              create: (_) => LoginPasswordVisibilityCubit(),
              child: Form(
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
                          BlocBuilder<LoginPasswordVisibilityCubit, bool>(
                            builder: (context, isObscure) {
                              return textField(
                                controller: passwordTextController,
                                labelText: appStrings.lblPassword,
                                maxLines: 1,
                                hintText: appStrings.lblEnterPassword,
                                prefixIcon: const Icon(Icons.lock),
                                validator: Validators.validatePassword,
                                obscureText: isObscure,
                                suffixIcon: IconButton(
                                  icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => context.read<LoginPasswordVisibilityCubit>().toggleVisibility(),
                                ),
                              );
                            },
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: s.s20),
            // Bottom Login Button
            Column(
              spacing: 8,
              children: [
                AppButton(
                  strTitle: appStrings.lblSignIn,
                  fontColor: appColors.textPrimaryColor,
                  backgroundColor: appColors.primaryColor,
                  isDisable: false,
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pushNamed(context, AppRoutes.home);
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    emailTextController.text = 'demo@inspectionwv.com';
                    passwordTextController.text = '12345678';
                  },
                  child: Text(
                    'Use Demo Credentials',
                    style: secondaryTextStyle(size: s.s14, fontWeight: FontWeight.w200).copyWith(color: appColors.primaryColor, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ).paddingOnly(left: 16, right: 16, bottom: 16),
          ],
        ),
      ).center(),
    );
  }
}
