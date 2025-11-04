import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/increment_decrement_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/cart/cart_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/models/eCommerce/cart/cart_product.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/my_cart/components/gift_bottom_sheet.dart';

class CartProductCard extends ConsumerWidget {
  final CartProduct product;
  final bool hasGift;
  final void Function()? increment;
  final void Function()? decrement;
  const CartProductCard({
    super.key,
    required this.product,
    required this.hasGift,
    this.increment,
    this.decrement,
  });

  void _handleGiftTap({
    required bool isGift,
    required WidgetRef ref,
    required int shopId,
  }) async {
    await ref.read(cartController.notifier).getAllGifts(shopId: shopId);
    showModalBottomSheet(
      context: GlobalFunction.navigatorKey.currentContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GiftBottomSheet(
        productId: product.id,
        gift: product.gift,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Material(
        color: GlobalFunction.getContainerColor(),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors(context).accentColor!,
                width: 2.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h).copyWith(right: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(
                    productImage: product.thumbnail,
                  ),
                  Gap(16.w),
                  _buildProductInfo(
                    context: context,
                    product: product,
                    ref: ref,
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
        width: 64.w,
        height: 64.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
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
    required CartProduct product,
    required WidgetRef ref,
  }) {
    return Flexible(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 12.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Gap(6.h),
          _buildProductBottomRow(
            context: context,
            product: product,
          ),
          Gap(8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IncrementDecrementButton(
                productQuantity: product.quantity,
                increment: increment,
                decrement: decrement,
              ),
              Visibility(
                visible: hasGift,
                child: _giftWidget(isGifted: product.gift != null, ref: ref),
              )
            ],
          ),
          Visibility(
              visible: product.gift != null,
              child: _senderReceiverInfoWidget()),
        ],
      ),
    );
  }

  Widget _buildProductBottomRow({
    required BuildContext context,
    required CartProduct product,
  }) {
    return Consumer(builder: (context, ref, _) {
      return Row(
        children: [
          Text(
            GlobalFunction.price(
              ref: ref,
              price: product.discountPrice > 0
                  ? product.discountPrice.toString()
                  : product.price.toString(),
            ),
            style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors(context).primaryColor,
                ),
          ),
          Visibility(
            visible: product.discountPrice > 0,
            child: Row(
              children: [
                Gap(2.w),
                Text(
                  GlobalFunction.price(
                    ref: ref,
                    price: product.price.toString(),
                  ),
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontSize: 12.sp,
                        color: EcommerceAppColor.lightGray,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: EcommerceAppColor.lightGray,
                      ),
                ),
              ],
            ),
          ),
          Gap(8.w),
          Visibility(
            visible: product.color != null,
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
                  product.color?.name ?? '',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(),
                ),
              ),
            ),
          ),
          Gap(8.w),
          Visibility(
            visible: product.size != null,
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
                  product.size?.name ?? '',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _giftWidget({required bool isGifted, required WidgetRef ref}) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.r),
      onTap: () => _handleGiftTap(isGift: isGifted, ref: ref, shopId: 1),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: isGifted
                ? EcommerceAppColor.green
                : colors(GlobalFunction.navigatorKey.currentContext)
                    .primaryColor!
                    .withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.svg.gift,
              colorFilter: ColorFilter.mode(
                isGifted
                    ? EcommerceAppColor.green
                    : colors(GlobalFunction.navigatorKey.currentContext)
                        .primaryColor!,
                BlendMode.srcIn,
              ),
            ),
            Gap(5.w),
            Text(
              isGifted ? 'Gifted' : 'Gift',
              style: AppTextStyle(GlobalFunction.navigatorKey.currentContext!)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _senderReceiverInfoWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _senderColumn('Sender', product.gift?.senderName ?? ''),
          SvgPicture.asset(
            Assets.svg.arrowRight,
            colorFilter: ColorFilter.mode(
                colors(GlobalFunction.navigatorKey.currentContext!)
                    .primaryColor!,
                BlendMode.srcIn),
          ),
          _senderColumn('Receiver', product.gift?.receiverName ?? '',
              isReceiver: true),
        ],
      ),
    );
  }

  Column _senderColumn(String senderName, String senderValue,
      {bool isReceiver = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gift $senderName',
          style: AppTextStyle(GlobalFunction.navigatorKey.currentContext!)
              .bodyTextSmall,
        ),
        Text(
          senderValue,
          style: AppTextStyle(GlobalFunction.navigatorKey.currentContext!)
              .bodyTextSmall
              .copyWith(
                  fontWeight: FontWeight.w700,
                  color: isReceiver
                      ? colors(GlobalFunction.navigatorKey.currentContext!)
                          .primaryColor
                      : colors(GlobalFunction.navigatorKey.currentContext!)
                          .bodyTextColor),
        ),
      ],
    );
  }
}
