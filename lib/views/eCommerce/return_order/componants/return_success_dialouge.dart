import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/generated/l10n.dart';

Future<void> showReturnSuccessDialog({
  required BuildContext context,
  required String message,
  required String orderId,
  required String returnAddress,
  required VoidCallback onGoToOrders,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ✅ SVG Image
            SvgPicture.asset(
              "assets/svg/money-change.svg",
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 16),

            /// ✅ Title / Success Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle(context).title.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            /// ✅ Order ID
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${S.of(context).orderId}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 16),
                Expanded(child: Text(orderId, textAlign: TextAlign.end)),
              ],
            ),
            const SizedBox(height: 8),

            /// ✅ Return Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${S.of(context).returnAddress}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 16),
                Expanded(child: Text(returnAddress, textAlign: TextAlign.end)),
              ],
            ),

            const SizedBox(height: 20),

            /// ✅ Action Button
            CustomButton(
              buttonText: S.of(context).goToMyOrders,
              onPressed: () {
                Navigator.pop(context); // close dialog
                onGoToOrders(); // callback
              },
            ),
          ],
        ),
      );
    },
  );
}
