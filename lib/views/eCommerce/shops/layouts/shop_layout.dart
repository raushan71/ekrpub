import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/custom_cart.dart';
import 'package:ekray/components/ecommerce/custom_search_field.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/shop/shop_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/models/eCommerce/common/product_filter_model.dart';
import 'package:ekray/models/eCommerce/shop/shop_details.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/categories/components/sub_categories_bottom_sheet.dart';
import 'package:ekray/views/eCommerce/home/components/category_card.dart';
import 'package:ekray/views/eCommerce/home/components/product_card.dart';
import 'package:ekray/views/eCommerce/products/components/review_card.dart';
import 'package:ekray/views/eCommerce/shops/components/rating_summary.dart';

class EcommerceShopLayout extends ConsumerStatefulWidget {
  final int shopId;

  const EcommerceShopLayout({super.key, required this.shopId});

  @override
  ConsumerState<EcommerceShopLayout> createState() =>
      _EcommerceShopLayoutState();
}

class _EcommerceShopLayoutState extends ConsumerState<EcommerceShopLayout> {
  bool isProduct = true;
  int selectedTabIndex = 0;
  int columnCount = 4;

  final ScrollController productScrollController = ScrollController();
  final ScrollController reviewScrollController = ScrollController();

  bool isRatingsVisible = true;
  bool isHeadingShow = true;

  final TextEditingController textEditingController = TextEditingController();

  int productPage = 1;
  int reviewPage = 1;
  final int perPage = 20;

  String shopName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchShopDetails();
      _fetchReviews();
    });

    productScrollController.addListener(productScrollListener);
    reviewScrollController.addListener(reviewScrollListener);
  }

  @override
  void dispose() {
    productScrollController.dispose();
    reviewScrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void _fetchShopDetails() {
    ref
        .read(shopControllerProvider.notifier)
        .getShopProducts(
          productFilterModel:
              ProductFilterModel(shopId: widget.shopId, page: 1, perPage: 20),
          isPagination: false,
        )
        .then((value) => setState(() {}));
  }

  void _fetchReviews() {
    ref.read(shopControllerProvider.notifier).getReviews(
          isPagination: false,
          productFilterModel: ProductFilterModel(
            page: reviewPage,
            perPage: perPage,
            shopId: widget.shopId,
          ),
        );
    ref.read(shopControllerProvider.notifier).review.clear();
  }

  void reviewScrollListener() {
    if (reviewScrollController.offset >=
        reviewScrollController.position.maxScrollExtent) {
      if (ref.read(shopControllerProvider.notifier).review.length <
              ref.read(shopControllerProvider.notifier).totalReviews! &&
          !ref.read(shopControllerProvider)) {
        reviewPage++;
        ref.read(shopControllerProvider.notifier).getReviews(
              isPagination: true,
              productFilterModel: ProductFilterModel(
                page: reviewPage,
                perPage: perPage,
                shopId: widget.shopId,
              ),
            );
      }
    }

    if (reviewScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (isRatingsVisible) {
        setState(() {
          isHeadingShow = false;
          isRatingsVisible = false;
        });
      }
    } else if (reviewScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!isRatingsVisible &&
          reviewScrollController.position.pixels ==
              reviewScrollController.position.minScrollExtent) {
        setState(() {
          isHeadingShow = true;
          isRatingsVisible = true;
        });
      }
    }
  }

  void productScrollListener() {
    if (productScrollController.offset >=
        productScrollController.position.maxScrollExtent) {
      if (ref.read(shopControllerProvider.notifier).products.length <
              ref.read(shopControllerProvider.notifier).totalShopProducts! &&
          !ref.read(shopControllerProvider)) {
        productPage++;
        ref.read(shopControllerProvider.notifier).getShopProducts(
              isPagination: true,
              productFilterModel: ProductFilterModel(
                page: productPage,
                perPage: perPage,
                shopId: widget.shopId,
              ),
            );
      }
    }

    if (productScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (isRatingsVisible) {
        setState(() {
          isHeadingShow = false;
        });
      }
    } else if (productScrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        productScrollController.position.pixels ==
            productScrollController.position.minScrollExtent) {
      setState(() {
        isHeadingShow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              surfaceTintColor: GlobalFunction.getContainerColor(),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
          ),
          body: Column(
            children: [
              _buildAppBarWidget(context),
              Consumer(
                builder: (context, ref, _) {
                  final asyncValue =
                      ref.watch(shopDetailsControllerProvider(widget.shopId));
                  return asyncValue.when(
                    data: (shopDetails) {
                      return Expanded(
                        child: NestedScrollView(
                          controller: selectedTabIndex == 0
                              ? productScrollController
                              : null,
                          headerSliverBuilder: (context, value) {
                            return [
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    _buildHeaderWidget(context, shopDetails),
                                  ],
                                ),
                              ),
                              SliverPersistentHeader(
                                pinned: true,
                                floating: true,
                                delegate: _SliverAppBarDelegate(
                                  child: _buildFilterRowWidget(context),
                                ),
                              ),
                            ];
                          },
                          body: _buildTabBarViewWidget(context),
                        ),
                      );
                    },
                    error: (error, stackTrace) => Center(
                      child: Text(error.toString()),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              )
            ],
          )),
    );
  }

  Widget _buildAppBarWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w).copyWith(bottom: 5.h),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.nav.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          Gap(20.w),
          Flexible(
            flex: 5,
            child: CustomSearchField(
              name: 'search',
              hintText: 'Search Product',
              textInputType: TextInputType.text,
              controller: textEditingController,
              onChanged: (value) {
                ref.read(shopControllerProvider.notifier).getShopProducts(
                      productFilterModel: ProductFilterModel(
                        shopId: widget.shopId,
                        page: 1,
                        perPage: 20,
                        search: value,
                      ),
                      isPagination: false,
                    );
              },
              widget: Container(
                margin: EdgeInsets.all(10.sp),
                child: SvgPicture.asset(Assets.svg.searchHome),
              ),
            ),
          ),
          Gap(10.w),
          CustomCartWidget(context: context),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(BuildContext context, ShopDetails shopDetails) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.only(top: isHeadingShow ? 0 : 0),
      child: Column(
        children: [
          _buildShopInfoCard(context, shopDetails),
          if (shopDetails.banners.isNotEmpty) _buildBannerWidget(shopDetails),
        ],
      ),
    );
  }

  Widget _buildShopInfoCard(BuildContext context, ShopDetails shopDetails) {
    return Container(
      color: colors(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: shopDetails.logo,
              width: 44.w,
              height: 44.h,
              fit: BoxFit.cover,
            ),
          ),
          Gap(10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 160.w),
                child: AutoSizeText(
                  shopDetails.name,
                  style: AppTextStyle(context).title.copyWith(
                      color: EcommerceAppColor.white, fontSize: 20.sp),
                ),
              ),
              Gap(2.h),
              Text(
                "${shopDetails.totalProducts}+ Products",
                style: AppTextStyle(context).bodyText.copyWith(
                      color: EcommerceAppColor.white,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  color: shopDetails.shopStatus == 'Offline'
                      ? EcommerceAppColor.lightGray
                      : EcommerceAppColor.green,
                ),
                child: Center(
                  child: Text(
                    shopDetails.shopStatus,
                    style: AppTextStyle(context)
                        .bodyTextSmall
                        .copyWith(color: EcommerceAppColor.white),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors(context).dark!.withOpacity(0.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16.sp,
                      color: EcommerceAppColor.carrotOrange,
                    ),
                    Text(
                      shopDetails.rating.toString(),
                      style: AppTextStyle(context).title.copyWith(
                            fontSize: 18.sp,
                            color: EcommerceAppColor.white,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerWidget(ShopDetails shopDetails) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      height: 81.h,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 16.w),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: shopDetails.banners.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(right: 10.w),
            width: MediaQuery.of(context).size.width / 1.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: shopDetails.banners[index].thumbnail,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  final List<String> filterText = ['All Products', 'Categories', 'Reviews'];

  Widget _buildFilterRowWidget(BuildContext context) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colors(context).accentColor,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: List.generate(
          filterText.length,
          (index) => Flexible(
            flex: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(30.r),
              onTap: () {
                setState(() {
                  selectedTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  color: selectedTabIndex == index
                      ? GlobalFunction.getContainerColor()
                      : colors(context).accentColor,
                  boxShadow: [
                    if (selectedTabIndex == index)
                      const BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.10),
                        offset: Offset(0, 0),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                  ],
                ),
                height: 50.h,
                child: Center(
                  child: Text(
                    filterText[index],
                    style: AppTextStyle(context)
                        .bodyText
                        .copyWith(color: const Color(0xFF617885)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarViewWidget(BuildContext context) {
    switch (selectedTabIndex) {
      case 0:
        return _buildProductsWidget();
      case 1:
        return _buildCategoriesWidget();
      case 2:
        return _buildReviewWidget();
      default:
        return _buildProductsWidget();
    }
  }

  Widget _buildProductsWidget() {
    final products = ref.watch(shopControllerProvider.notifier).products;

    return Container(
      margin: EdgeInsets.only(top: 10.h),
      color: colors(context).accentColor,
      child: ref.watch(shopControllerProvider) && products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : AnimationLimiter(
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.66,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return AnimationConfiguration.staggeredGrid(
                    duration: const Duration(milliseconds: 375),
                    position: index,
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: ProductCard(
                        product: product,
                        onTap: () {
                          context.nav.pushNamed(
                            Routes.getProductDetailsRouteName(
                                AppConstants.appServiceName),
                            arguments: product.id,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCategoriesWidget() {
    final asyncValue =
        ref.watch(shopCategoriesControllerProvider(widget.shopId));

    return asyncValue.when(
      data: (categories) {
        return Container(
          margin: EdgeInsets.only(top: 14.h),
          color: colors(context).accentColor,
          child: AnimationLimiter(
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 15.h,
                crossAxisSpacing: 0.w,
                childAspectRatio: 90.w / 105.w,
                crossAxisCount: columnCount,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: columnCount,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: CategoryCard(
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
                            GlobalFunction.navigatorKey.currentContext!.nav
                                .pushNamed(
                              Routes.getProductsViewRouteName(
                                AppConstants.appServiceName,
                              ),
                              arguments: [
                                category.id,
                                category.name,
                                null,
                                null,
                                shopName,
                                category.subCategories,
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildReviewWidget() {
    final reviews = ref.watch(shopControllerProvider.notifier).review;

    return ref.watch(shopControllerProvider) && reviews.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                if (isRatingsVisible)
                  RatingSummary(
                    averageRatingPercentage: ref
                        .watch(shopControllerProvider.notifier)
                        .averageRatingPercentagew!,
                  ),
                ListView.builder(
                  itemCount: reviews.length,
                  controller: reviewScrollController,
                  padding: EdgeInsets.only(top: 8.h),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ReviewCard(review: review);
                  },
                ),
              ],
            ),
          );
  }
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
  double get maxExtent => 70.0;

  @override
  double get minExtent => 70.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
