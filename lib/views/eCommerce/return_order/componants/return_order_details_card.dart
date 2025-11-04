import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_details_model/return_order_details_model.dart';
import 'package:ekray/utils/global_function.dart';

class ReturnOrderDetailsCard extends ConsumerStatefulWidget {
  final ReturnOrderDetailsModel orderDetails;
  const ReturnOrderDetailsCard({
    super.key,
    required this.orderDetails,
  });

  @override
  ConsumerState<ReturnOrderDetailsCard> createState() =>
      _ReturnOrderDetailsCardState();
}

class _ReturnOrderDetailsCardState
    extends ConsumerState<ReturnOrderDetailsCard> {
  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GlobalFunction.getContainerColor(),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowWidget(
            context: context,
            key: S.of(context).orderId,
            value: widget.orderDetails.data?.returnOrders?.orderId ?? "",
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).returnStatus,
            value: widget.orderDetails.data?.returnOrders?.status ?? "",
            isOrderStatus: true,
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).returnDate,
            value: widget.orderDetails.data?.returnOrders?.returnDate ?? "",
          ),
          // Gap(14.h),
          // _buildRowWidget(
          //   context: context,
          //   key: S.of(context).returnAddress,
          //   value: widget.orderDetails.data?.returnOrders?.returnAddress ?? "",
          // ),
          // Gap(14.h),
          // _buildRowWidget(
          //   context: context,
          //   key: S.of(context).reason,
          //   value: widget.orderDetails.data?.returnOrders?.reason ?? "",
          // ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).amount,
            value: GlobalFunction.price(
              ref: ref,
              price:
                  widget.orderDetails.data?.returnOrders?.amount.toString() ??
                      "0.0",
            ),
            isAmount: false,
          ),
          Gap(14.h),
          Text(
            S.of(context).reasonForReturn,
            // "Reason for Return",
            style: AppTextStyle(context).bodyText.copyWith(
                  color: colors(context).bodyTextSmallColor,
                ),
          ),
          Gap(7.h),
          Text(
            widget.orderDetails.data?.returnOrders?.reason ?? "",
            style: AppTextStyle(context).bodyText,
          ),
          Gap(14.h),
          if (widget.orderDetails.data?.returnOrders?.rejectNote != null)
            Text(
              S.of(context).cancellationReason,
              style: AppTextStyle(context).bodyText.copyWith(
                    color: colors(context).primaryColor,
                  ),
            ),
          Gap(7.h),
          Text(
            widget.orderDetails.data?.returnOrders?.rejectNote ?? "",
            style: AppTextStyle(context).bodyText,
          ),
        ],
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
            return SizedBox(
              width: 200.w,
              child: Text(
                textAlign: TextAlign.end,
                isAmount
                    ? '${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}$value'
                    : value.toString(),
                style: AppTextStyle(context).bodyText,
              ),
            );
          }),
        ]
      ],
    );
  }
}
