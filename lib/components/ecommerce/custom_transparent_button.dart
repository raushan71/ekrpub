import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';

class CustomTransparentButton extends StatelessWidget {
  final String buttonText;
  final void Function() onTap;
  final Color? buttonTextColor;
  final Color? borderColor;
  final Color? buttonColor;
  const CustomTransparentButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.buttonTextColor,
    this.borderColor,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50.r),
      onTap: onTap,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.r),
          color: buttonColor,
          border: Border.all(
            color: borderColor ?? EcommerceAppColor.black,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: AppTextStyle(context).buttonText.copyWith(
                  color: buttonTextColor,
                ),
          ),
        ),
      ),
    );
  }
}
