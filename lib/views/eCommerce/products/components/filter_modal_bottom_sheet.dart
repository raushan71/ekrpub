import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/controllers/eCommerce/product/product_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/common/product_filter_model.dart';
import 'package:ekray/utils/context_less_navigation.dart';

import '../../../../controllers/eCommerce/dashboard/dashboard_controller.dart';
import '../../../../models/eCommerce/category/category.dart';
import '../../../../models/eCommerce/product/filter.dart';

// ignore: must_be_immutable
class FilterModalBottomSheet extends ConsumerStatefulWidget {
  ProductFilterModel productFilterModel;
  FilterModalBottomSheet({
    super.key,
    required this.productFilterModel,
  });

  @override
  ConsumerState<FilterModalBottomSheet> createState() =>
      _FilterModalBottomSheetState();
}

class _FilterModalBottomSheetState
    extends ConsumerState<FilterModalBottomSheet> {
  final EdgeInsets _edgeInsets =
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h)
          .copyWith(bottom: 20.h);

  @override
  Widget build(BuildContext context) {
    final brandList =
        ref.watch(productControllerProvider.notifier).filter?.brands ?? [];
    final colorList =
        ref.watch(productControllerProvider.notifier).filter?.colors ?? [];
    final sizeList =
        ref.watch(productControllerProvider.notifier).filter?.sizes ?? [];
    final categories = ref.read(dashboardControllerProvider).value?.categories;
    return Padding(
      padding: _edgeInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 1.2.h,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Gap(10.h),
              _buildCustomerReviewSection(),
              Gap(20.h),
              _buildSortSection(),
              Gap(20.h),
              _buildCategorySection(categories: categories),
              Gap(20.h),
              _buildBrandSection(brandList: brandList),
              Gap(20.h),
              _buildColorSection(colorList: colorList),
              Gap(20.h),
              _buildSizeSection(sizeList: sizeList),
              Gap(20.h),
              _buildProductPriceSection(),
              Gap(30.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(context).filter,
          style: AppTextStyle(context).subTitle,
        ),
        IconButton(
          onPressed: () {
            _onPressClear();
            context.nav.pop();
          },
          icon: const Icon(Icons.close),
        )
      ],
    );
  }

  Widget _buildCustomerReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).customerReview,
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(8.h),
        _buildReviewChips(),
      ],
    );
  }

  Widget _buildReviewChips() {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(
        reviewList.length,
        (index) => Material(
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          color: ref.watch(selectedReviewIndex) == index
              ? colors(context).primaryColor
              : Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () {
              if (index == ref.read(selectedReviewIndex)) {
                ref.refresh(selectedReviewIndex.notifier).state = null;
              } else {
                ref.read(selectedReviewIndex.notifier).state = index;
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              width: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colors(context).accentColor!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16.sp,
                    color: EcommerceAppColor.carrotOrange,
                  ),
                  Gap(10.w),
                  Text(
                    reviewList[index].toString(),
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ref.watch(selectedReviewIndex) == index
                              ? colors(context).light
                              : null,
                        ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).sortBy,
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(10.h),
        _buildSortChips(),
      ],
    );
  }

  Widget _buildSortChips() {
    return Wrap(
      children: List.generate(
        getSortList(context).length,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors(context).accentColor!)),
            backgroundColor: colors(context).accentColor,
            disabledColor: colors(context).light,
            labelStyle: TextStyle(
              color: ref.watch(selectedSortByIndex) == index
                  ? colors(context).light
                  : null,
            ),
            label: Text(
              getSortList(context)[index]['title'],
            ),
            selectedColor: colors(context).primaryColor,
            surfaceTintColor: colors(context).light,
            checkmarkColor: colors(context).light,
            selected: ref.watch(selectedSortByIndex) != null &&
                ref.watch(selectedSortByIndex) == index,
            onSelected: (bool selected) {
              if (index == ref.read(selectedSortByIndex)) {
                ref.read(selectedSortByIndex.notifier).state = null;
                widget.productFilterModel =
                    widget.productFilterModel.copyWith(sortType: null);
              } else {
                ref.read(selectedSortByIndex.notifier).state = index;
                widget.productFilterModel = widget.productFilterModel
                    .copyWith(sortType: getSortList(context)[index]['key']);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductPriceSection() {
    final currentRangeValues = ref.watch(priceRangeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).productPrice,
              style: AppTextStyle(context)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              "${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}${ref.watch(selectedMinPrice)?.round() ?? currentRangeValues.start} - ${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}${ref.watch(selectedMaxPrice)?.round() ?? currentRangeValues.end} ",
              style: AppTextStyle(context).bodyText.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors(context).primaryColor,
                  ),
            )
          ],
        ),
        Gap(20.h),
        _buildPriceSlider(),
        Gap(10.h),
        _buildPriceRangeLabels(),
      ],
    );
  }

  Widget _buildPriceSlider() {
    final filter = ref.watch(productControllerProvider.notifier).filter;
    final currentRangeValues = ref.watch(priceRangeProvider);

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 8.h,
        overlayShape: SliderComponentShape.noThumb,
      ),
      child: RangeSlider(
        inactiveColor: colors(context).accentColor,
        activeColor: colors(context).primaryColor,
        min: filter?.minPrice ?? 0.0,
        max: filter?.maxPrice ?? 0.0,
        values: currentRangeValues,
        onChanged: (values) {
          ref.read(priceRangeProvider.notifier).state = values;
          ref.read(selectedMinPrice.notifier).state = values.start;
          ref.read(selectedMaxPrice.notifier).state = values.end;
        },
      ),
    );
  }

  Widget _buildPriceRangeLabels() {
    final minPrice =
        ref.watch(productControllerProvider.notifier).filter?.minPrice ?? 0.0;
    final maxPrice =
        ref.watch(productControllerProvider.notifier).filter?.maxPrice ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          ref
                  .read(masterControllerProvider.notifier)
                  .materModel
                  .data
                  .currency
                  .symbol +
              minPrice.toString(),
          style: AppTextStyle(context).bodyTextSmall,
        ),
        Text(
          ref
                  .read(masterControllerProvider.notifier)
                  .materModel
                  .data
                  .currency
                  .symbol +
              maxPrice.toString(),
          style: AppTextStyle(context).bodyTextSmall,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(50.r),
            onTap: () => _onPressClear(),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.r),
                  border: Border.all(color: colors(context).accentColor!)),
              child: Center(
                child: Text(
                  S.of(context).clear,
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ),
        ),
        Gap(20.w),
        Flexible(
          flex: 1,
          child: Consumer(builder: (context, ref, _) {
            return CustomButton(
              buttonText: S.of(context).apply,
              onPressed: _onPressFilter,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategorySection({List<Category>? categories}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(10.h),
        _buildCategoryChips(categories: categories),
      ],
    );
  }

  Widget _buildCategoryChips({List<Category>? categories}) {
    return Wrap(
      children: List.generate(
        categories?.length ?? 0,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors(context).accentColor!)),
            backgroundColor: colors(context).accentColor,
            disabledColor: colors(context).light,
            labelStyle: TextStyle(
              color: ref.watch(selectedCategoryByIndex) == index
                  ? colors(context).light
                  : null,
            ),
            label: Text(
              categories?[index].name ?? '',
            ),
            selectedColor: colors(context).primaryColor,
            surfaceTintColor: colors(context).light,
            checkmarkColor: colors(context).light,
            selected: ref.watch(selectedCategoryByIndex) != null &&
                ref.watch(selectedCategoryByIndex) == index,
            onSelected: (bool selected) {
              if (index == ref.read(selectedCategoryByIndex)) {
                ref.refresh(selectedCategoryByIndex.notifier).state;
                widget.productFilterModel =
                    widget.productFilterModel.copyWith(categoryId: null);
              } else {
                ref.read(selectedCategoryByIndex.notifier).state = index;
                widget.productFilterModel = widget.productFilterModel
                    .copyWith(categoryId: categories?[index].id);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection({List<Brand>? brandList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Brand",
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(10.h),
        _buildBrandChips(brands: brandList),
      ],
    );
  }

  Widget _buildBrandChips({List<Brand>? brands}) {
    return Wrap(
      children: List.generate(
        brands?.length ?? 0,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors(context).accentColor!)),
            backgroundColor: colors(context).accentColor,
            disabledColor: colors(context).light,
            labelStyle: TextStyle(
              color: ref.watch(selectedBrandIndex) == index
                  ? colors(context).light
                  : null,
            ),
            label: Text(
              brands?[index].name ?? '',
            ),
            selectedColor: colors(context).primaryColor,
            surfaceTintColor: colors(context).light,
            checkmarkColor: colors(context).light,
            selected: ref.watch(selectedBrandIndex) != null &&
                ref.watch(selectedBrandIndex) == index,
            onSelected: (bool selected) {
              if (index == ref.read(selectedBrandIndex)) {
                ref.refresh(selectedBrandIndex.notifier).state;
                widget.productFilterModel =
                    widget.productFilterModel.copyWith(brandId: null);
              } else {
                ref.watch(selectedBrandIndex.notifier).state = index;
                widget.productFilterModel = widget.productFilterModel
                    .copyWith(brandId: brands?[index].id);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorSection({List<Color>? colorList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(10.h),
        _buildColorChips(colorList: colorList),
      ],
    );
  }

  Widget _buildColorChips({List<Color>? colorList}) {
    return Wrap(
      children: List.generate(
        colorList?.length ?? 0,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors(context).accentColor!)),
            backgroundColor: colors(context).accentColor,
            disabledColor: colors(context).light,
            labelStyle: TextStyle(
              color: ref.watch(selectedColorIndex) == index
                  ? colors(context).light
                  : null,
            ),
            label: Text(
              colorList?[index].name ?? '',
            ),
            selectedColor: colors(context).primaryColor,
            surfaceTintColor: colors(context).light,
            checkmarkColor: colors(context).light,
            selected: ref.watch(selectedColorIndex) != null &&
                ref.watch(selectedColorIndex) == index,
            onSelected: (bool selected) {
              if (index == ref.read(selectedColorIndex)) {
                ref.refresh(selectedColorIndex.notifier).state;
                widget.productFilterModel =
                    widget.productFilterModel.copyWith(colorId: null);
              } else {
                ref.watch(selectedColorIndex.notifier).state = index;
                widget.productFilterModel = widget.productFilterModel
                    .copyWith(colorId: colorList?[index].id);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSection({List<Color>? sizeList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Size",
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Gap(10.h),
        _buildSizeChips(sizeList: sizeList),
      ],
    );
  }

  Widget _buildSizeChips({List<Color>? sizeList}) {
    return Wrap(
      children: List.generate(
        sizeList?.length ?? 0,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors(context).accentColor!)),
            backgroundColor: colors(context).accentColor,
            disabledColor: colors(context).light,
            labelStyle: TextStyle(
              color: ref.watch(selectedSizeIndex) == index
                  ? colors(context).light
                  : null,
            ),
            label: Text(
              sizeList?[index].name ?? '',
            ),
            selectedColor: colors(context).primaryColor,
            surfaceTintColor: colors(context).light,
            checkmarkColor: colors(context).light,
            selected: ref.watch(selectedSizeIndex) != null &&
                ref.watch(selectedSizeIndex) == index,
            onSelected: (bool selected) {
              if (index == ref.read(selectedSizeIndex)) {
                ref.refresh(selectedSizeIndex.notifier).state;
                widget.productFilterModel =
                    widget.productFilterModel.copyWith(sizeId: null);
              } else {
                ref.watch(selectedSizeIndex.notifier).state = index;
                widget.productFilterModel = widget.productFilterModel
                    .copyWith(sizeId: sizeList?[index].id);
              }
            },
          ),
        ),
      ),
    );
  }

  void _onPressFilter() {
    ref
        .read(productControllerProvider.notifier)
        .getCategoryWiseProducts(
          productFilterModel: widget.productFilterModel.copyWith(
            rating: ref.read(selectedReviewIndex) != null
                ? reviewList[ref.read(selectedReviewIndex)!]
                : null,
            sortType: ref.read(selectedSortByIndex) != null
                ? getSortList(context)[ref.read(selectedSortByIndex)!]['key']
                : null,
            minPrice: ref.read(selectedMinPrice)?.round(),
            maxPrice: ref.read(selectedMaxPrice)?.round(),
          ),
          isPagination: false,
        )
        .then((context) {
      ref.read(selectedReviewIndex.notifier).state = null;
      ref.read(selectedSortByIndex.notifier).state = null;

      ref.read(selectedCategoryByIndex.notifier).state = null;
      ref.read(selectedBrandIndex.notifier).state = null;
      ref.read(selectedColorIndex.notifier).state = null;
      ref.read(selectedSizeIndex.notifier).state = null;
      ref.invalidate(selectedMinPrice);
      ref.invalidate(selectedMaxPrice);
    });
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onPressClear() {
    ref.refresh(selectedReviewIndex.notifier).state;
    ref.refresh(selectedSortByIndex.notifier).state;
    ref.refresh(selectedColorIndex.notifier).state;
    ref.refresh(selectedSizeIndex.notifier).state;
    ref.refresh(selectedCategoryByIndex.notifier).state;
    ref.refresh(selectedBrandIndex.notifier).state;
    ref.read(productControllerProvider.notifier).getCategoryWiseProducts(
          productFilterModel: widget.productFilterModel.copyWith(
            rating: ref.read(selectedReviewIndex) != null
                ? reviewList[ref.read(selectedReviewIndex)!]
                : null,
            sortType: ref.read(selectedSortByIndex) != null
                ? getSortList(context)[ref.read(selectedSortByIndex)!]['key']
                : null,
            minPrice: null,
            maxPrice: null,
          ),
          isPagination: false,
        );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  final List<double> reviewList = [5.0, 4.0, 3.0, 2.0, 1.0];
  List<Map<String, dynamic>> getSortList(BuildContext context) {
    final List<Map<String, dynamic>> sortList = [
      {
        "title": S.of(context).priceHighToLow,
        "key": "high_to_low",
      },
      {
        "title": S.of(context).priceLowToHigh,
        "key": "low_to_high",
      },
      {
        "title": S.of(context).topSeller,
        "key": "top_selling",
      },
      {
        "title": S.of(context).newProduct,
        "key": "newest",
      },
    ];

    return sortList;
  }
}
