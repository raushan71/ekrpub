// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/models/common/master_model.dart';

class PaymentCard extends StatelessWidget {
  final PaymentGateways paymentGateways;
  final bool isActive;
  final void Function()? onTap;
  const PaymentCard({
    super.key,
    required this.paymentGateways,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            border: Border.all(
                color: isActive
                    ? EcommerceAppColor.primary
                    : colors(context).accentColor!),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.svg.radio,
                      width: 22.sp,
                      colorFilter: ColorFilter.mode(
                        isActive
                            ? colors(context).primaryColor!
                            : colors(context).accentColor!,
                        BlendMode.srcIn,
                      ),
                    ),
                    Gap(14.w),
                    Text(
                      paymentGateways.name.isNotEmpty
                          ? '${paymentGateways.name[0].toUpperCase()}${paymentGateways.name.substring(1)}'
                          : '',
                      style: AppTextStyle(context).bodyText,
                    )
                  ],
                ),
              ),
              CachedNetworkImage(
                imageUrl: paymentGateways.logo,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 80.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
