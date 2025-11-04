import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/components/ecommerce/app_logo.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/category/category_controller.dart';
import 'package:ekray/controllers/eCommerce/flash_sales/flash_sales_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/category/category.dart';
import 'package:ekray/models/eCommerce/order/order_model.dart';
import 'package:ekray/models/eCommerce/product/product.dart'
    as product;
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/categories/components/sub_categories_bottom_sheet.dart';
import 'package:ekray/views/eCommerce/checkout/components/address_modal_bottom_sheet.dart';
import 'package:ekray/views/eCommerce/home/components/category_card.dart';
import 'package:ekray/views/eCommerce/home/components/popular_product_card.dart';
import 'package:ekray/views/eCommerce/home/components/product_card.dart';
import 'package:ekray/views/eCommerce/home/components/shop_card.dart';
import 'package:ekray/views/eCommerce/products/layouts/product_details_layout.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../../../components/ecommerce/custom_search_field.dart';
import '../../../../controllers/common/master_controller.dart';
import '../../../../controllers/eCommerce/dashboard/dashboard_controller.dart';
import '../../../../models/eCommerce/shop/shop.dart';
import '../components/banner_widget.dart';

class EcommerceHomeViewLayout extends ConsumerStatefulWidget {
  const EcommerceHomeViewLayout({super.key});

  @override
  ConsumerState<EcommerceHomeViewLayout> createState() =>
      _EcommerceHomeViewLayoutState();
}

class _EcommerceHomeViewLayoutState
    extends ConsumerState<EcommerceHomeViewLayout> {
  final TextEditingController productSearchController = TextEditingController();
  PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();

  final List<SubCategory> subCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(currentPageController.notifier).state;
      ref.read(flashSalesListControllerProvider.notifier).getFlashSalesList();
    });
    pageController.addListener(_pageListener);
  }

  @override
  void dispose() {
    if (mounted) scrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _pageListener() {
    int? newPage = pageController.page?.round();
    if (newPage != ref.read(currentPageController)) {
      setState(() {
        ref.read(currentPageController.notifier).state = newPage!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapperWidget(
      isLoading: ref.watch(subCategoryControllerProvider),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            surfaceTintColor: GlobalFunction.getContainerColor(),
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
        ),
        body: NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (context, value) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildAppBarWidget(context),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                floating: true,
                delegate: _SliverAppBarDelegate(
                  child: GestureDetector(
                    onTap: () => context.nav.pushNamed(
                      Routes.getProductsViewRouteName(
                          AppConstants.appServiceName),
                      arguments: [
                        null,
                        'All Product',
                        null,
                        null,
                        null,
                        subCategories,
                      ],
                    ),
                    child: Container(
                      decoration: _buildContainerDecoration(context),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: AbsorbPointer(
                        absorbing: true,
                        child: CustomSearchField(
                          name: 'product_search',
                          hintText: S.of(context).searchProduct,
                          textInputType: TextInputType.text,
                          controller: productSearchController,
                          widget: Container(
                            margin: EdgeInsets.all(10.sp),
                            child: SvgPicture.asset(Assets.svg.searchHome),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ];
          },
          body: ref.watch(dashboardControllerProvider).when(
                data: (dashboardData) => RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(dashboardControllerProvider).value;
                    ref
                        .refresh(flashSalesListControllerProvider.notifier)
                        .stream;
                  },
                  child: AnimationLimiter(
                    child: SingleChildScrollView(
                      child: Column(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.h,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            Gap(20.h),
                            BannerWidget(dashboardData: dashboardData),
                            Gap(20.h),
                            _buildCategoriesWidget(
                                context, dashboardData.categories),
                            Gap(10.h),
                            DealOfTheDayWidget(),
                            _buildScrollingContainers(),
                            _buildPopularProductWidget(
                                context, dashboardData.popularProducts),
                            if (ref
                                .read(masterControllerProvider.notifier)
                                .materModel
                                .data
                                .isMultiVendor) ...[
                              _buildShopsWidget(context, dashboardData.shops),
                              Divider(
                                  color: colors(context).accentColor,
                                  thickness: 2),
                            ],
                            Gap(10.h),
                            _buildBeautyProductWidget(
                                products: dashboardData.justForYou.products),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(error.toString(),
                      style: AppTextStyle(context).subTitle),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
        ),
      ),
    );
  }

  Widget _buildBeautyProductWidget({required List<product.Product> products}) {
    return Stack(
      children: [
        GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h)
              .copyWith(top: 34.h, bottom: 80.h),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _calculateCrossAxisCount(context),
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.66,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(
            product: products[index],
            onTap: () => context.nav.pushNamed(
              Routes.getProductDetailsRouteName(AppConstants.appServiceName),
              arguments: products[index].id,
            ),
          ),
        ),
        Positioned(
            left: 20.w,
            child: Text(S.of(context).justForYou,
                style: AppTextStyle(context).subTitle)),
        Positioned(
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
          child: _buildViewMoreButton(context, 'Just For You', 'just_for_you'),
        ),
      ],
    );
  }

  Widget _buildCategoriesWidget(
      BuildContext context, List<Category> categories) {
    return Column(
      children: [
        _buildSectionHeader(context, S.of(context).categories,
            Routes.getCategoriesViewRouteName(AppConstants.appServiceName)),
        Gap(10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Gap(10.w),
              ...categories.map(
                (category) => CategoryCard(
                  category: category,
                  onTap: () {
                    if (category.subCategories.isNotEmpty) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SubCategoriesBottomSheet(
                          category: category,
                        ),
                      );
                    } else {
                      GlobalFunction.navigatorKey.currentContext!.nav.pushNamed(
                        Routes.getProductsViewRouteName(
                          AppConstants.appServiceName,
                        ),
                        arguments: [
                          category.id,
                          category.name,
                          null,
                          null,
                          null,
                          category.subCategories,
                        ],
                      );
                    }
                  },
                ),
              ),
              Gap(10.w),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShopsWidget(BuildContext context, List<Shop> shops) {
    return Column(
      children: [
        _buildSectionHeader(context, S.of(context).shops,
            Routes.getShopsViewRouteName(AppConstants.appServiceName)),
        SizedBox(
          height: MediaQuery.of(context).size.height / 8.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: shops.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: ShopCardCircle(
                callback: () => context.nav.pushNamed(
                  Routes.getShopViewRouteName(AppConstants.appServiceName),
                  arguments: shops[index].id,
                ),
                shop: shops[index],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProductWidget(
      BuildContext context, List<product.Product> products) {
    return Container(
      decoration: BoxDecoration(color: colors(context).accentColor),
      child: Column(
        children: [
          _buildSectionHeader(context, S.of(context).popularProducts,
              Routes.getProductsViewRouteName(AppConstants.appServiceName),
              arguments: [
                null,
                'Popular',
                'popular',
                null,
                null,
                subCategories
              ]),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.8,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) => PopularProductCard(
                product: products[index],
                onTap: () => context.nav.pushNamed(
                  Routes.getProductDetailsRouteName(
                      AppConstants.appServiceName),
                  arguments: products[index].id,
                ),
              ),
            ),
          ),
          Gap(20.h),
        ],
      ),
    );
  }

  Widget _buildAppBarWidget(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(AppConstants.userBox).listenable(),
      builder: (context, userBox, _) {
        return Container(
          color: GlobalFunction.getContainerColor(),
          padding:
              EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ref.read(hiveServiceProvider).userIsLoggedIn()
                  ? GestureDetector(
                      onTap: () => showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                        ),
                        barrierColor:
                            colors(context).accentColor!.withOpacity(0.8),
                        context: context,
                        builder: (_) => const AddressModalBottomSheet(),
                      ),
                      child: _buildHeaderRow(context),
                    )
                  : const AppLogo(isAnimation: true, centerAlign: false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String route,
      {List<dynamic>? arguments}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h).copyWith(right: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyle(context).buttonText),
          TextButton(
            onPressed: () => context.nav.pushNamed(route, arguments: arguments),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context).viewMore,
                    style: AppTextStyle(context)
                        .bodyText
                        .copyWith(color: colors(context).primaryColor)),
                Gap(3.w),
                SvgPicture.asset(
                  Assets.svg.arrowRight,
                  colorFilter: ColorFilter.mode(
                      colors(context).primaryColor!, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton(
      BuildContext context, String title, String argument) {
    return OutlinedButton(
      onPressed: () => context.nav.pushNamed(
        Routes.getProductsViewRouteName(AppConstants.appServiceName),
        arguments: [null, title, argument, null, null, subCategories],
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: GlobalFunction.getBackgroundColor(context: context) !=
                colors(context).dark
            ? EcommerceAppColor.primary.withOpacity(0.1)
            : colors(context).accentColor,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        side: BorderSide(color: EcommerceAppColor.primary, width: 1),
        minimumSize: Size(MediaQuery.of(context).size.width, 45.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(S.of(context).viewMore,
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: colors(context).primaryColor,
                  fontWeight: FontWeight.w600)),
          Gap(3.w),
          SvgPicture.asset(
            Assets.svg.arrowRight,
            colorFilter: ColorFilter.mode(
                colors(context).primaryColor!, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  Decoration _buildContainerDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      boxShadow: [
        BoxShadow(
          color: colors(context).accentColor ?? EcommerceAppColor.offWhite,
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLeftRow(context),
        Icon(Icons.expand_more, color: colors(context).hintTextColor),
      ],
    );
  }

  Widget _buildLeftRow(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          const AppLogo(withAppName: false, isAnimation: true),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).deliverTo,
                    style: AppTextStyle(context)
                        .bodyTextSmall
                        .copyWith(fontWeight: FontWeight.w700)),
                ValueListenableBuilder(
                  valueListenable: Hive.box(AppConstants.userBox).listenable(),
                  builder: (context, box, _) {
                    final addressData =
                        box.get(AppConstants.defaultAddress, defaultValue: "");
                    print(
                        "Retrieved addressData: $addressData, Type: ${addressData.runtimeType}");

                    return Text(
                      addressData.isNotEmpty
                          ? _defaultAddress(context, addressData)
                          : "",
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle(context)
                          .bodyText
                          .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _defaultAddress(BuildContext context, dynamic data) {
    if (data == null) return '';

    try {
      Address address = Address.fromJson(data);

      return GlobalFunction.formatDeliveryAddress(
          context: context, address: address);
    } catch (e) {
      print("Error parsing address data: $e");
      return '';
    }
  }
}

int _calculateCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  return screenWidth > 600 ? 3 : 2;
}

class DealOfTheDayWidget extends ConsumerWidget {
  final bool showViewMore;
  const DealOfTheDayWidget({
    super.key,
    this.showViewMore = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime? endDate;
    final runningSaleData =
        ref.watch(flashSalesListControllerProvider.notifier).runningFlashSale;
    if (runningSaleData != null) {
      endDate = DateTime.parse(runningSaleData.endDate ?? "");
    }

    return runningSaleData != null
        ? Container(
            margin: EdgeInsets.all(showViewMore ? 10.w : 0.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: LinearGradient(colors: [
                  const Color(0xFFB822FF),
                  EcommerceAppColor.primary,
                ])),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        runningSaleData.name ?? "",
                        style: AppTextStyle(context)
                            .subTitle
                            .copyWith(color: EcommerceAppColor.white),
                      ),
                      Gap(10.h),
                      Row(
                        children: [
                          Text(
                            S.of(context).endingIn,
                            style: AppTextStyle(context).bodyText.copyWith(
                                fontSize: 16.sp,
                                color: EcommerceAppColor.white),
                          ),
                          Gap(10.w),
                          if (endDate != null)
                            SlideCountdownSeparated(
                              separatorStyle: AppTextStyle(context)
                                  .bodyText
                                  .copyWith(color: FoodAppColor.white),
                              style: AppTextStyle(context).title.copyWith(
                                  color: FoodAppColor.carrotOrange,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: EcommerceAppColor.white),
                              duration: endDate.isAfter(DateTime.now())
                                  ? endDate.difference(DateTime.now())
                                  : Duration.zero,
                            ),
                        ],
                      )
                    ],
                  ),
                  if (showViewMore)
                    _buildViewMoreButton(
                      context,
                      ref,
                      runningSaleData.id,
                      runningSaleData.name ?? "",
                    ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildViewMoreButton(
      BuildContext context, WidgetRef ref, id, String title) {
    return OutlinedButton(
      onPressed: () {
        ref
            .read(flashSaleDetailsControllerProvider.notifier)
            .getFlashSalesDetails(id: id);
        context.nav.pushNamed(Routes.flashSaleDetails, arguments: title);
      },
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => 60.h;

  @override
  double get minExtent => 60.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
