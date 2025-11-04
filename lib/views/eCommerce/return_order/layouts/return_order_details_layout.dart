import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/return_policy/return_policy_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_details_model/return_order_details_model.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_details_model/return_order_product.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/checkout/layouts/checkout_layout.dart';
import 'package:ekray/views/eCommerce/return_order/componants/return_address_card.dart';
import 'package:ekray/views/eCommerce/return_order/componants/return_order_details_card.dart';
import 'package:ekray/views/eCommerce/return_order/componants/return_product_card.dart';

class ReturnOrderDetailsLayout extends ConsumerStatefulWidget {
  final int orderId;
  const ReturnOrderDetailsLayout({super.key, required this.orderId});

  @override
  ConsumerState<ReturnOrderDetailsLayout> createState() =>
      _ReturnOrderDetailsLayoutState();
}

class _ReturnOrderDetailsLayoutState
    extends ConsumerState<ReturnOrderDetailsLayout> {
  bool isConfirmLoading = false;
  PaymentType selectedPaymentType = PaymentType.none;
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: colors(context).accentColor,
      appBar: AppBar(
        title: Text(S.of(context).orderDetails),
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final asyncValue =
              ref.watch(returnOrderDetailsControllerProvider(widget.orderId));
          return asyncValue.when(
            data: (orderDetails) => SingleChildScrollView(
              child: Column(
                children: [
                  Gap(8.h),
                  _buildServiceItemsWidget(
                    context,
                    orderDetails.data!.returnOrders!.returnOrderProducts!,
                    false,
                    null,
                    false,
                    widget.orderId,
                  ),
                  Gap(8.h),
                  _buildShopCardWidget(
                    context: context,
                    orderDetails: orderDetails,
                  ),
                  Gap(8.h),
                  ReturnAddressCard(
                    address: orderDetails.data!.returnOrders!.returnAddress!,
                    showEditButton: true,
                    onTap: () {},
                    editTap: () {},
                  ),
                  Gap(8.h),
                  ReturnOrderDetailsCard(
                    orderDetails: orderDetails,
                  ),
                  Gap(8.h),
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
    List<ReturnOrderProduct> products,
    bool? showCheckbox,
    Function(int)? onTap,
    bool? showButton,
    int? orderId,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 14.h,
          ),
          color: GlobalFunction.getContainerColor(),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  '${S.of(context).retrunItem} (${products.length})',
                  style:
                      AppTextStyle(context).subTitle.copyWith(fontSize: 16.sp),
                ),
              ),
              Gap(14.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) => ReturnOrderProductCard(
                  orderId: widget.orderId,
                  product: products[index],
                  index: index,
                  showCheckbox: showCheckbox,
                ),
              ),
              Gap(30.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopCardWidget({
    required BuildContext context,
    required ReturnOrderDetailsModel orderDetails,
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
                                        imageUrl: orderDetails
                                                .data?.returnOrders?.shopLogo ??
                                            "",
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
                                      orderDetails
                                              .data?.returnOrders?.shopName ??
                                          "",
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
                                  orderDetails.data?.returnOrders?.shopRating
                                          .toString() ??
                                      "0.0",
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
            ],
          )
        ],
      ),
    );
  }
}
