import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/shop/shop_controller.dart';
import 'package:ekray/models/eCommerce/shop/shop.dart';
import 'package:ekray/views/eCommerce/shops/components/shop_card.dart';

class EcommerceShopsLayout extends ConsumerStatefulWidget {
  const EcommerceShopsLayout({super.key});

  @override
  ConsumerState<EcommerceShopsLayout> createState() =>
      _EcommerceShopsLayoutState();
}

class _EcommerceShopsLayoutState extends ConsumerState<EcommerceShopsLayout> {
  final ScrollController scrollController = ScrollController();

  int page = 1;
  final int perPage = 20;
  bool scrollLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(shopControllerProvider.notifier).shops.isEmpty) {
        _fetchShops(isPagination: false);
      }
    });
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        ref.read(shopControllerProvider.notifier).shops.length <
            ref.read(shopControllerProvider.notifier).total! &&
        !ref.read(shopControllerProvider)) {
      scrollLoading = true;
      page++;
      _fetchShops(isPagination: true);
    }
  }

  void _fetchShops({required bool isPagination}) {
    ref.read(shopControllerProvider.notifier).getShops(
          page: page,
          perPage: perPage,
          isPagination: isPagination,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shops'),
      ),
      backgroundColor: colors(context).accentColor,
      body: AnimationLimiter(
        child: Consumer(
          builder: (context, ref, child) {
            final shopProvider = ref.watch(shopControllerProvider);
            final shops = ref.watch(shopControllerProvider.notifier).shops;

            if (shopProvider && !scrollLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                page = 1;
                _fetchShops(isPagination: false);
              },
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final Shop shop = shops[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: ShopCard(shop: shop),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
