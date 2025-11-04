import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/models/eCommerce/category/category.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';

class SubCategoriesBottomSheet extends ConsumerWidget {
  final Category category;
  final String? shopName;
  const SubCategoriesBottomSheet({
    super.key,
    required this.category,
    this.shopName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: GlobalFunction.getContainerColor(),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.r), topRight: Radius.circular(8.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.name,
                  style:
                      AppTextStyle(context).subTitle.copyWith(fontSize: 20.sp)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3,
            ),
            itemBuilder: (context, index) {
              final SubCategory subCategory = category.subCategories[index];
              return _buildGadgetButton(subCategory: subCategory);
            },
            itemCount: category.subCategories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          const SizedBox(height: 16),
          _buildViewMoreButton(context: context),
        ],
      ),
    );
  }

  Widget _buildGadgetButton({required SubCategory subCategory}) {
    return ElevatedButton.icon(
      onPressed: () =>
          GlobalFunction.navigatorKey.currentContext!.nav.popAndPushNamed(
        Routes.getProductsViewRouteName(
          AppConstants.appServiceName,
        ),
        arguments: [
          category.id,
          category.name,
          null,
          subCategory.id,
          shopName,
          category.subCategories
        ],
      ),
      icon: CachedNetworkImage(
        imageUrl: subCategory.thumbnail,
        width: 24.w,
      ),
      label: Text(subCategory.name),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color:
              colors(GlobalFunction.navigatorKey.currentContext).accentColor!,
        ),
        alignment: Alignment.centerLeft,
        textStyle:
            AppTextStyle(GlobalFunction.navigatorKey.currentContext!).bodyText,
        foregroundColor:
            colors(GlobalFunction.navigatorKey.currentContext!).bodyTextColor,
      ),
    );
  }

  Widget _buildViewMoreButton({required BuildContext context}) {
    return OutlinedButton(
      onPressed: () => context.nav.popAndPushNamed(
        Routes.getProductsViewRouteName(
          AppConstants.appServiceName,
        ),
        arguments: [
          category.id,
          category.name,
          null,
          null,
          shopName,
          category.subCategories
        ],
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: GlobalFunction.getContainerColor(),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        side: BorderSide(color: EcommerceAppColor.primary, width: 1),
        minimumSize: Size(MediaQuery.of(context).size.width, 45.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'View all Products',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: colors(context).primaryColor,
                fontWeight: FontWeight.w600),
          ),
          Gap(3.w),
          SvgPicture.asset(
            Assets.svg.arrowRight,
            colorFilter: ColorFilter.mode(
              colors(context).primaryColor!,
              BlendMode.srcIn,
            ),
          )
        ],
      ),
    );
  }
}
