import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';

class DealOfDayWidget extends StatefulWidget {
  final DateTime targetDate;

  const DealOfDayWidget({
    super.key,
    required this.targetDate,
  });

  @override
  State<DealOfDayWidget> createState() => _DealOfDayWidgetState();
}

class _DealOfDayWidgetState extends State<DealOfDayWidget> {
  late Timer countdownTimer;
  late Duration remainingTime;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.targetDate.difference(DateTime.now());
    startTimer();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final now = DateTime.now();
        if (now.isBefore(widget.targetDate)) {
          remainingTime = widget.targetDate.difference(now);
        } else {
          remainingTime = Duration.zero;
          countdownTimer.cancel(); // Stop timer when countdown ends
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDealHeader(),
        Gap(16.h),
        _buildScrollingContainers(),
      ],
    );
  }

  Widget _buildDealHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: EcommerceAppColor.carrotOrange,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDealInfo(),
          SizedBox(height: 44.h, width: 120.w, child: _buildViewMoreButton()),
        ],
      ),
    );
  }

  Widget _buildDealInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).dealOfTheDay,
          style: AppTextStyle(context).subTitle.copyWith(
                color: colors(context).light,
              ),
        ),
        Gap(8.h),
        Row(
          children: [
            Text(
              S.of(context).endingIn,
              style: AppTextStyle(context).bodyText.copyWith(
                    color: colors(context).light,
                  ),
            ),
            Gap(10.w),
            _buildCountdownDisplay(),
          ],
        )
      ],
    );
  }

  Widget _buildCountdownDisplay() {
    final days = remainingTime.inDays;
    final hours = remainingTime.inHours.remainder(24);
    final minutes = remainingTime.inMinutes.remainder(60);
    final seconds = remainingTime.inSeconds.remainder(60);

    return Row(
      children: [
        ..._buildCountdownUnit(days, S.of(context).days),
        _separator(),
        ..._buildCountdownUnit(hours, S.of(context).hours),
        _separator(),
        ..._buildCountdownUnit(minutes, S.of(context).minutes),
        _separator(),
        ..._buildCountdownUnit(seconds, S.of(context).seconds),
      ],
    );
  }

  List<Widget> _buildCountdownUnit(int value, String label) {
    return [
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3).copyWith(left: 4.w, right: 4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.r),
              color: colors(context).light,
            ),
            child: Center(
              child: Text(
                _twoDigits(value),
                style: AppTextStyle(context).bodyText.copyWith(
                      color: EcommerceAppColor.carrotOrange,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          // Gap(4.h),
          // Text(
          //   label,
          //   style: AppTextStyle(context).bodyTextSmall.copyWith(
          //         color: colors(context).light,
          //       ),
          // ),
        ],
      ),
      Gap(5.w),
    ];
  }

  Widget _separator() {
    return Text(
      ':',
      style: AppTextStyle(context).bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: colors(context).light,
          ),
    );
  }

  Widget _buildViewMoreButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        side: const BorderSide(color: EcommerceAppColor.white, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).viewMore,
            style: AppTextStyle(context)
                .bodyTextSmall
                .copyWith(color: colors(context).light),
          ),
          Gap(3.w),
          SvgPicture.asset(
            Assets.svg.arrowRight,
            colorFilter:
                ColorFilter.mode(colors(context).light!, BlendMode.srcIn),
          )
        ],
      ),
    );
  }

  Widget _buildScrollingContainers() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(
          60,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 2.h,
            width: 5.w,
            color: EcommerceAppColor.lightGray.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
  }
}
