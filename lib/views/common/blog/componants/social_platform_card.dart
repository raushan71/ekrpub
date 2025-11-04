import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialPlatformCard extends StatelessWidget {
  final Color color;
  final String icon;
  final VoidCallback onTap;
  const SocialPlatformCard(
      {super.key,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
/*************  ✨ Codeium Command ⭐  *************/
  /// Builds a [GestureDetector] widget that wraps a [Container] widget.
  ///
  /// The [Container] widget is given a fixed width and height of 75 and 48
  /// logical pixels respectively. It is also given a margin of 8 logical
  /// pixels on the right side. The background color of the [Container] is set
  /// to [color]. The [Container] contains a [Center] widget which in turn
  /// contains an [SvgPicture] widget that displays the icon specified by
  /// [icon].
  ///
  /// When the [GestureDetector] is tapped, it calls the [onTap] callback.
  /// ****  8b565f33-b638-44d7-9462-db00e5d296ad  ******
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75.w,
        height: 48.h,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: color,
        ),
        child: Center(
          child: SvgPicture.asset(icon),
        ),
      ),
    );
  }
}
