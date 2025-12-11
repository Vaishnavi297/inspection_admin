import 'package:inspection_station/utils/extensions/duration_extension.dart';
import 'package:inspection_station/utils/extensions/int_extension.dart';

import '../../utils/routes/app_routes.dart';
import '/../utils/constants/app_assets.dart';
import '../../utils/constants/app_dimension.dart';
import '../../utils/constants/app_strings.dart';
import '../../components/app_text_style/app_text_style.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future init() async {
    await 3.second.delay();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.imgLogo, height: s.s120, width: s.s120),
            Padding(
              padding: EdgeInsets.all(s.s8),
              child: Column(
                children: [Text(appStrings.lblInspectionWV, style: boldTextStyle(size: FontSize.s32))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
