import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/confirmation_dialog.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_transparent_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/controllers/eCommerce/cart/cart_controller.dart';
import 'package:ekray/controllers/eCommerce/product/product_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/cart/add_to_cart_model.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/products/layouts/product_details_layout.dart';

import '../../models/eCommerce/product/product.dart';

class AddToCartBottomSheet extends StatelessWidget {
  final Product product;
  const AddToCartBottomSheet({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 18.h,
        ).copyWith(right: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).select,
                  style:
                      AppTextStyle(context).subTitle.copyWith(fontSize: 20.sp),
                ),
                IconButton(
                  onPressed: () {
                    context.nav.pop();
                  },
                  icon: Icon(
                    Icons.close,
                    size: 24.sp,
                  ),
                )
              ],
            ),
            Gap(6.h),
            _buildProductCard(),
            Gap(3.h),
            Visibility(
              visible: product.colors.isNotEmpty ||
                  product.productSizeList.isNotEmpty,
              child: _buildAttributeWidget(),
            ),
            Gap(16.h),
            _buildBottomRow(),
          ],
        ),
      );
    });
  }

  Widget _buildProductCard() {
    return Consumer(builder: (context, ref, _) {
      return SizedBox(
        height: 126.h,
        width: double.infinity,
        child: Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: CachedNetworkImage(
                imageUrl: product.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Padding(
                padding: EdgeInsets.all(8.dm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${product.name}\n',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle(ContextLess.context)
                          .bodyText
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    Gap(8.h),
                    if (product.discountPrice > 0) ...[
                      Text(
                        ref
                                .read(masterControllerProvider.notifier)
                                .materModel
                                .data
                                .currency
                                .symbol +
                            (product.discountPrice +
                                    ref.watch(selectedColorPriceProvider) +
                                    ref.watch(selectedSizePriceProvider))
                                .toString(),
                        style: AppTextStyle(context)
                            .bodyText
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      Text(
                        ref
                                .read(masterControllerProvider.notifier)
                                .materModel
                                .data
                                .currency
                                .symbol +
                            (product.price +
                                    ref.watch(selectedColorPriceProvider) +
                                    ref.watch(selectedSizePriceProvider))
                                .toString(),
                        style: AppTextStyle(context)
                            .bodyText
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                    if (product.discountPrice > 0) ...[
                      Text(
                        ref
                                .read(masterControllerProvider.notifier)
                                .materModel
                                .data
                                .currency
                                .symbol +
                            product.price.toString(),
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: EcommerceAppColor.lightGray,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: EcommerceAppColor.lightGray,
                            ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAttributeWidget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: colors(ContextLess.context).accentColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Visibility(
            visible: product.colors.isNotEmpty,
            child: _buildColorPickerWidget(),
          ),
          Gap(4.h),
          Visibility(
            visible: product.productSizeList.isNotEmpty,
            child: _buildSizePicker(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerWidget() {
    return Consumer(builder: (context, ref, _) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.dm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: GlobalFunction.getContainerColor(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).color,
              style: AppTextStyle(context).bodyText.copyWith(fontSize: 16.sp),
            ),
            Gap(8.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  product.colors.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5.r),
                        onTap: () {
                          ref.read(selectedProductColorIndex.notifier).state =
                              index;
                          ref.read(selectedColorPriceProvider.notifier).state =
                              product.colors[index].price;
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.dm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(
                              color:
                                  ref.watch(selectedProductColorIndex) == index
                                      ? EcommerceAppColor.primary
                                      : colors(context).accentColor!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              product.colors[index].name[0].toUpperCase() +
                                  product.colors[index].name.substring(1),
                              style: AppTextStyle(context).bodyText.copyWith(
                                    color:
                                        ref.watch(selectedProductColorIndex) ==
                                                index
                                            ? EcommerceAppColor.primary
                                            : EcommerceAppColor.gray,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Widget _buildColorPickerWidget() {
  //   return Consumer(builder: (context, ref, _) {
  //     return Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.all(16.dm),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8.r),
  //         color: GlobalFunction.getContainerColor(),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             S.of(context).color,
  //             style: AppTextStyle(context).bodyText.copyWith(fontSize: 16.sp),
  //           ),
  //           Gap(8.h),
  //           Row(
  //             children: [
  //               Wrap(
  //                 alignment: WrapAlignment.start,
  //                 direction: Axis.horizontal,
  //                 children: List.generate(
  //                   product.colors.length,
  //                   (index) => Padding(
  //                     padding: EdgeInsets.only(right: 8.w),
  //                     child: Material(
  //                       color: Theme.of(context).scaffoldBackgroundColor,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(5.r),
  //                       ),
  //                       child: InkWell(
  //                         borderRadius: BorderRadius.circular(5.r),
  //                         onTap: () {
  //                           ref.read(selectedProductColorIndex.notifier).state =
  //                               index;
  //                           ref
  //                               .read(selectedColorPriceProvider.notifier)
  //                               .state = product.colors[index].price;
  //                         },
  //                         child: Container(
  //                           padding: EdgeInsets.all(8.dm),
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(5.r),
  //                             border: Border.all(
  //                               color: ref.watch(selectedProductColorIndex) ==
  //                                       index
  //                                   ? EcommerceAppColor.primary
  //                                   : colors(context).accentColor!,
  //                             ),
  //                           ),
  //                           child: Center(
  //                             child: Text(
  //                               product.colors[index].name[0].toUpperCase() +
  //                                   product.colors[index].name.substring(1),
  //                               style: AppTextStyle(context).bodyText.copyWith(
  //                                     color: ref.watch(
  //                                                 selectedProductColorIndex) ==
  //                                             index
  //                                         ? EcommerceAppColor.primary
  //                                         : EcommerceAppColor.gray,
  //                                   ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           )
  //         ],
  //       ),
  //     );
  //   });
  // }
  Widget _buildSizePicker() {
    return Consumer(builder: (context, ref, _) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.dm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: GlobalFunction.getContainerColor(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).size,
              style: AppTextStyle(context).bodyText.copyWith(
                    fontSize: 16.sp,
                  ),
            ),
            Gap(10.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  product.productSizeList.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5.r),
                        onTap: () {
                          ref.read(selectedProductSizeIndex.notifier).state =
                              index;
                          ref.read(selectedSizePriceProvider.notifier).state =
                              product.productSizeList[index].price;
                        },
                        child: IntrinsicWidth(
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(
                                color:
                                    ref.watch(selectedProductSizeIndex) == index
                                        ? EcommerceAppColor.primary
                                        : colors(context).accentColor!,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                product.productSizeList[index].name,
                                style: AppTextStyle(context).bodyText.copyWith(
                                      color:
                                          ref.watch(selectedProductSizeIndex) ==
                                                  index
                                              ? EcommerceAppColor.primary
                                              : EcommerceAppColor.gray,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Widget _buildSizePicker() {
  //   return Consumer(builder: (context, ref, _) {
  //     return Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.all(16.dm),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8.r),
  //         color: GlobalFunction.getContainerColor(),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             S.of(context).size,
  //             style: AppTextStyle(context).bodyText.copyWith(
  //                   fontSize: 16.sp,
  //                 ),
  //           ),
  //           Gap(10.h),
  //           Wrap(
  //             alignment: WrapAlignment.start,
  //             direction: Axis.horizontal,
  //             runSpacing: 8.w,
  //             children: List.generate(
  //               product.productSizeList.length,
  //               (index) => Padding(
  //                 padding: EdgeInsets.only(right: 8.w),
  //                 child: Material(
  //                   color: Theme.of(context).scaffoldBackgroundColor,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(5.r),
  //                   ),
  //                   child: InkWell(
  //                     borderRadius: BorderRadius.circular(5.r),
  //                     onTap: () {
  //                       ref.read(selectedProductSizeIndex.notifier).state =
  //                           index;
  //                       ref.read(selectedSizePriceProvider.notifier).state =
  //                           product.productSizeList[index].price;
  //                     },
  //                     child: IntrinsicWidth(
  //                       child: Container(
  //                         padding: EdgeInsets.all(8.r),
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(5.r),
  //                           border: Border.all(
  //                             color:
  //                                 ref.watch(selectedProductSizeIndex) == index
  //                                     ? EcommerceAppColor.primary
  //                                     : colors(context).accentColor!,
  //                           ),
  //                         ),
  //                         child: Center(
  //                           child: Text(
  //                             product.productSizeList[index].name,
  //                             style: AppTextStyle(context).bodyText.copyWith(
  //                                   color:
  //                                       ref.watch(selectedProductSizeIndex) ==
  //                                               index
  //                                           ? EcommerceAppColor.primary
  //                                           : EcommerceAppColor.gray,
  //                                 ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     );
  //   });
  // }

  Widget _buildBottomRow() {
    return Consumer(builder: (context, ref, _) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: AbsorbPointer(
                absorbing: product.quantity == 0,
                child: CustomTransparentButton(
                  borderColor: product.quantity == 0
                      ? ColorTween(
                          begin: colors(context).primaryColor,
                          end: colors(context).light,
                        ).lerp(0.5)
                      : colors(context).primaryColor,
                  buttonTextColor: product.quantity == 0
                      ? ColorTween(
                          begin: colors(context).primaryColor,
                          end: colors(context).light,
                        ).lerp(0.5)
                      : colors(context).primaryColor,
                  onTap: () {
                    if (!ref.read(hiveServiceProvider).userIsLoggedIn()) {
                      _showTheWarningDialog();
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => LoadingWrapperWidget(
                          isLoading: ref.watch(cartController).isLoading,
                          child: Container(),
                        ),
                      );
                      _onTapCart(product, false, ref, context).then((value) {
                        ref.read(hiveServiceProvider).getAuthToken().then(
                              (token) => [
                                if (token != null)
                                  if (context.mounted)
                                    {
                                      Navigator.of(context)
                                        ..pop()
                                        ..pop()
                                    }
                              ],
                            );
                      });
                    }
                  },
                  buttonText: S.of(ContextLess.context).addToCart,
                ),
              ),
            ),
            Gap(16.w),
            Flexible(
              flex: 1,
              child: AbsorbPointer(
                absorbing: product.quantity == 0,
                child: CustomButton(
                  buttonText: S.of(ContextLess.context).buyNow,
                  buttonColor: product.quantity == 0
                      ? ColorTween(
                          begin: colors(context).primaryColor,
                          end: colors(context).light,
                        ).lerp(0.5)
                      : colors(context).primaryColor,
                  onPressed: () {
                    _onTapCart(product, true, ref, context);
                  },
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  _showTheWarningDialog() {
    showDialog(
      barrierColor: colors(GlobalFunction.navigatorKey.currentContext!)
          .accentColor!
          .withOpacity(0.8),
      context: GlobalFunction.navigatorKey.currentContext!,
      builder: (_) => ConfirmationDialog(
        title: S.of(ContextLess.context).youAreNotLoggedIn,
        confirmButtonText:
            S.of(GlobalFunction.navigatorKey.currentContext!).login,
        onPressed: () {
          GlobalFunction.navigatorKey.currentContext!.nav
              .pushNamedAndRemoveUntil(Routes.login, (route) => false);
        },
      ),
    );
  }

  Future<void> _onTapCart(Product product, bool isBuyNow, WidgetRef ref,
      BuildContext context) async {
    final AddToCartModel addToCartModel = AddToCartModel(
      productId: product.id,
      quantity: 1,
      size: product.productSizeList.isNotEmpty
          ? product.productSizeList[ref.read(selectedProductSizeIndex)].id
          : null,
      color: product.colors.isNotEmpty
          ? product.colors[ref.read(selectedProductColorIndex)!].id
          : null,
    );

    if (!ref.read(hiveServiceProvider).userIsLoggedIn()) {
      _showTheWarningDialog();
    } else {
      await ref
          .read(cartController.notifier)
          .addToCart(addToCartModel: addToCartModel);
      if (isBuyNow) {
        context.nav.pop();
        context.nav.pushNamed(
            Routes.getMyCartViewRouteName(
              AppConstants.appServiceName,
            ),
            arguments: [false, isBuyNow]);
      }
    }
  }
}
