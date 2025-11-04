import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/controllers/eCommerce/voucher/voucher_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/voucher/voucher_model.dart';

class VoucherCard extends ConsumerStatefulWidget {
  final VoucherModel voucher;
  const VoucherCard({
    super.key,
    required this.voucher,
  });

  @override
  ConsumerState<VoucherCard> createState() => _VoucherCardState();
}

class _VoucherCardState extends ConsumerState<VoucherCard> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DottedBorder(
          color: widget.voucher.isCollected ||
                  ref.watch(couponIdsProvider).contains(widget.voucher.id)
              ? Colors.transparent
              : EcommerceAppColor.primary,
          dashPattern: const [5, 4],
          borderType: BorderType.RRect,
          radius: Radius.circular(12.r),
          strokeWidth: 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: colors(context).primaryColor!.withOpacity(0.2),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.voucher.discountType != 'Percentage') ...[
                  Text(
                    "${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}${widget.voucher.discount}",
                    style: AppTextStyle(context).title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ] else ...[
                  Text(
                    "${widget.voucher.discount}%",
                    style: AppTextStyle(context).title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                Gap(8.h),
                Text(
                  "${S.of(context).minimumSpend} ${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}${widget.voucher.minOrderAmount}",
                  style:
                      AppTextStyle(context).bodyText.copyWith(fontSize: 12.sp),
                ),
                Gap(8.h),
                Text(
                  '${S.of(context).validity}: ${widget.voucher.validity}',
                  style: AppTextStyle(context).bodyText.copyWith(
                      fontSize: 12.sp, color: colors(context).primaryColor),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 14.w,
          top: 18.h,
          child: Transform.rotate(
            angle: widget.voucher.isCollected ||
                    ref.watch(couponIdsProvider).contains(widget.voucher.id)
                ? 50
                : 0,
            child: Material(
              color: widget.voucher.isCollected ||
                      ref.watch(couponIdsProvider).contains(widget.voucher.id)
                  ? ColorTween(
                      begin: colors(context).primaryColor,
                      end: colors(context).accentColor,
                    ).lerp(
                      0.5,
                    )
                  : colors(context).primaryColor,
              borderRadius: BorderRadius.circular(100.r),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : AbsorbPointer(
                      absorbing: widget.voucher.isCollected ||
                          ref
                              .watch(couponIdsProvider)
                              .contains(widget.voucher.id),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100.r),
                        onTap: () {
                          setState(() {
                            _isLoading = true;
                          });
                          ref
                              .read(voucherCollectProvider.notifier)
                              .collectVoucher(voucherId: widget.voucher.id)
                              .then((response) {
                            if (response.isSuccess) {
                              ref
                                  .read(couponIdsProvider.notifier)
                                  .addCouponId(couponId: widget.voucher.id);
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          child: Center(
                            child: Text(
                              widget.voucher.isCollected ||
                                      ref
                                          .watch(couponIdsProvider)
                                          .contains(widget.voucher.id)
                                  ? S.of(context).collected
                                  : S.of(context).collect,
                              style: AppTextStyle(context)
                                  .buttonText
                                  .copyWith(color: colors(context).light),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        )
      ],
    );
  }
}
