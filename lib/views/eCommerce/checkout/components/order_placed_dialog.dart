import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/cart/hive_cart_model.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';

class OrderPlacedDialog extends ConsumerWidget {
  Widget? customButton;
  OrderPlacedDialog({super.key, this.customButton});

  get ref => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              padding: const EdgeInsets.all(14),
              decoration: ShapeDecoration(
                color: const Color(0xFF1EDD31),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.done,
                  color: EcommerceAppColor.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              S.of(context).yourOrderHasBeenPlaced,
              textAlign: TextAlign.center,
              style: AppTextStyle(context).subTitle.copyWith(fontSize: 22.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              S.of(context).orderPlaceDes,
              textAlign: TextAlign.center,
              style: AppTextStyle(context).bodyText,
            ),
            SizedBox(height: 16.h),
            customButton ??
                CustomButton(
                  buttonText: S.of(context).continueShopping,
                  onPressed: () {
                    Hive.box<HiveCartModel>(AppConstants.cartModelBox).clear();
                    ref.refresh(selectedTabIndexProvider.notifier).state;
                    context.nav.pushNamedAndRemoveUntil(
                        Routes.getCoreRouteName(AppConstants.appServiceName),
                        (route) => false);
                  },
                )
          ],
        ),
      ),
    );
  }
}
