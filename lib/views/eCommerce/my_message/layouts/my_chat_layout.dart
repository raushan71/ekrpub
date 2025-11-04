import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/message/message_controller.dart';
import 'package:ekray/controllers/eCommerce/pusher/pusher_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/models/eCommerce/message_model/messages.dart';
import 'package:ekray/models/eCommerce/message_model/user.dart';
import 'package:ekray/models/eCommerce/shop_message_model/product.dart';
import 'package:ekray/models/eCommerce/shop_message_model/shop.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/my_message/components/product_card_widget.dart';

class MyChatLayout extends ConsumerStatefulWidget {
  final Shop shop;
  const MyChatLayout({super.key, required this.shop});

  @override
  ConsumerState<MyChatLayout> createState() => _MyChatLayoutState();
}

class _MyChatLayoutState extends ConsumerState<MyChatLayout> {
  final TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pusherControllerProvider.notifier).init();
      ref
          .read(getMessageControllerProvider.notifier)
          .getMessage(shopId: widget.shop.id ?? 0, isInitial: true);
      _scrollToBottom();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 20) {
        ref.read(getMessageControllerProvider.notifier).getMessage(
              shopId: widget.shop.id ?? 0,
            );
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      onPopInvokedWithResult: (result, t) {
        ref.read(getShopsControllerProvider.notifier).getShops();
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          titleSpacing: 0,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Divider(
              color: Colors.grey.shade100,
              height: 0.5.h,
            ),
          ),
          title: Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.shop.logo ?? '',
                    width: 40.w,
                    height: 40.h),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.shop.name ?? '',
                      style: AppTextStyle(context).title.copyWith(
                          fontSize: 16.sp,
                          color: colors(context).headingColor)),
                  Text(widget.shop.lastOnline == true ? "Active" : "Inactive",
                      style: AppTextStyle(context).bodyText.copyWith(
                          fontSize: 12.sp,
                          color: widget.shop.lastOnline == true
                              ? Colors.green
                              : Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        body: ref.watch(getMessageControllerProvider).when(
            loading: () => Center(
                  child: CircularProgressIndicator(),
                ),
            error: (error, stackTrace) => Center(
                  child: Text(
                    error.toString(),
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            data: (data) {
              // _scrollToBottom();
              final messages = data ?? [];
              return Column(
                children: [
                  // Messages
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Text(
                              "No messages yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 8.h),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final bool isMe = message.type == "user";
                              bool isFirstOfGroup = true;
                              if (index < messages.length - 1) {
                                final next = messages[index + 1];
                                isFirstOfGroup = message.type != next.type;
                              }
                              debugPrint(
                                  "product: ${message.product?.toJson()}");

                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.0.h),
                                child: _buildMessage(
                                  isMe: isMe,
                                  text: message.message ?? "",
                                  showAvatar: isFirstOfGroup,
                                  imageUrl: isMe
                                      ? message.user?.profilePhoto ?? ''
                                      : message.shop?.logo,
                                  product: message.product,
                                  dateTime: message.createdAt ?? DateTime.now(),
                                ),
                              );
                            },
                          ),
                  ),

                  // Input Field
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: messageController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Value cannot be empty";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Type a message",
                                hintStyle: TextStyle(fontSize: 14.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                      color: colors(context).primaryColor!),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 10.h),
                                suffixIcon:
                                    //  ref
                                    //         .watch(sendMessageControllerProvider)
                                    //     ? SizedBox(
                                    //         width: 20.w,
                                    //         height: 20.h,
                                    //         child: Padding(
                                    //           padding: const EdgeInsets.all(8.0),
                                    //           child: CircularProgressIndicator(),
                                    //         ))
                                    //     :
                                    IconButton(
                                  icon: SvgPicture.asset(
                                    Assets.svg.sendRight,
                                    // width: 20.w,
                                    // height: 20.h,
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final saveUser = await ref
                                          .read(hiveServiceProvider)
                                          .getUserInfo();
                                      UserMessage? users;
                                      if (saveUser != null) {
                                        users = UserMessage(
                                          name: saveUser.name,
                                          id: saveUser.id,
                                          profilePhoto: saveUser.profilePhoto,
                                        );
                                      }
                                      final messageText =
                                          messageController.text;
                                      final messageModel = Messages(
                                          type: "user",
                                          message: messageController.text,
                                          user: users);
                                      ref
                                          .read(getMessageControllerProvider
                                              .notifier)
                                          .addNewMessage(messageModel)
                                          .then((val) async {
                                        messageController.clear();
                                        await ref
                                            .read(sendMessageControllerProvider
                                                .notifier)
                                            .sendMessage(
                                              shopId: widget.shop.id ?? 0,
                                              message: messageText,
                                            );
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildMessage({
    required bool isMe,
    String? text,
    ProductMessage? product,
    required bool showAvatar,
    String? imageUrl,
    required DateTime dateTime,
  }) {
    debugPrint("productisnull: ${product?.thumbnail}");
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && showAvatar) ...[
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 8.0.w, top: 4.h),
              child: ClipOval(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: imageUrl ?? '',
                  width: 30.w,
                  height: 30.h,
                  errorWidget: (context, url, error) => SizedBox(),
                ),
              ),
            )
          ] else ...{
            SizedBox(width: 8.w),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SizedBox(
                width: 30.w,
                height: 30.h,
              ),
            ),
          },
          product != null && (text == null || text.isEmpty)
              ? ProductMessageCard(
                  product: product,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      constraints: BoxConstraints(maxWidth: 260.w),
                      decoration: BoxDecoration(
                        color: isMe
                            ? colors(context).primaryColor!
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        text ?? '',
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(GlobalFunction.formatMessageDateTime(dateTime),
                        style: AppTextStyle(context).bodyText.copyWith(
                            fontSize: 10.sp, color: EcommerceAppColor.gray)),
                  ],
                ),
          if (isMe && showAvatar) ...[
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(right: 16.0, top: 4.h),
              child: ClipOval(
                child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: imageUrl ?? '',
                    width: 30.w,
                    height: 30.h,
                    errorWidget: (context, url, error) => SizedBox()),
              ),
            )
          ] else ...{
            SizedBox(width: 8.w),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 30.w,
                height: 30.h,
              ),
            ),
          }
        ],
      ),
    );
  }
}
