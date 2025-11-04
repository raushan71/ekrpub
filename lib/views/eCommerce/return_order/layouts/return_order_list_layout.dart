import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/return_policy/return_policy_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/views/eCommerce/return_order/componants/return_order_card.dart';

class ReturnOrderListLayout extends ConsumerStatefulWidget {
  const ReturnOrderListLayout({super.key});

  @override
  ConsumerState<ReturnOrderListLayout> createState() =>
      _ReturnOrderListLayoutState();
}

class _ReturnOrderListLayoutState extends ConsumerState<ReturnOrderListLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(returnOrderListProvider.notifier).fetchReturnOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).accentColor,
      appBar: AppBar(
        title: Text(S.of(context).returnOrders),
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(3.h),
          _buildOrderListWidget(),
        ],
      ),
    );
  }

  Widget _buildOrderListWidget() {
    final returnOrders = ref.watch(returnOrderListProvider);

    return Expanded(
      child: returnOrders.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Text(
            "Error: $err",
            style: AppTextStyle(context).subTitle,
          ),
        ),
        data: (data) {
          if (data.data?.returnOrders?.isEmpty ?? true) {
            return Center(
              child: Text(
                'Order not found!',
                style: AppTextStyle(context).subTitle,
              ),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              itemCount: data.data?.returnOrders?.length ?? 0,
              itemBuilder: (context, index) {
                final order = data.data?.returnOrders?[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.h,
                    child: FadeInAnimation(
                      child: ReturnOrderCard(order: order),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
