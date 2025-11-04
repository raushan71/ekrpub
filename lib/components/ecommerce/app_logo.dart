// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';

class AppLogo extends StatefulWidget {
  final bool isAnimation;
  final bool? withAppName;
  final bool centerAlign;
  const AppLogo({
    super.key,
    this.withAppName = true,
    this.isAnimation = true,
    this.centerAlign = true,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimation) {
      // Initialize the controller and set the duration
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );

      // Create a curved animation to control the easing
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );

      // Set up a listener to rebuild the widget when animation value changes
      _animation.addListener(() {
        setState(() {});
      });

      // Repeat the animation indefinitely
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.isAnimation) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.centerAlign
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ValueListenableBuilder(
            valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
            builder: (context, settingBox, _) {
              final String? appLogo = settingBox.get(AppConstants.appLogo);
              if (appLogo != null) {
                return CachedNetworkImage(
                  imageUrl: appLogo,
                  height: 55.h,
                  width: 55.w,
                );
              }
              return Image.asset(
                  width: 55.w, height: 55.w, "assets/png/favicon.png");
            }),
        if (widget.withAppName ?? false)
          ValueListenableBuilder(
              valueListenable:
                  Hive.box(AppConstants.appSettingsBox).listenable(),
              builder: (context, settingsBox, _) {
                final String appName = settingsBox.get(AppConstants.appName,
                    defaultValue: 'Ekray');
                return SizedBox(
                  child: Row(
                    children: [
                      Gap(14.w),
                      Text(
                        appName,
                        style: AppTextStyle(context).title.copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1),
                      )
                    ],
                  ),
                );
              })
      ],
    );
  }
}
