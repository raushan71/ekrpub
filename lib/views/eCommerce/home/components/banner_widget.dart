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
  late CarouselSliderController _carouselController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    // Initialize current index
    _currentIndex = 0;
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dashboardData.banners.isEmpty) {
      return SizedBox(height: 0.h);
    }

    return Stack(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.dashboardData.banners.length,
          itemBuilder: (context, index, realIndex) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: widget.dashboardData.banners[index].thumbnail,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 160.h,
                    color: colors(context).accentColor?.withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors(context).primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 160.h,
                    color: colors(context).accentColor?.withOpacity(0.1),
                    child: Icon(
                      Icons.error_outline,
                      color: colors(context).hintTextColor,
                    ),
                  ),
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 100),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 160.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.dashboardData.banners.length > 1,
            pauseAutoPlayOnTouch: true,
            pauseAutoPlayOnManualNavigate: true,
            onPageChanged: (index, reason) {
              // Only update state if this widget is still mounted
              if (mounted && _currentIndex != index) {
                setState(() {
                  _currentIndex = index;
                });
                // Update the provider for indicator dots (for other widgets that might need it)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ref.read(currentPageController.notifier).state = index;
                  }
                });
              }
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
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? colors(context).light
                      : colors(context).accentColor!.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30.sp),
                ),
                height: 8.h,
                width: _currentIndex == index ? 24.w : 8.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
