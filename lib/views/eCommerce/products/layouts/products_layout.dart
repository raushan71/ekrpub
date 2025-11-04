import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/custom_cart.dart';
import 'package:ekray/components/ecommerce/custom_search_field.dart';
import 'package:ekray/components/ecommerce/product_not_found.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/product/product_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/category/category.dart';
import 'package:ekray/models/eCommerce/common/product_filter_model.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/home/components/product_card.dart';
import 'package:ekray/views/eCommerce/products/components/filter_modal_bottom_sheet.dart';
import 'package:ekray/views/eCommerce/products/components/list_product_card.dart';

final isListProvider = StateProvider<bool>((ref) => true);

class EcommerceProductsLayout extends ConsumerStatefulWidget {
  final int? categoryId;
  final String? sortType;
  final String categoryName;
  final int? subCategoryId;
  final String? shopName;
  final List<SubCategory>? subCategories;

  const EcommerceProductsLayout({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.sortType,
    this.subCategoryId,
    this.shopName,
    this.subCategories,
  });

  @override
  ConsumerState<EcommerceProductsLayout> createState() =>
      _EcommerceProductsLayoutState();
}

class _EcommerceProductsLayoutState
    extends ConsumerState<EcommerceProductsLayout> {
  final ScrollController scrollController = ScrollController();
  final ScrollController productScrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  bool isHeaderVisible = true;
  // bool isList = true;
  int page = 1;
  int perPage = 20;
  List<FilterCategory> filterCategoryList = [
    FilterCategory(id: 0, name: 'All')
  ];
  double scrollPossition = 0.0;
  bool isLastPosition = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(productControllerProvider.notifier).products.clear();
      _setselectedSubCategory(id: widget.subCategoryId ?? 0).then((_) {
        _fetchProducts(isPagination: false);
      });
    });
    _setSubCotegory(subCategories: widget.subCategories ?? []);

    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    debugPrint("listener");
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLastPosition = true;
        scrollPossition = scrollController.position.pixels;
      });
      print('Call fetch more products');
      _fetchMoreProducts();
    }
  }

  void _fetchProducts({required bool isPagination}) {
    ref.read(productControllerProvider.notifier).getCategoryWiseProducts(
          productFilterModel: ProductFilterModel(
            categoryId: widget.categoryId,
            page: page,
            perPage: perPage,
            search: searchController.text,
            sortType: widget.sortType,
            subCategoryId: ref.watch(selectedSubCategory) != 0
                ? ref.watch(selectedSubCategory)
                : null,
          ),
          isPagination: isPagination,
        );
  }

  void _fetchMoreProducts() {
    final productNotifier = ref.read(productControllerProvider.notifier);
    if (productNotifier.products.length < productNotifier.total! &&
        !ref.watch(productControllerProvider)) {
      page++;
      _fetchProducts(isPagination: true);
    }
  }

  void _setSubCotegory({required List<SubCategory> subCategories}) {
    for (SubCategory category in subCategories) {
      filterCategoryList.add(
        FilterCategory(id: category.id, name: category.name),
      );
    }
  }

  Future<void> _setselectedSubCategory({required int id}) {
    ref.read(selectedSubCategory.notifier).state = id;
    return Future.value();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("isList ${ref.watch(isListProvider)}");
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: GlobalFunction.getContainerColor()));
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor ==
                const Color.fromARGB(255, 1, 1, 2)
            ? colors(context).dark
            : colors(context).accentColor,
        body: NestedScrollView(
          floatHeaderSlivers: false,
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, value) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _customHeaderAppBarWidget(),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  maxExtentS: widget.subCategories!.isNotEmpty ? 110.h : 60.h,
                  child: _buildFilterRow(context),
                ),
              )
            ];
          },
          body: _buildProductsWidget(context),
        ),
      ),
    );
  }

  Widget _customHeaderAppBarWidget() {
    return _buildHeaderRow(context);
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 16.w, bottom: 20.h),
      color: GlobalFunction.getContainerColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLeftRow(context),
          _buildRightRow(context),
        ],
      ),
    );
  }

  Widget _buildLeftRow(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => context.nav.pop(context),
            icon: Icon(Icons.arrow_back, size: 26.sp),
          ),
          Gap(16.w),
          Expanded(
            child: Text(
              widget.shopName ?? widget.categoryName,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle(context).subTitle,
            ),
          ),
          Gap(4.w),
        ],
      ),
    );
  }

  Widget _buildRightRow(BuildContext context) {
    return Row(
      children: [
        CustomCartWidget(context: context),
        Gap(16.w),
        GestureDetector(
          onTap: () => _showFilterModal(context),
          child: SvgPicture.asset(Assets.svg.filter, width: 46.sp),
        ),
      ],
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: GlobalFunction.getContainerColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      context: context,
      builder: (_) => FilterModalBottomSheet(
        productFilterModel: ProductFilterModel(
          page: 1,
          perPage: 20,
          categoryId: widget.categoryId,
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      color: GlobalFunction.getContainerColor(),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: CustomSearchField(
                  name: 'searchProduct',
                  hintText: S.of(context).searchProduct,
                  textInputType: TextInputType.text,
                  controller: searchController,
                  onChanged: (value) {
                    page = 1;
                    _fetchProducts(isPagination: false);
                  },
                  widget: Container(
                    margin: EdgeInsets.all(10.sp),
                    child: SvgPicture.asset(Assets.svg.searchHome),
                  ),
                ),
              ),
              Gap(20.w),
              Consumer(
                builder: (context, ref, child) {
                  final isList = ref.watch(isListProvider);
                  return GestureDetector(
                    onTap: () =>
                        ref.read(isListProvider.notifier).state = !isList,
                    child: SvgPicture.asset(
                        isList ? Assets.svg.grid : Assets.svg.list,
                        width: 26.w),
                  );
                },
              ),
            ],
          ),
          Gap(8.h),
          Visibility(
              visible: widget.sortType != null,
              child: Divider(
                  color: colors(context).accentColor, height: 2, thickness: 2)),
          Visibility(
            visible:
                widget.sortType == null && widget.subCategories!.isNotEmpty,
            child: _buildFilterListWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterListWidget() {
    return Consumer(builder: (context, ref, _) {
      return Container(
        margin: EdgeInsets.only(top: 8.h),
        height: 35.h,
        color: GlobalFunction.getContainerColor(),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filterCategoryList.length,
          itemBuilder: (context, index) {
            debugPrint("selected category1 ${ref.watch(selectedSubCategory)}");
            debugPrint(
                "selected category2 ${ref.watch(selectedSubCategory) == filterCategoryList[index].id}");
            final isSelected =
                ref.watch(selectedSubCategory) == filterCategoryList[index].id;

            debugPrint("isSelected $isSelected");

            return GestureDetector(
              onTap: () {
                if (searchController.text.isNotEmpty) {
                  searchController.clear();
                }
                page = 1;
                if (ref.watch(selectedSubCategory.notifier).state !=
                    filterCategoryList[index].id) {
                  debugPrint(
                      "selected category3 ${filterCategoryList[index].id}");

                  _setselectedSubCategory(id: filterCategoryList[index].id!)
                      .then((_) {
                    _fetchProducts(isPagination: false);
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: isSelected
                          ? colors(context).primaryColor!
                          : colors(context).accentColor!),
                ),
                child: Center(
                  child: Text(filterCategoryList[index].name,
                      style: AppTextStyle(context).bodyTextSmall),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildProductsWidget(BuildContext context) {
    final productController = ref.watch(productControllerProvider.notifier);
    final products = productController.products;

    if (ref.watch(productControllerProvider)) {
      return Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const ProductNotFoundWidget();
    }

    return ref.watch(isListProvider)
        ? _buildListProductsWidget(context)
        : _buildGridProductsWidget(context);
  }

  Widget _buildListProductsWidget(BuildContext context) {
    final products = ref.watch(productControllerProvider.notifier).products;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: AnimationLimiter(
        child: ListView.builder(
          controller: scrollController,
          // physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          itemCount: products.length,
          itemBuilder: (context, index) {
            if (isLastPosition && scrollController.hasClients) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollController.jumpTo(scrollPossition);
                setState(() {
                  isLastPosition = false;
                });
              });
            }
            final product = products[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: ListProductCard(
                    product: product,
                    onTap: () => context.nav.pushNamed(
                      Routes.getProductDetailsRouteName(
                          AppConstants.appServiceName),
                      arguments: product.id,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridProductsWidget(BuildContext context) {
    final products = ref.watch(productControllerProvider.notifier).products;

    return AnimationLimiter(
      child: GridView.builder(
        controller: scrollController,

        // physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.66,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          if (isLastPosition && scrollController.hasClients) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollController.jumpTo(scrollPossition);
              setState(() {
                isLastPosition = false;
              });
            });
          }
          final product = products[index];
          return AnimationConfiguration.staggeredGrid(
            duration: const Duration(milliseconds: 375),
            position: index,
            columnCount: 2,
            child: ScaleAnimation(
              child: ProductCard(
                product: product,
                onTap: () => context.nav.pushNamed(
                  Routes.getProductDetailsRouteName(
                      AppConstants.appServiceName),
                  arguments: product.id,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  final selectedSubCategory = StateProvider<int>((value) => 0);
}

class FilterCategory {
  final int? id;
  final String name;

  FilterCategory({this.id, required this.name});
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.child,
    this.maxExtentS = 80.0,
  });

  final Widget child;
  final double maxExtentS;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxExtentS;

  @override
  double get minExtent => maxExtentS;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
