import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:ekray/controllers/eCommerce/message/message_controller.dart';
import 'package:ekray/controllers/eCommerce/order/order_controller.dart';
import 'package:ekray/controllers/eCommerce/payment/payment_controller.dart';
import 'package:ekray/controllers/eCommerce/return_policy/return_policy_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/order/order_details_model.dart';
import 'package:ekray/models/eCommerce/shop_message_model/shop.dart' as shop;
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/checkout/components/address_card.dart';
import 'package:ekray/views/eCommerce/checkout/components/build_payment_card.dart';
import 'package:ekray/views/eCommerce/checkout/components/order_placed_dialog.dart';
import 'package:ekray/views/eCommerce/checkout/components/pay_card.dart';
import 'package:ekray/views/eCommerce/checkout/layouts/checkout_layout.dart';
import 'package:ekray/views/eCommerce/checkout/layouts/web_payment_page.dart';
import 'package:ekray/views/eCommerce/order_details/components/order_details_card.dart';
import 'package:ekray/views/eCommerce/order_details/components/order_product_card.dart';
import 'package:ekray/views/eCommerce/products/layouts/product_details_layout.dart';

class OrderDetailsLayout extends ConsumerStatefulWidget {
  final int orderId;
  const OrderDetailsLayout({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsLayout> createState() => _OrderDetailsLayoutState();
}

class _OrderDetailsLayoutState extends ConsumerState<OrderDetailsLayout> {
  bool isConfirmLoading = false;
  PaymentType selectedPaymentType = PaymentType.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(orderDetailsControllerProvider(widget.orderId));
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final asyncValue =
        ref.watch(orderDetailsControllerProvider(widget.orderId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colors(context).accentColor,
      appBar: AppBar(
        title: Text(S.of(context).orderDetails),
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          asyncValue.maybeWhen(
            data: (orderDetails) {
              final isReturnable = orderDetails.data.order.isReturnable;
              debugPrint("isReturnable: $isReturnable");
              return isReturnable == true
                  ? GestureDetector(
                      onTap: () {
                        showDialog(
                            barrierColor:
                                isDark ? Color(0x99000000) : Color(0x80000000),
                            context: context,
                            builder: (context) {
                              final asyncValue = ref.watch(
                                  orderDetailsControllerProvider(
                                      widget.orderId));

                              return asyncValue.maybeWhen(
                                data: (orderDetails) => Dialog(
                                  clipBehavior: Clip.hardEdge,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      return SingleChildScrollView(
                                        child: _buildServiceItemsWidget(
                                            context,
                                            orderDetails.data.order.products,
                                            orderDetails.data.order.orderStatus,
                                            true, (index) {
                                          ref
                                              .read(
                                                  selectedReturnProductProvider
                                                      .notifier)
                                              .toggleProductSelection(
                                                  orderDetails.data.order
                                                      .products[index]);
                                        }, true, widget.orderId, isDark, true),
                                      );
                                    },
                                  ),
                                ),
                                orElse: () => const SizedBox(),
                              );
                            });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: colors(context).primaryColor!,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          "Return",
                          style: AppTextStyle(context)
                              .bodyText
                              .copyWith(color: colors(context).primaryColor),
                        ),
                      ),
                    )
                  : SizedBox();
            },
            orElse: () => const SizedBox(),
          )
        ],
      ),
      bottomNavigationBar:
          ref.watch(orderDetailsControllerProvider(widget.orderId)).when(
                data: (orderDetails) =>
                    orderDetails.data.order.orderStatus.toLowerCase() !=
                                'cancelled' &&
                            orderDetails.data.order.orderStatus.toLowerCase() !=
                                'confirm' &&
                            orderDetails.data.order.orderStatus.toLowerCase() !=
                                'processing' &&
                            orderDetails.data.order.orderStatus.toLowerCase() !=
                                'on the way'
                        ? _buildBottomNavigationWidget(
                            context: context,
                            orderId: orderDetails.data.order.id,
                            orderStatus: orderDetails.data.order.orderStatus,
                          )
                        : null,
                error: (error, s) => null,
                loading: () => const SizedBox(),
              ),
      body: Consumer(
        builder: (context, ref, _) {
          final asyncValue =
              ref.watch(orderDetailsControllerProvider(widget.orderId));
          return asyncValue.when(
            data: (orderDetails) => SingleChildScrollView(
              child: Column(
                children: [
                  Gap(8.h),
                  _buildServiceItemsWidget(
                      context,
                      orderDetails.data.order.products,
                      orderDetails.data.order.orderStatus,
                      false,
                      null,
                      false,
                      widget.orderId,
                      isDark,
                      false),
                  Gap(8.h),
                  _buildShopCardWidget(
                    context: context,
                    orderDetails: orderDetails,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: AddressCard(
                      address: orderDetails.data.order.address,
                      cardColor: GlobalFunction.getContainerColor(),
                    ),
                  ),
                  OrderDetailsCard(
                    orderDetails: orderDetails,
                  ),
                  Gap(8.h),
                  Visibility(
                    visible:
                        orderDetails.data.order.paymentStatus == 'Pending' &&
                            orderDetails.data.order.paymentMethod ==
                                'Online Payment',
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: CustomTransparentButton(
                            buttonTextColor: colors(context).primaryColor,
                            borderColor: colors(context).primaryColor,
                            buttonText: 'Pay Now',
                            onTap: () {
                              showModalBottomSheet(
                                showDragHandle: true,
                                isScrollControlled: true,
                                backgroundColor: EcommerceAppColor.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.r),
                                    topRight: Radius.circular(12.r),
                                  ),
                                ),
                                barrierColor: colors(context)
                                    .accentColor!
                                    .withOpacity(0.8),
                                context: context,
                                builder: (context) {
                                  return _buildPaymentBottomSheet();
                                },
                              );
                            },
                          ),
                        ),
                        Gap(8.h),
                      ],
                    ),
                  )
                ],
              ),
            ),
            error: ((error, stackTrace) => Center(
                  child: Text(error.toString()),
                )),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceItemsWidget(
      BuildContext context,
      List<Products> products,
      String orderStatus,
      bool? showCheckbox,
      Function(int)? onTap,
      bool? showButton,
      int? orderId,
      bool isDark,
      bool hideReviewButton) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedProducts = ref.watch(selectedReturnProductProvider);
        final isEnableNextButton =
            products.any((product) => product.isReturnable == true);
        debugPrint("isEnableNextButton: $isEnableNextButton");
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 14.h,
          ),
          color: showCheckbox == true && isDark
              ? Colors.grey.withValues(alpha: 0.3)
              : GlobalFunction.getContainerColor(),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              showCheckbox == true
                  ? Center(
                      child: Text(
                        'Select Return Items',
                        style: AppTextStyle(context)
                            .subTitle
                            .copyWith(fontSize: 16.sp),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        '${S.of(context).serviceItem} (${products.length})',
                        style: AppTextStyle(context)
                            .subTitle
                            .copyWith(fontSize: 16.sp),
                      ),
                    ),
              Gap(14.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final isProductReturnable = products[index].isReturnable;

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: onTap == null
                            ? null
                            : () {
                                debugPrint("tap");

                                onTap(index);
                              },
                        child: OrderProductCard(
                          hideReviewButton: hideReviewButton,
                          orderId: widget.orderId,
                          product: products[index],
                          orderStatus: orderStatus,
                          index: index,
                          showCheckbox: showCheckbox,
                          isSelected:
                              selectedProducts.contains(products[index]),
                        ),
                      ),
                      if (isProductReturnable == false && showCheckbox == true)
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 10.h),
                            height: 100.h,
                            width: ScreenUtil().screenWidth / 1.2,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                        ),
                    ],
                  );
                },
              ),
              Gap(30.h),
              if (showButton == true)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: colors(context).accentColor!,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      Gap(24.h),
                      CustomButton(
                          buttonText: "Next",
                          buttonColor: isEnableNextButton == true
                              ? colors(context).primaryColor
                              : colors(context).primaryColor!.withOpacity(0.5),
                          onPressed: isEnableNextButton == true
                              ? () {
                                  if (selectedProducts.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: S.of(context).pleaseSelectOneProduct,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return;
                                  }
                                  context.nav.pop();
                                  context.nav.pushNamed(
                                    Routes.getReturnPolicyProductViewRouteName(
                                      AppConstants.appServiceName,
                                    ),
                                    arguments: widget.orderId,
                                  );
                                }
                              : null),
                    ],
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopCardWidget({
    required BuildContext context,
    required OrderDetails orderDetails,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      color: GlobalFunction.getContainerColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).shoppingFrom,
              style: AppTextStyle(context).bodyTextSmall),
          Gap(10.h),
          Row(
            children: [
              Expanded(
                child: Material(
                  borderRadius: BorderRadius.circular(8.r),
                  color: EcommerceAppColor.offWhite,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () {
                      // showDialog(
                      //   context: context,
                      //   builder: (context) => const SellerReviewDialog(),
                      // );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: colors(context).accentColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 7,
                            child: SizedBox(
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.r),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            orderDetails.data.order.shop.logo,
                                        height: 24.h,
                                        width: 24.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Gap(10.w),
                                  Flexible(
                                    flex: 5,
                                    child: Text(
                                      orderDetails.data.order.shop.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle(context)
                                          .bodyTextSmall
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: EcommerceAppColor.carrotOrange,
                                  size: 20.sp,
                                ),
                                Gap(5.w),
                                Text(
                                  orderDetails.data.order.shop.rating
                                      .toString(),
                                  style: AppTextStyle(context)
                                      .bodyTextSmall
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Gap(10.w),
              GestureDetector(
                onTap: () async {
                  final saveUser =
                      await ref.read(hiveServiceProvider).getUserInfo();
                  final shopModel = shop.Shop(
                    id: orderDetails.data.order.shop.id,
                    name: orderDetails.data.order.shop.name,
                    logo: orderDetails.data.order.shop.logo,
                  );

                  ref
                      .read(storeMessageControllerProvider.notifier)
                      .storeMessage(
                        shopId: orderDetails.data.order.shop.id,
                        userId: saveUser!.id!,

                        // productId: productDetails.product.id,
                      );

                  context.nav.pushNamed(
                    Routes.getChatViewRouteName(AppConstants.appServiceName),
                    arguments: shopModel,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: colors(context).primaryColor!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SvgPicture.asset(
                    Assets.svg.message,
                    color: colors(context).primaryColor,
                    // width: 16.w,
                    // height: 16.h,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavigationWidget(
      {required BuildContext context,
      required int orderId,
      required String orderStatus}) {
    return Consumer(builder: (context, ref, _) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        height: 86.h,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: orderStatus.toLowerCase() == 'pending'
            ? CustomTransparentButton(
                buttonText: S.of(context).cancelOrder,
                borderColor: colors(context).accentColor,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      title: S.of(context).areYouSureWantToCancelOrder,
                      confirmButtonText: S.of(context).confirm,
                      isLoading: ref.watch(orderControllerProvider),
                      onPressed: () {
                        ref
                            .read(orderControllerProvider.notifier)
                            .cancelOrder(orderId: orderId)
                            .then((response) {
                          final data = ref
                              .refresh(orderDetailsControllerProvider(orderId));
                          debugPrint(data.toString());
                          return context.nav.pop();
                        });
                      },
                    ),
                  );
                },
              )
            : orderStatus.toLowerCase() == 'delivered'
                ?
                //  ref.watch(orderControllerProvider)
                //     ? const Center(child: CircularProgressIndicator())
                //     :
                CustomButton(
                    buttonText: S.of(context).orderAgain,
                    onPressed: () => _showPaymentBottomSheet(context, orderId),
                  )
                : const SizedBox.shrink(),
      );
    });
  }

  Widget _buildPaymentBottomSheet() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer(builder: (context, ref, _) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shrinkWrap: true,
              itemCount: ref
                  .read(masterControllerProvider.notifier)
                  .materModel
                  .data
                  .paymentGateways
                  .length,
              itemBuilder: ((context, index) {
                final paymentGateway = ref
                    .read(masterControllerProvider.notifier)
                    .materModel
                    .data
                    .paymentGateways[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 7.h),
                  child: PaymentCard(
                    paymentGateways: paymentGateway,
                    isActive: ref.watch(selectedPayment) == paymentGateway.name,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor:
                            colors(context).accentColor!.withOpacity(0.8),
                        builder: (_) => LoadingWrapperWidget(
                          isLoading: ref.watch(paymentControllerProvider),
                          child: Container(),
                        ),
                      );
                      ref.read(selectedPayment.notifier).state =
                          paymentGateway.name;

                      ref
                          .read(paymentControllerProvider.notifier)
                          .orderPayment(
                            orderId: widget.orderId,
                            paymentMethod: ref.read(selectedPayment),
                          )
                          .then((paymentUrl) {
                        ref.refresh(selectedPayment.notifier).state;
                        if (paymentUrl != null) {
                          context.nav.pop();
                          context.nav.popAndPushNamed(
                            Routes.webPaymentScreen,
                            arguments: WebPaymentScreenArg(
                              paymentUrl: paymentUrl,
                              orderId: widget.orderId,
                            ),
                          );
                        } else {
                          Navigator.of(context)
                            ..pop()
                            ..pop();
                          GlobalFunction.showCustomSnackbar(
                            message: 'Something went wrong!',
                            isSuccess: false,
                          );
                        }
                      });
                    },
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToBePaidWidget({
    required PaymentType selectedPaymentType,
    required Function(PaymentType) onPaymentTypeChanged,
  }) {
    final masterData = ref.watch(masterControllerProvider.notifier).materModel;
    bool isCashonDeliveryEnable = masterData.data.cashOnDelivery;
    bool isOnlinePaymentEnable = masterData.data.onlinePayment;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  SvgPicture.asset(Assets.svg.receipt),
                  Gap(8.w),
                  Text(
                    S.of(context).toBePaid,
                    style: AppTextStyle(context).subTitle,
                  ),
                ],
              ),
            ),
            Text(
              GlobalFunction.price(
                ref: ref,
                price:
                    ref.read(cartSummeryController)['payableAmount'].toString(),
              ),
              style: AppTextStyle(context).subTitle,
            )
          ],
        ),
        Gap(10.h),
        Row(
          children: [
            if (isCashonDeliveryEnable)
              Flexible(
                flex: 1,
                child: PayCard(
                  isActive: selectedPaymentType == PaymentType.cash,
                  type: S.of(context).cashOnDelivery,
                  image: Assets.png.cash.image(),
                  onTap: () {
                    if (selectedPaymentType != PaymentType.cash) {
                      onPaymentTypeChanged(PaymentType.cash);
                    }
                  },
                ),
              ),
            Gap(10.w),
            if (isOnlinePaymentEnable)
              Flexible(
                flex: 1,
                child: PayCard(
                  isActive: selectedPaymentType == PaymentType.online,
                  type: S.of(context).creditOrDebitCard,
                  image: Assets.png.card.image(),
                  onTap: () {
                    if (selectedPaymentType != PaymentType.online) {
                      onPaymentTypeChanged(PaymentType.online);
                    }
                  },
                ),
              )
          ],
        ),
      ],
    );
  }

  void _showPaymentBottomSheet(BuildContext context, int orderId) {
    showModalBottomSheet(
      // isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return SizedBox(
            //  height: 400.h,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildToBePaidWidget(
                            selectedPaymentType: selectedPaymentType,
                            onPaymentTypeChanged: (PaymentType newType) {
                              setModalState(() {
                                selectedPaymentType = newType;
                                debugPrint(
                                    'selectedPaymentType: $selectedPaymentType');
                              });
                            },
                          ),
                          if (selectedPaymentType == PaymentType.online) ...[
                            _buildPaymentMethodsWidget(setModalState)
                            // const CircularProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Gap(8.h),
                  isConfirmLoading
                      ? CircularProgressIndicator()
                      : CustomButton(
                          buttonText: S.of(context).placeOrder,
                          onPressed: () {
                            {
                              setModalState(() {
                                isConfirmLoading = true;
                              });
                              ref
                                  .read(orderControllerProvider.notifier)
                                  .orderAgain(
                                    orderId: orderId,
                                    paymentMethod: selectedPaymentType ==
                                            PaymentType.online
                                        ? ref.read(selectedPayment)
                                        : selectedPaymentType.name,
                                  )
                                  .then(
                                (response) {
                                  setModalState(() {
                                    isConfirmLoading = false;
                                  });
                                  debugPrint(
                                      "responseSuccess ${response.message}");
                                  if (response.isSuccess == true) {
                                    ref.invalidate(isProfileVefifySuccess);
                                    ref
                                        .read(cartController.notifier)
                                        .getAllCarts();
                                    ref
                                        .refresh(
                                            selectedTabIndexProvider.notifier)
                                        .state;
                                    ref.invalidate(selectedPayment);
                                    showDialog(
                                      context: context,
                                      barrierColor: colors(context)
                                          .accentColor!
                                          .withOpacity(0.8),
                                      builder: (context) => OrderPlacedDialog(
                                        customButton: response.data == null
                                            ? null
                                            : CustomButton(
                                                buttonText:
                                                    S.of(context).makePayment,
                                                onPressed: () {
                                                  context.nav
                                                      .pushNamedAndRemoveUntil(
                                                    Routes.webPaymentScreen,
                                                    (route) => false,
                                                    arguments:
                                                        WebPaymentScreenArg(
                                                      paymentUrl: response.data,
                                                      orderId: null,
                                                    ),
                                                  );
                                                }),
                                      ),
                                    );
                                  } else {
                                    context.nav.pop();
                                  }
                                },
                              );
                            }
                          })
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildPaymentMethodsWidget(
      void Function(void Function()) setModalState) {
    final selectedPaymentMethod = ref.watch(selectedPayment);
    return SizedBox(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 16.h),
        shrinkWrap: true,
        itemCount: ref
            .read(masterControllerProvider.notifier)
            .materModel
            .data
            .paymentGateways
            .length,
        itemBuilder: (context, index) {
          final paymentMethod = ref
              .read(masterControllerProvider.notifier)
              .materModel
              .data
              .paymentGateways[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: PaymentCard(
              onTap: () {
                setModalState(() {
                  ref.read(selectedPayment.notifier).state = paymentMethod.name;
                });
              },
              isActive: selectedPaymentMethod == paymentMethod.name,
              paymentGateways: paymentMethod,
            ),
          );
        },
      ),
    );
  }
}
