// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/decrement_button.dart';
import 'package:ekray/components/ecommerce/increment_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';

class IncrementDecrementButton extends StatelessWidget {
  final void Function()? increment;
  final void Function()? decrement;
  final int productQuantity;
  const IncrementDecrementButton({
    super.key,
    this.increment,
    this.decrement,
    required this.productQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: EcommerceAppColor.lightGray,
          onTap: decrement,
        ),
        Gap(10.w),
        Text(
          productQuantity.toString(),
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(10.w),
        IncrementButton(
          buttonColor: colors(context).accentColor,
          iconColor: EcommerceAppColor.lightGray,
          onTap: increment,
        ),
      ],
    );
  }
}
