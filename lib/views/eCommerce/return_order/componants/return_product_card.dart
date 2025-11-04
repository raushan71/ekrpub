import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_details_model/return_order_product.dart';
import 'package:ekray/utils/global_function.dart';

class ReturnOrderProductCard extends StatefulWidget {
  final ReturnOrderProduct product;

  final int orderId;
  final int index;
  final bool? isSelected;
  final bool? showCheckbox;
  final bool? addPadding;

  const ReturnOrderProductCard({
    super.key,
    required this.orderId,
    required this.product,
    required this.index,
    this.isSelected,
    this.showCheckbox = false,
    this.addPadding = true,
  });

  @override
  State<ReturnOrderProductCard> createState() => _ReturnOrderProductCardState();
}

class _ReturnOrderProductCardState extends State<ReturnOrderProductCard> {
  @override
  Widget build(BuildContext context) {
    debugPrint("isSelected: ${widget.isSelected}");
    return Padding(
      padding: widget.addPadding == false
          ? EdgeInsets.zero
          : EdgeInsets.only(top: 5.h, left: 20.w, right: 20.w),
      child: Material(
        color: GlobalFunction.getContainerColor(),
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
                    productImage: widget.product.thumbnail ?? "",
                  ),
                  Gap(16.w),
                  _buildProductInfo(
                    context: context,
                  ),
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
                  widget.product.productName ?? "",
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
            "${widget.product.quantity} x  ${GlobalFunction.price(
              ref: ref,
              price: widget.product.price.toString(),
            )} ",
            style: AppTextStyle(context).subTitle.copyWith(
                  color: colors(context).primaryColor,
                ),
          ),
          // Text(
          //   "${GlobalFunction.price(
          //     ref: ref,
          //     price: widget.product.productPrice.toString(),
          //   )} ",
          //   style: AppTextStyle(context).subTitle.copyWith(
          //       color: EcommerceAppColor.lightGray,
          //       decoration: TextDecoration.lineThrough,
          //       decorationColor: EcommerceAppColor.lightGray),
          // ),
        ],
      );
    });
  }

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
