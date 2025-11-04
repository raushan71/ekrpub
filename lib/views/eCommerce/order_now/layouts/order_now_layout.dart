// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/controllers/eCommerce/cart/cart_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/cart/hive_cart_model.dart';
import 'package:ekray/models/eCommerce/order/order_now_cart_model.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/checkout/layouts/checkout_layout.dart';
import 'package:ekray/views/eCommerce/my_cart/components/voucher_bottom_sheet.dart';
import 'package:ekray/views/eCommerce/order_now/components/cart_product_card.dart';
import 'package:ekray/views/eCommerce/products/layouts/product_details_layout.dart';

class EcommerceOrderNowLayout extends ConsumerStatefulWidget {
  final OrderNowCartModel orderNowCartModel;
  const EcommerceOrderNowLayout({
    super.key,
    required this.orderNowCartModel,
  });

  @override
  ConsumerState<EcommerceOrderNowLayout> createState() =>
      _EcommerceOrderNowLayoutState();
}

class _EcommerceOrderNowLayoutState
    extends ConsumerState<EcommerceOrderNowLayout> {
  final TextEditingController promoCodeController = TextEditingController();

  bool isCouponApply = false;
  int productQuantity = 1;
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  init() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(cartSummeryController.notifier).calculateCartSummery(
            couponCode: promoCodeController.text,
            shopIds: [widget.orderNowCartModel.shopId],
            isBuyNow: 1,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapperWidget(
      isLoading: ref.watch(cartController).isLoading,
      child: Scaffold(
        appBar: productQuantity < 1
            ? null
            : _buildAppBar(context: context, cartItems: [], isRoot: true),
        backgroundColor: colors(context).accentColor,
        body: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 16.h),
                child: AnimationLimiter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.h,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        Gap(12.h),
                        _buildCartProduct(),
                        _buildPromoCodeApplyWidget(context: context),
                        Gap(12.h),
                        _buildSummaryWidget(context: context),
                        Gap(MediaQuery.of(context).size.height / 6.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4.h,
              left: 0,
              right: 0,
              child: _buildBottomNavigationBar(context: context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCartProduct() {
    return Container(
      color: GlobalFunction.getContainerColor(),
      padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: checkMultivendor(),
            child: Row(
              children: [
                Checkbox(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: colors(context).primaryColor,
                  value: true,
                  onChanged: (v) {
                    // ref
                    //     .read(shopIdsProvider.notifier)
                    //     .toggleShopId(cartItem.shopId);
                    // ref.read(cartSummeryController.notifier).calculateCartSummery(
                    //       couponCode: promoCodeController.text,
                    //       shopIds: ref.read(shopIdsProvider).toList(),
                    //     );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.orderNowCartModel.shopName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle(context)
                        .bodyText
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: checkMultivendor(),
            child: Gap(8.h),
          ),
          Visibility(
            visible: checkMultivendor(),
            child: Divider(
              height: 5.h,
              thickness: 2,
              color: colors(context).accentColor,
            ),
          ),
          OrderNowCartProduct(
              product: widget.orderNowCartModel,
              productQuantity: productQuantity,
              increment: () {
                setState(() {
                  productQuantity++;
                });
                ref
                    .read(cartController.notifier)
                    .increment(productId: widget.orderNowCartModel.productId);
              },
              decrement: () {
                setState(() {
                  productQuantity--;
                });
                if (productQuantity < 1) context.nav.pop();
                ref
                    .read(cartController.notifier)
                    .decrement(productId: widget.orderNowCartModel.productId);
              }),
          Visibility(visible: checkMultivendor(), child: Gap(8.h)),
          Visibility(
            visible: checkMultivendor(),
            child: _buildVoucherWidget(
              context: context,
              shopId: widget.orderNowCartModel.shopId,
              shopName: widget.orderNowCartModel.shopName,
            ),
          ),
          Visibility(
            visible: checkMultivendor(),
            child: Gap(8.h),
          ),
          Visibility(
            visible: checkMultivendor(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                40,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  width: 3.w,
                  height: 2.h,
                  color: EcommerceAppColor.lightGray,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVoucherWidget({
    required BuildContext context,
    required int shopId,
    required String shopName,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: false,
          backgroundColor: EcommerceAppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          context: context,
          builder: (context) {
            return VoucherBottomSheet(
              shopId: shopId,
              shopName: shopName,
            );
          },
        );
      },
      child: Row(
        children: [
          SvgPicture.asset(
            Assets.svg.ticket,
            height: 30.h,
            width: 30.w,
          ),
          Gap(10.w),
          Text(
            S.of(context).storeVoucher,
            style: AppTextStyle(context).bodyTextSmall,
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 18.sp,
            color: colors(context).bodyTextSmallColor,
          )
        ],
      ),
    );
  }

  AppBar _buildAppBar(
      {required BuildContext context,
      required List<HiveCartModel> cartItems,
      required bool isRoot}) {
    return AppBar(
      backgroundColor: GlobalFunction.getContainerColor(),
      surfaceTintColor: colors(context).light,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      // TODO need to work on this page

      title: Text(
        S.of(context).orderNow,
        style: AppTextStyle(context).appBarText,
      ),
    );
  }

  Widget _buildPromoCodeApplyWidget({required BuildContext context}) {
    return Container(
      color: GlobalFunction.getContainerColor(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: _buildPromoTextField(context: context),
          ),
          Gap(10.w),
          AbsorbPointer(
            absorbing: promoCodeController.text.isEmpty,
            child: Material(
              color: colors(context).primaryColor!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () {
                  ref
                      .read(buyNowSummeryController.notifier)
                      .calculateCartSummery(
                        couponCode: promoCodeController.text.trim(),
                        productId: widget.orderNowCartModel.productId,
                        quantity: productQuantity,
                        showSnackbar: true,
                      );
                },
                child: Container(
                  height: 58.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        // S.of(context).apply,
                        ref.watch(buyNowSummeryController)['applyCoupon']
                            ? S.of(context).applied
                            : S.of(context).apply,
                        style: AppTextStyle(context)
                            .subTitle
                            .copyWith(color: colors(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoTextField({required BuildContext context}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: EcommerceAppColor.primary, // Color of the solid border
          width: 1.5,
        ),
        color: colors(context).accentColor, // Fill color
      ),
      child: FormBuilderTextField(
        readOnly: ref.watch(buyNowSummeryController)['applyCoupon'],
        textAlign: TextAlign.start,
        name: 'promoCode',
        controller: promoCodeController,
        style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.w600,
            ),
        cursorColor: colors(context).primaryColor,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16),
          alignLabelWithHint: true,
          hintText: S.of(context).promoCode,
          hintStyle: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w700,
                color: colors(context).hintTextColor,
              ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(8.sp),
            child: SvgPicture.asset(
              Assets.svg.cuppon,
            ),
          ),
          floatingLabelStyle: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w400,
                color: colors(context).primaryColor,
              ),
          filled: true,
          fillColor: colors(context).accentColor,
          errorStyle: AppTextStyle(context).bodyTextSmall.copyWith(
                fontWeight: FontWeight.w400,
                color: colors(context).errorColor,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildSummaryWidget({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: ShapeDecoration(
        color: GlobalFunction.getContainerColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).orderSummary,
            style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Gap(8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: ShapeDecoration(
              color: colors(context).accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  context: context,
                  title: S.of(context).subTotal,
                  value: ref.watch(cartSummeryController)['totalAmount'],
                ),
                Gap(10.h),
                _buildSummaryRow(
                  context: context,
                  title: S.of(context).discount,
                  value:
                      ref.watch(cartSummeryController)['discount'].toDouble(),
                  isDiscount: true,
                ),
                Gap(10.h),
                _buildSummaryRow(
                  context: context,
                  title: S.of(context).deliveryCharge,
                  value: ref.watch(cartSummeryController)['deliveryCharge'],
                ),
                Gap(10.h),
                const Divider(
                  thickness: 1,
                ),
                Gap(5.h),
                _buildSummaryRow(
                  context: context,
                  title: S.of(context).payableAmount,
                  value: ref.watch(cartSummeryController)['payableAmount'],
                  isPayable: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required double value,
    required BuildContext context,
    bool isDiscount = false,
    bool isPayable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: isPayable ? FontWeight.bold : FontWeight.w500),
        ),
        Text(
          "${isDiscount ? '-' : ''}${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}$value",
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: isPayable ? FontWeight.bold : FontWeight.w500,
                color: isDiscount ? EcommerceAppColor.primary : null,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar({required BuildContext context}) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
        builder: (context, box, _) {
          final appLocal = box.get(AppConstants.appLocal) ?? 'en';

          return Container(
              height: 90.h,
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(
                  bottom: 14.h,
                  top: 16.h,
                  right: appLocal == 'ar' ? 20.w : null,
                  left: appLocal == 'ar' ? null : 20.w),
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          S.of(context).totalAmount,
                          style: AppTextStyle(context).bodyText,
                        ),
                        Gap(4.h),
                        Text(
                          "${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol} ${ref.watch(cartSummeryController)['payableAmount']}",
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    flex: 3,
                    child: CustomButton(
                        buttonText: S.of(context).checkout,
                        onPressed: () {
                          final OrderNowArguments orderNowArguments =
                              OrderNowArguments(
                            productId: widget.orderNowCartModel.productId,
                            quantity: productQuantity,
                            color: widget.orderNowCartModel.color,
                            size: widget.orderNowCartModel.size,
                          );
                          context.nav.pushNamed(
                            Routes.getCheckoutViewRouteName(
                              AppConstants.appServiceName,
                            ),
                            arguments: [
                              double.parse(
                                _getPayableAmount(),
                              ),
                              ref.read(subTotalProvider)['isCouponApply'] &&
                                      promoCodeController.text.isNotEmpty
                                  ? promoCodeController.text.trim()
                                  : null,
                              orderNowArguments,
                            ],
                          );
                        },
                        buttonColor: colors(context).primaryColor),
                  ),
                ],
              ));
        });
  }

  Widget radioWidget({required bool isActive, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 18.h,
        width: 18.w,
        padding: EdgeInsets.all(2.sp),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: EcommerceAppColor.primary,
            width: 2.2,
          ),
        ),
        child: isActive
            ? Container(
                height: 8.h,
                width: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EcommerceAppColor.primary,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildDottedDivider() {
    return DottedBorder(
      borderType: BorderType.Oval,
      strokeCap: StrokeCap.butt,
      color: Colors.grey,
      strokeWidth: 1,
      dashPattern: const [5, 5],
      child: const SizedBox(
        width: double.infinity,
        height: 0,
      ),
    );
  }

  Widget get fullWidthPath {
    return DottedBorder(
      customPath: (size) {
        return Path()
          ..moveTo(0, 20)
          ..lineTo(size.width, 20);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(),
      ),
    );
  }

  String _getPayableAmount() {
    double payableAmount = 0.0;
    payableAmount = ref.watch(subTotalProvider.notifier).getSubTotal() != 0.0
        ? ref.watch(subTotalProvider.notifier).getSubTotal()! +
            ref.watch(subTotalProvider.notifier).getDeliveryCharge()!
        : 0.0;
    return payableAmount.toStringAsFixed(2);
  }

  bool checkMultivendor() {
    return ref
        .read(masterControllerProvider.notifier)
        .materModel
        .data
        .isMultiVendor;
  }
}
