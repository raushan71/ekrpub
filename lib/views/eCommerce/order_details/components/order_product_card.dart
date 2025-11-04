import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/order/order_details_model.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/order_details/components/product_review_dialog.dart';
import 'package:tuple/tuple.dart';

class OrderProductCard extends StatefulWidget {
  final Products product;
  final String orderStatus;
  final int orderId;
  final int index;
  final bool? isSelected;
  final bool? showCheckbox;
  final bool? addPadding;
  EdgeInsetsGeometry? padding;
  bool hideReviewButton;

  OrderProductCard({
    super.key,
    required this.orderId,
    required this.product,
    required this.index,
    required this.orderStatus,
    this.isSelected,
    this.showCheckbox = false,
    this.addPadding = true,
    this.padding,
    this.hideReviewButton = false,
  });

  @override
  State<OrderProductCard> createState() => _OrderProductCardState();
}

class _OrderProductCardState extends State<OrderProductCard> {
  @override
  Widget build(BuildContext context) {
    debugPrint("isSelected: ${widget.isSelected}");
    return Padding(
      padding: widget.addPadding == false
          ? widget.padding ?? EdgeInsets.zero
          : EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w, bottom: 10.h),
      child: Material(
        color: widget.showCheckbox == true
            ? Colors.transparent
            : GlobalFunction.getContainerColor(),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colors(context).accentColor!,
                width: 2.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h).copyWith(bottom: 0.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.showCheckbox == false
                      ? SizedBox.shrink()
                      : _buildSelectedIndicator(widget.isSelected ?? false),
                  _buildProductImage(
                    productImage: widget.product.thumbnail,
                  ),
                  Gap(16.w),
                  _buildProductInfo(
                    context: context,
                    hideReviewButton: widget.hideReviewButton,
                  ),
                  Gap(16.w),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage({required String productImage}) {
    return Flexible(
      flex: 1,
      child: Container(
        width: 70.w,
        height: 60.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              productImage,
              errorListener: (error) => debugPrint(error.toString()),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo({
    required BuildContext context,
    bool hideReviewButton = false,
  }) {
    return Flexible(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Gap(10.h),
          _buildProductBottomRow(
            context: context,
          ),
          Gap(10.h),
          _buildProductBottomRow1(hideReviewButton)
        ],
      ),
    );
  }

  Widget _buildProductBottomRow({
    required BuildContext context,
  }) {
    return Consumer(builder: (context, ref, _) {
      return Row(
        children: [
          Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            "${widget.product.orderQty} x  ${GlobalFunction.price(
              ref: ref,
              price: widget.product.discountPrice != 0
                  ? widget.product.discountPrice.toString()
                  : widget.product.price.toString(),
            )} ",
            style: AppTextStyle(context).subTitle.copyWith(
                color: colors(context).primaryColor,
                fontSize: widget.product.discountPrice != 0 &&
                        widget.orderStatus.toLowerCase() == 'delivered'
                    ? 14.sp
                    : 14.sp),
          ),
          if (widget.product.discountPrice != 0) ...[
            Gap(2.w),
            Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              GlobalFunction.price(
                  ref: ref, price: widget.product.price.toString()),
              style: AppTextStyle(context).bodyText.copyWith(
                    color: EcommerceAppColor.lightGray,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: EcommerceAppColor.lightGray,
                  ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildProductBottomRow1(bool hideReviewButton) {
    return Row(
      children: [
        Row(
          children: [
            Visibility(
              visible: widget.product.color != null,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: colors(context).accentColor,
                ),
                child: Center(
                  child: Text(
                      widget.product.color != null
                          ? capitalize(widget.product.color!)
                          : '',
                      style: AppTextStyle(context).bodyTextSmall),
                ),
              ),
            ),
            Visibility(
              visible:
                  widget.product.color != null && widget.product.size != null,
              child: Gap(8.w),
            ),
            Visibility(
              visible: widget.product.size != null,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: colors(context).accentColor,
                ),
                child: Center(
                  child: Text(
                      widget.product.size != null
                          ? capitalize(widget.product.size!)
                          : '',
                      style: AppTextStyle(context).bodyTextSmall),
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        if (widget.orderStatus.toLowerCase() == 'delivered') ...[
          if (widget.product.rating != null) ...[
            _buildRatingBar(),
          ] else ...[
            if (!hideReviewButton) _buildReviewButton(context: context),
          ]
        ]
      ],
    );
  }

  Widget _buildReviewButton({
    required BuildContext context,
  }) {
    return Material(
      color: EcommerceAppColor.carrotOrange,
      borderRadius: BorderRadius.circular(3.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(3.r),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ProductReviewDialog(
              arugument: Tuple2(widget.orderId, widget.product.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.r),
          ),
          child: Text(
            S.of(context).review,
            style: AppTextStyle(context)
                .bodyTextSmall
                .copyWith(color: EcommerceAppColor.white),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return RatingBar.builder(
      ignoreGestures: true,
      tapOnlyMode: false,
      itemSize: 18.sp,
      initialRating: widget.product.rating ?? 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      unratedColor: EcommerceAppColor.offWhite,
      itemBuilder: (context, _) => Icon(
        Icons.star_rounded,
        size: 16.sp,
        color: EcommerceAppColor.carrotOrange,
      ),
      onRatingUpdate: (rating) => debugPrint(rating.toString()),
    );
  }

  String capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  _buildSelectedIndicator(bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0.w),
      child: isSelected
          ? Image.asset("assets/png/return_selected.png",
              width: 24.w, height: 24.w)
          : Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
