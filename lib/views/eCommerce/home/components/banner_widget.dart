import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/models/eCommerce/dashboard/dashboard.dart';

class BannerWidget extends ConsumerStatefulWidget {
  final Dashboard dashboardData;
  const BannerWidget({super.key, required this.dashboardData});

  @override
  ConsumerState<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends ConsumerState<BannerWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.dashboardData.banners.isEmpty
        ? SizedBox(height: 0.h)
        : Stack(
            children: [
              CarouselSlider.builder(
                itemCount: widget.dashboardData.banners.length,
                itemBuilder: (context, index, realIndex) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        imageUrl: widget.dashboardData.banners[index].thumbnail,
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 160.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    ref.read(currentPageController.notifier).state = index;
                  },
                ),
              ),
              Positioned(
                bottom: 16.h,
                left: 50.w,
                right: 50.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.dashboardData.banners.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: ref.watch(currentPageController) == index
                            ? colors(context).light
                            : colors(context).accentColor!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30.sp),
                      ),
                      height: 8.h,
                      width: 8.w,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
