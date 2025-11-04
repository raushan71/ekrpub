import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/controllers/eCommerce/flash_sales/flash_sales_controller.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/views/eCommerce/home/components/product_card.dart';

class FlashSaleDetailsLayout extends ConsumerStatefulWidget {
  String title;
  FlashSaleDetailsLayout({super.key, required this.title});

  @override
  _FlashSaleDetailsLayoutState createState() => _FlashSaleDetailsLayoutState();
}

class _FlashSaleDetailsLayoutState
    extends ConsumerState<FlashSaleDetailsLayout> {
  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? 3 : 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: AppTextStyle(context).appBarText),
      ),
      body: ref.watch(flashSaleDetailsControllerProvider)
          ? Center(child: CircularProgressIndicator())
          : ref
                  .watch(flashSaleDetailsControllerProvider.notifier)
                  .products
                  .isEmpty
              ? Center(child: Text("No Product Available"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                        ).copyWith(bottom: 80.h),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _calculateCrossAxisCount(context),
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.66,
                        ),
                        itemCount: ref
                            .watch(flashSaleDetailsControllerProvider.notifier)
                            .products
                            .length,
                        itemBuilder: (context, index) {
                          final products = ref
                              .watch(
                                  flashSaleDetailsControllerProvider.notifier)
                              .products;
                          return ProductCard(
                            product: products[index],
                            onTap: () => context.nav.pushNamed(
                              Routes.getProductDetailsRouteName(
                                  AppConstants.appServiceName),
                              arguments: products[index].id,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
    );
  }
}
