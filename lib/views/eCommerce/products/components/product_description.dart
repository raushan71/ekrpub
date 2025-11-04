import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/components/ecommerce/confirmation_dialog.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/product/product_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/cart/hive_cart_model.dart';
import 'package:ekray/models/eCommerce/product/product_details.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/home/layouts/home_view_layout.dart';
import 'package:share_plus/share_plus.dart';

class ProductDescription extends ConsumerStatefulWidget {
  final ProductDetails productDetails;
  const ProductDescription({
    super.key,
    required this.productDetails,
  });

  @override
  ConsumerState<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends ConsumerState<ProductDescription> {
  bool isTextExpanded = false;
  bool isFavorite = true;
  @override
  void initState() {
    isFavorite = widget.productDetails.product.isFavorite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      width: double.infinity,
      color: GlobalFunction.getContainerColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.productDetails.product.brand ?? '',
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: colors(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              InkWell(
                onTap: () {
                  final websiteUrl =
                      AppConstants.baseUrl.replaceAll("api", "products");
                  Share.share(
                      "check out my website $websiteUrl/${widget.productDetails.product.id}/details");
                },
                child: Card(
                    child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(Icons.share, color: colors(context).primaryColor),
                )),
              ),
            ],
          ),
          Gap(10.h),
          Text(
            widget.productDetails.product.name,
            style: AppTextStyle(context)
                .bodyText
                .copyWith(fontWeight: FontWeight.w700),
          ),
          Gap(10.h),
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: isTextExpanded
                ? Text(
                    widget.productDetails.product.shortDescription,
                    style: AppTextStyle(context)
                        .bodyTextSmall
                        .copyWith(fontSize: 12.sp),
                  )
                : Text(
                    widget.productDetails.product.shortDescription,
                    style: AppTextStyle(context)
                        .bodyTextSmall
                        .copyWith(fontSize: 13.sp),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          Gap(10.h),
          GestureDetector(
            onTap: () {
              setState(() {
                isTextExpanded = !isTextExpanded;
              });
            },
            child: Text(
              isTextExpanded ? S.of(context).readLess : S.of(context).readMore,
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: colors(context).primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: colors(context).primaryColor,
                  ),
            ),
          ),
          Gap(5.h),
          _buildReviewAndSoldCount(context: context),
          Gap(5.h),
          _buildPriceAndAddToCart(context: context),
          Gap(10.h),
          widget.productDetails.product.runningFlashSale != null
              ? DealOfTheDayWidget(
                  showViewMore: false,
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildReviewAndSoldCount({required BuildContext context}) {
    return Row(
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
              widget.productDetails.product.rating.toString(),
              style: AppTextStyle(context).bodyText.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Gap(5.w),
            Text(
              '(${widget.productDetails.product.totalReviews})',
              style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors(context).bodyTextSmallColor),
            ),
            Gap(14.w),
            CircleAvatar(
                radius: 3.r,
                backgroundColor: EcommerceAppColor.lightGray.withOpacity(0.5)),
            Gap(14.w),
            Text(
              '${widget.productDetails.product.totalSold} Sold',
              style: AppTextStyle(context).bodyText.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors(context).bodyTextSmallColor,
                  ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              if (ref.read(hiveServiceProvider).userIsLoggedIn()) {
                setState(() {
                  isFavorite = !isFavorite;
                });
                ref
                    .read(productControllerProvider.notifier)
                    .favoriteProductAddRemove(
                      productId: widget.productDetails.product.id,
                    );
              } else {
                showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                          title:
                              'You are unable to favorite products without login!',
                          confirmButtonText: 'Login',
                          onPressed: () {
                            context.nav.pushNamedAndRemoveUntil(
                                Routes.login, (route) => false);
                          },
                        ));
              }
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline_rounded,
              size: isFavorite ? 31.sp : 30.sp,
              color: isFavorite
                  ? colors(context).errorColor
                  : colors(context).bodyTextSmallColor,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPriceAndAddToCart({required BuildContext context}) {
    return ValueListenableBuilder<Box<HiveCartModel>>(
        valueListenable:
            Hive.box<HiveCartModel>(AppConstants.cartModelBox).listenable(),
        builder: (context, cartBox, _) {
          // bool inCart = false;
          // late int productQuantity;
          // int cartIndex = -1;
          final cartItems = cartBox.values.toList();
          for (int i = 0; i < cartItems.length; i++) {
            final cartProduct = cartItems[i];
            if (cartProduct.productId == widget.productDetails.product.id) {
              // inCart = true;
              // productQuantity = cartProduct.productsQTY;
              // cartIndex = i;
              break;
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.productDetails.product.discountPrice > 0) ...[
                    Text(
                      GlobalFunction.price(
                        ref: ref,
                        price: (widget.productDetails.product.discountPrice +
                                ref.watch(selectedColorPriceProvider) +
                                ref.watch(selectedSizePriceProvider))
                            .toString(),
                      ),
                      style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 22.sp),
                    ),
                  ] else ...[
                    Text(
                      GlobalFunction.price(
                        ref: ref,
                        price: (widget.productDetails.product.price +
                                ref.watch(selectedColorPriceProvider) +
                                ref.watch(selectedSizePriceProvider))
                            .toString(),
                      ),
                      style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 22.sp),
                    ),
                  ],
                  Gap(5.w),
                  Visibility(
                    visible: widget.productDetails.product.discountPrice > 0,
                    child: Text(
                      GlobalFunction.price(
                        ref: ref,
                        price: widget.productDetails.product.price.toString(),
                      ),
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontSize: 18.sp,
                            color: EcommerceAppColor.lightGray,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: EcommerceAppColor.lightGray,
                          ),
                    ),
                  ),
                  Gap(10.w),
                  Visibility(
                    visible: widget.productDetails.product.discountPrice > 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        color: colors(context).errorColor,
                      ),
                      child: Center(
                        child: Text(
                          '-${widget.productDetails.product.discountPercentage} %',
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: colors(context).light,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  )
                ],
              ),

              // if (inCart) ...[
              //   IncrementDecrementButton(
              //     productQuantity: productQuantity,
              //     increment: () {
              //       ref.read(cartController.notifier).incrementProductQuantity(
              //             productId: widget.productDetails.product.id,
              //             cartBox: cartBox,
              //             index: cartIndex,
              //           );
              //     },
              //     decrement: () {
              //       ref.read(cartController.notifier).decrementProductQuantity(
              //             productId: widget.productDetails.product.id,
              //             cartBox: cartBox,
              //             index: cartIndex,
              //           );
              //     },
              //   )
              // ] else ...{
              //   IncrementButton(
              //     onTap: () async {
              //       HiveCartModel cartItem = HiveCartModel(
              //         shopId: widget.productDetails.product.shop.id,
              //         shopLogo: widget.productDetails.product.shop.logo,
              //         deliveryCharge:
              //             widget.productDetails.product.shop.deliveryCharge,
              //         shopName: widget.productDetails.product.shop.name,
              //         review: 4.7,
              //         productId: widget.productDetails.product.id,
              //         productLogo: widget
              //             .productDetails.product.thumbnails.first.thumbnail,
              //         title: widget.productDetails.product.name,
              //         price: GlobalFunction.getPrice(
              //           currentPrice: widget.productDetails.product.price,
              //           discountPrice:
              //               widget.productDetails.product.discountPrice,
              //         ),
              //         currentPrice: widget.productDetails.product.price,
              //         discountPrice:
              //             widget.productDetails.product.discountPrice,
              //         color: widget.productDetails.product.colors.isNotEmpty &&
              //                 ref.read(selectedProductColorIndex) != null
              //             ? widget.productDetails.product
              //                 .colors[ref.read(selectedProductColorIndex)!].name
              //                 .toLowerCase()
              //             : '',
              //         productsQTY: 1,
              //         size: '',
              //         unit: '',
              //       );
              //       await cartBox.add(cartItem);
              //     },
              //   )
              // },
            ],
          );
        });
  }
}
