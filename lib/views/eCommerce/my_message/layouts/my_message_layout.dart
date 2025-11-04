import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/custom_search_field.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/message/message_controller.dart';
import 'package:ekray/controllers/eCommerce/pusher/pusher_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';

class MyMessageLayout extends ConsumerStatefulWidget {
  const MyMessageLayout({super.key});

  static TextEditingController nameController = TextEditingController();
  static TextEditingController phoneController = TextEditingController();
  static TextEditingController emailController = TextEditingController();

  @override
  ConsumerState<MyMessageLayout> createState() => _MyMessageLayoutState();
}

class _MyMessageLayoutState extends ConsumerState<MyMessageLayout> {
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pusherControllerProvider.notifier).init();
      ref.read(getShopsControllerProvider.notifier).getShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.refresh(getTotalUnreadMessagesControllerProvider);
      },
      child: Scaffold(
        //  backgroundColor: colors(context).accentColor,
        appBar: AppBar(
          title: Text(S.of(context).message),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSearchField(
                  name: 'search',
                  hintText: S.of(context).seachSeller,
                  textInputType: TextInputType.text,
                  controller: messageController,
                  widget: Container(
                    margin: EdgeInsets.all(10.sp),
                    child: SvgPicture.asset(Assets.svg.searchHome),
                  ),
                  onChanged: (value) async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    ref
                        .read(getShopsControllerProvider.notifier)
                        .getShops(search: value);
                  },
                ),
                Gap(8.h),
                ref.watch(getShopsControllerProvider).when(
                    data: (data) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data?.data?.data?.length ?? 0,
                        separatorBuilder: (context, index) => Gap(
                          1.h,
                          color: Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final message = data?.data?.data?[index];
                          // PusherService()
                          //     .subscribeToUserChannel(message?.shop?.id ?? 0);
                          return ListTile(
                            titleAlignment: ListTileTitleAlignment.top,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: message?.unreadMessageShop == 0
                                ? Colors.transparent
                                : colors(context)
                                    .primaryColor!
                                    .withValues(alpha: 0.2),
                            onTap: () {
                              context.nav.pushNamed(
                                  Routes.getChatViewRouteName(
                                      AppConstants.appServiceName),
                                  arguments: message?.shop);
                            },
                            leading: CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: 50.w,
                              height: 50.h,
                              imageUrl: message?.shop?.logo ?? "",
                              errorWidget: (context, url, error) {
                                return Icon(
                                  Icons.person,
                                );
                              },
                            ),
                            title: Text(
                              message?.shop?.name ?? "",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            subtitle: Text(
                              message?.lastMessage ?? "",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: colors(context).hintTextColor,
                                  ),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                message?.lastMessageTime ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: EcommerceAppColor.gray),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    error: (error, stk) =>
                        Center(child: Text(error.toString())),
                    loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum OrderStatus {
  all,
  pending,
  confirm,
  processing,
  onTheWay,
  delivered,
  canceled,
}
