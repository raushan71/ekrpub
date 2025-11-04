import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_list_model/return_order.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';

class ReturnOrderCard extends ConsumerWidget {
  final ReturnOrder? order;
  const ReturnOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currecy = ref.watch(currencyProvider);
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Material(
        color: GlobalFunction.getContainerColor(),
        child: InkWell(
          onTap: () {
            context.nav.pushNamed(
              Routes.getReturnOrderDetailsViewRouteName(
                  AppConstants.appServiceName),
              arguments: order?.id,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 20.h,
            ),
            margin: EdgeInsets.only(top: 3.h),
            width: double.infinity,
            child: Column(
              children: [
                _buildAddressCardWidget(context),
                Gap(14.h),
                _buildRowWidget(
                  context: context,
                  key: S.of(context).orderId,
                  value: order?.orderId,
                ),
                Gap(14.h),
                _buildRowWidget(
                  context: context,
                  key: S.of(context).returnDate,
                  value: order?.returnDate ?? '',
                ),
                Gap(14.h),
                _buildRowWidget(
                  context: context,
                  key: S.of(context).amount,
                  value: "${currecy.symbol}${order?.amount}",
                  isAmount: true,
                ),
                // Gap(14.h),
                // _buildRowWidget(
                //   context: context,
                //   key: S.of(context).reason,
                //   value: order?.reason,
                //   isAmount: true,
                // ),
                Gap(14.h),
                _buildRowWidget(
                  context: context,
                  key: S.of(context).status,
                  value: order?.status?.toLowerCase(),
                  isOrderStatus: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowWidget({
    required BuildContext context,
    required String key,
    required dynamic value,
    bool isAmount = false,
    bool isOrderStatus = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: AppTextStyle(context).bodyText.copyWith(
                color: colors(context).bodyTextSmallColor,
              ),
        ),
        if (isOrderStatus) ...[
          GlobalFunction.getStatusWidget(context: context, status: value)
        ] else ...[
          Consumer(builder: (context, ref, _) {
            return Text(
              isAmount ? value.toString() : value.toString(),
              style: AppTextStyle(context).bodyText,
            );
          }),
        ]
      ],
    );
  }

  Widget _buildAddressCardWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors(context).accentColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Flexible(flex: 1, child: SvgPicture.asset(Assets.svg.fillLocation)),
          Gap(5.w),
          Flexible(
            flex: 8,
            child: Text(
              order?.returnAddress ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle(context).bodyText.copyWith(fontSize: 12.sp),
            ),
          )
        ],
      ),
    );
  }
}
