import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';

class ReturnAddressCard extends StatelessWidget {
  final String address;
  final bool showEditButton;
  final void Function()? onTap;
  final void Function()? editTap;

  final Color? cardColor;
  final Color? borderColor;

  const ReturnAddressCard({
    super.key,
    required this.address,
    this.showEditButton = false,
    this.onTap,
    this.editTap,
    this.cardColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
      builder: (context, box, _) {
        final appLocal = box.get(AppConstants.appLocal);
        final isDark = box.get(AppConstants.isDarkTheme, defaultValue: false);
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          shadowColor: isDark ? Colors.black : Colors.black12,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      Assets.svg.locationPurple,
                      colorFilter: ColorFilter.mode(
                          colors(context).primaryColor!, BlendMode.srcIn),
                    ),
                    Gap(8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.withValues(alpha: 0.4)
                            : Colors.black87,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        S.of(context).collectionAddress,
                        style: AppTextStyle(context)
                            .bodyTextSmall
                            .copyWith(fontSize: 12.sp)
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Gap(8.h),
                Text(
                  address,
                  style: AppTextStyle(context)
                      .bodyTextSmall
                      .copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
