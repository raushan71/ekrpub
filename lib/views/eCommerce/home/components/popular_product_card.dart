import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/add_to_cart_bottom_sheet.dart';
import 'package:ekray/components/ecommerce/increment_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/models/eCommerce/product/product.dart';
import 'package:ekray/utils/global_function.dart';

class PopularProductCard extends ConsumerWidget {
  final Product product;
  final void Function()? onTap;
  const PopularProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: Material(
        borderRadius: BorderRadius.circular(8.0.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0.r),
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
            ).copyWith(top: 12.h),
            width: 220.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 6,
                  fit: FlexFit.tight,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.r),
                          child: CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (product.discountPercentage != 0)
                        Positioned(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              color: EcommerceAppColor.red,
                            ),
                            child: Text(
                              '-${product.discountPercentage}%',
                              style:
                                  AppTextStyle(context).bodyTextSmall.copyWith(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: colors(context).light,
                                      ),
                            ),
                          ),
                        ),
                      if (product.quantity == 0) ...[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: Center(
                              child: Text(
                                'Out of Stock',
                                style: AppTextStyle(context).subTitle.copyWith(
                                      color: colors(context).light,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Gap(5.h),
                      Text(
                        "${product.name}\n",
                        style: AppTextStyle(context)
                            .bodyText
                            .copyWith(fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16.sp,
                                color: EcommerceAppColor.carrotOrange,
                              ),
                              Text(
                                product.rating.toString(),
                                style: AppTextStyle(context)
                                    .bodyTextSmall
                                    .copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.sp),
                              ),
                              Gap(5.w),
                              Text(
                                '(${product.totalReviews})',
                                style: AppTextStyle(context)
                                    .bodyTextSmall
                                    .copyWith(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          CircleAvatar(
                            radius: 2.5,
                            backgroundColor:
                                EcommerceAppColor.lightGray.withOpacity(0.3),
                          ),
                          Text(
                            '${product.totalSold} Sold',
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 12.sp),
                          )
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (product.discountPrice > 0) ...[
                                Text(
                                  GlobalFunction.price(
                                    ref: ref,
                                    price: product.discountPrice.toString(),
                                  ),
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                              ] else ...[
                                Text(
                                  GlobalFunction.price(
                                    ref: ref,
                                    price: product.price.toString(),
                                  ),
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                              ],
                              Visibility(
                                visible: product.discountPrice > 0,
                                child: Text(
                                  GlobalFunction.price(
                                    ref: ref,
                                    price: product.price.toString(),
                                  ),
                                  style: AppTextStyle(context)
                                      .bodyText
                                      .copyWith(
                                        color: EcommerceAppColor.lightGray,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor:
                                            EcommerceAppColor.lightGray,
                                        fontSize: 12.sp,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          IncrementButton(
                            onTap: () {
                              ref
                                  .refresh(selectedProductColorIndex.notifier)
                                  .state;
                              ref
                                  .refresh(selectedProductSizeIndex.notifier)
                                  .state;
                              showModalBottomSheet(
                                isScrollControlled: true,
                                isDismissible: false,
                                barrierColor: colors(context)
                                    .accentColor!
                                    .withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                context: context,
                                builder: (_) => AddToCartBottomSheet(
                                  product: product,
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      Gap(product.discountPrice > 0 ? 10.h : 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
