// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/app_logo.dart';
import 'package:ekray/components/ecommerce/confirmation_dialog.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_cart.dart';
import 'package:ekray/components/ecommerce/custom_transparent_button.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/controllers/eCommerce/cart/cart_controller.dart';
import 'package:ekray/controllers/eCommerce/product/product_controller.dart';
import 'package:ekray/controllers/eCommerce/shop/shop_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/cart/add_to_cart_model.dart';
import 'package:ekray/models/eCommerce/product/product_details.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/products/components/product_color_picker.dart';
import 'package:ekray/views/eCommerce/products/components/product_description.dart';
import 'package:ekray/views/eCommerce/products/components/product_details_and_review.dart';
import 'package:ekray/views/eCommerce/products/components/product_image_page_view.dart';
import 'package:ekray/views/eCommerce/products/components/product_size_picker.dart';
import 'package:ekray/views/eCommerce/products/components/shop_info.dart';
import 'package:ekray/views/eCommerce/products/components/similar_products_widget.dart';

class EcommerceProductDetailsLayout extends ConsumerStatefulWidget {
  final int productId;
  const EcommerceProductDetailsLayout({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<EcommerceProductDetailsLayout> createState() =>
      _EcommerceProductDetailsLayoutState();
}

class _EcommerceProductDetailsLayoutState
    extends ConsumerState<EcommerceProductDetailsLayout> {
  bool isTextExpanded = false;
  bool isFavorite = false;
  bool isLoading = false;
  // change the status bar color to transparent

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didpop, result) {
        ref.invalidate(selectedSizePriceProvider);
        ref.invalidate(selectedColorPriceProvider);
      },
      child: LoadingWrapperWidget(
        isLoading: ref.watch(cartController).isLoading,
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () {
                ref.read(shopControllerProvider.notifier).review.clear();
                context.nav.pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: colors(context).primaryColor,
              ),
            ),
            actions: [
              _buildAppBarRightRow(context: context),
            ],
          ),
          backgroundColor: colors(context).accentColor,
          bottomNavigationBar: ref
              .watch(productDetailsControllerProvider(widget.productId))
              .whenOrNull(
                data: (productDetails) => _buildBottomNavigationBar(
                    context: context, productDetails: productDetails),
              ),
          body: ref
              .watch(productDetailsControllerProvider(widget.productId))
              .when(
                data: (productDetails) => SingleChildScrollView(
                  child: AnimationLimiter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 500),
                        childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.h,
                            child: FadeInAnimation(
                              child: widget,
                            )),
                        children: [
                          Gap(2.h),
                          ProductImagePageView(productDetails: productDetails),
                          Gap(14.h),
                          ProductDescription(productDetails: productDetails),
                          Gap(14.h),
                          Visibility(
                            visible: productDetails.product.colors.isNotEmpty,
                            child: ProductColorPicker(
                                productDetails: productDetails),
                          ),
                          Gap(14.h),
                          Visibility(
                            visible: productDetails
                                .product.productSizeList.isNotEmpty,
                            child: ProductSizePicker(
                                productDetails: productDetails),
                          ),
                          Visibility(
                            visible: ref
                                .read(masterControllerProvider.notifier)
                                .materModel
                                .data
                                .isMultiVendor,
                            child: Gap(14.h),
                          ),
                          Visibility(
                              visible: ref
                                  .read(masterControllerProvider.notifier)
                                  .materModel
                                  .data
                                  .isMultiVendor,
                              child: ShopInformation(
                                  productDetails: productDetails)),
                          Gap(14.h),
                          ProductDetailsAndReview(
                            productDetails: productDetails,
                          ),
                          Gap(14.h),
                          SimilarProductsWidget(
                            productDetails: productDetails,
                          ),
                          Gap(14.h),
                        ],
                      ),
                    ),
                  ),
                ),
                error: ((error, stackTrace) => Center(
                      child: Text(
                        error.toString(),
                      ),
                    )),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        ),
      ),
    );
  }

  _buildAppBarRightRow({required BuildContext context}) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(right: 20.w, bottom: 6.h),
        child: Row(
          children: [
            CustomCartWidget(context: context),
            // Gap(10.w),
            // SvgPicture.asset(
            //   Assets.svg.share,
            //   width: 52.w,
            // )
          ],
        ),
      ),
    );
  }

  _buildBottomNavigationBar(
      {required BuildContext context, required ProductDetails productDetails}) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: 70.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: AbsorbPointer(
                absorbing: productDetails.product.quantity == 0,
                child: CustomTransparentButton(
                  buttonTextColor: productDetails.product.quantity == 0
                      ? ColorTween(
                          begin: colors(context).primaryColor,
                          end: colors(context).light,
                        ).lerp(0.5)
                      : colors(context).primaryColor,
                  borderColor: productDetails.product.quantity == 0
                      ? ColorTween(
                          begin: colors(context).primaryColor,
                          end: colors(context).light,
                        ).lerp(0.5)
                      : colors(context).primaryColor,
                  buttonText: S.of(context).addToCart,
                  onTap: () => _onTapCart(productDetails, false),
                ),
              ),
            ),
            Gap(10.w),
            Flexible(
              flex: 1,
              child: AbsorbPointer(
                absorbing: productDetails.product.quantity == 0,
                child: CustomButton(
                    buttonText: S.of(context).buyNow,
                    buttonColor: productDetails.product.quantity == 0
                        ? ColorTween(
                            begin: colors(context).primaryColor,
                            end: colors(context).light,
                          ).lerp(0.5)
                        : colors(context).primaryColor,
                    onPressed: () => _onTapCart(productDetails, true)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapCart(ProductDetails productDetails, bool isBuyNow) async {
    final AddToCartModel addToCartModel = AddToCartModel(
      productId: productDetails.product.id,
      quantity: 1,
      size: productDetails.product.productSizeList.isNotEmpty
          ? productDetails
              .product.productSizeList[ref.read(selectedProductSizeIndex)].id
          : null,
      color: productDetails.product.colors.isNotEmpty
          ? productDetails
              .product.colors[ref.read(selectedProductColorIndex)!].id
          : null,
    );
    if (!ref.read(hiveServiceProvider).userIsLoggedIn()) {
      _showTheWarningDialog();
    } else {
      await ref
          .read(cartController.notifier)
          .addToCart(addToCartModel: addToCartModel);

      if (isBuyNow) {
        context.nav.pushNamed(
            Routes.getMyCartViewRouteName(
              AppConstants.appServiceName,
            ),
            arguments: [false, isBuyNow]);
      }
    }
  }

  _showTheWarningDialog() {
    showDialog(
      barrierColor: colors(GlobalFunction.navigatorKey.currentContext!)
          .accentColor!
          .withOpacity(0.8),
      context: GlobalFunction.navigatorKey.currentContext!,
      builder: (_) => ConfirmationDialog(
        title: S.of(context).youAreNotLoggedIn,
        confirmButtonText:
            S.of(GlobalFunction.navigatorKey.currentContext!).login,
        onPressed: () {
          GlobalFunction.navigatorKey.currentContext!.nav
              .pushNamedAndRemoveUntil(Routes.login, (route) => false);
        },
      ),
    );
  }
}

class LoadingWrapperWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  const LoadingWrapperWidget({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Opacity(
            opacity: 0.3,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (isLoading)
          const Center(
            child: AppLogo(
              withAppName: false,
              isAnimation: true,
            ),
          ),
      ],
    );
  }
}
