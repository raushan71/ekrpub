import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/models/eCommerce/shop_message_model/product.dart';
import 'package:ekray/utils/global_function.dart';

class ProductMessageCard extends StatefulWidget {
  final ProductMessage product;

  const ProductMessageCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductMessageCard> createState() => _ProductMessageCardState();
}

class _ProductMessageCardState extends State<ProductMessageCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: GlobalFunction.getContainerColor(),
      child: Container(
        width: 260.w,
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: colors(context).accentColor!,
          ),
        ),
        padding: EdgeInsets.all(12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProductImage(
              productImage: widget.product.thumbnail ?? '',
            ),
            Gap(16.w),
            _buildProductInfo(
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage({required String productImage}) {
    return Flexible(
      flex: 1,
      child: Container(
        width: 80.w,
        height: 60.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              productImage,
              errorListener: (error) => debugPrint(error.toString()),
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo({
    required BuildContext context,
  }) {
    return Flexible(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.product.name ?? '',
                  maxLines: 2,
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Gap(10.h),
          Row(
            children: [
              Text(
                "${widget.product.price ?? ''}",
                style: AppTextStyle(context).title.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
              ),
              Spacer(),
              Icon(
                Icons.star,
                color: colors(context).primaryColor,
                size: 15.sp,
              ),
              Gap(5.w),
              Text(
                "${widget.product.rating ?? ''}",
                style: AppTextStyle(context).bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Gap(5.w),
              Text(
                "(${widget.product.totalReviews ?? ''})",
                style: AppTextStyle(context).bodyText.copyWith(
                      color: colors(context).bodyTextSmallColor,
                    ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
