// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/confirmation_dialog.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/controllers/eCommerce/message/message_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/product/product_details.dart';
import 'package:ekray/models/eCommerce/shop_message_model/shop.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';

class ShopInformation extends StatelessWidget {
  final ProductDetails productDetails;
  const ShopInformation({
    super.key,
    required this.productDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: GlobalFunction.getContainerColor(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 5,
                  child: SizedBox(
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: CachedNetworkImage(
                              imageUrl: productDetails.product.shop.logo,
                              width: 24.w,
                              height: 24.h,
                            ),
                          ),
                        ),
                        Gap(10.w),
                        Flexible(
                          flex: 4,
                          child: Text(
                            productDetails.product.shop.name,
                            style: AppTextStyle(context)
                                .bodyText
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (ref.read(hiveServiceProvider).userIsLoggedIn()) {
                      final saveUser =
                          await ref.read(hiveServiceProvider).getUserInfo();

                      final shop = Shop(
                        id: productDetails.product.shop.id,
                        name: productDetails.product.shop.name,
                        logo: productDetails.product.shop.logo,
                      );

                      ref
                          .read(storeMessageControllerProvider.notifier)
                          .storeMessage(
                            shopId: productDetails.product.shop.id,
                            userId: saveUser!.id!,
                            productId: productDetails.product.id,
                          );
                      context.nav.pushNamed(
                        Routes.getChatViewRouteName(
                            AppConstants.appServiceName),
                        arguments: shop,
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => ConfirmationDialog(
                                title: 'You can\'t send message without login!',
                                confirmButtonText: 'Login',
                                onPressed: () {
                                  context.nav.pushNamedAndRemoveUntil(
                                      Routes.login, (route) => false);
                                },
                              ));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: colors(context).primaryColor!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SvgPicture.asset(
                      Assets.svg.message,
                      color: colors(context).primaryColor,
                      // width: 16.w,
                      // height: 16.h,
                    ),
                  ),
                ),
              ],
            ),
            Consumer(builder: (context, ref, _) {
              return Visibility(
                visible: ref
                    .read(masterControllerProvider.notifier)
                    .materModel
                    .data
                    .isMultiVendor,
                child: GestureDetector(
                  onTap: () {
                    context.nav.pushNamed(
                      Routes.getShopViewRouteName(AppConstants.appServiceName),
                      arguments: productDetails.product.shop.id,
                    );
                  },
                  child: Text(
                    S.of(context).vistiStore,
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: colors(context).primaryColor,
                          decoration: TextDecoration.underline,
                          decorationColor: colors(context).primaryColor,
                        ),
                  ),
                ),
              );
            }),
            Gap(10.h),
            Divider(
              color: colors(context).accentColor,
            ),
            Gap(10.h),
            _buildShopInfoRow(
              icon: Assets.svg.clock,
              text: S.of(context).estdTime,
              value: productDetails.product.shop.estimatedDeliveryTime,
              context: context,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildShopInfoRow(
      {required String icon,
      required String text,
      required String value,
      required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          child: Row(
            children: [
              SvgPicture.asset(icon),
              Gap(10.w),
              Text(
                text,
                style: AppTextStyle(context).bodyTextSmall,
              )
            ],
          ),
        ),
        Text(
          value,
          style: AppTextStyle(context).bodyTextSmall,
        )
      ],
    );
  }
}
