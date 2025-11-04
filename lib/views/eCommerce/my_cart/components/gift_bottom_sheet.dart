import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/custom_text_field.dart';
import 'package:ekray/components/ecommerce/custom_transparent_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/cart/cart_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/models/eCommerce/address/add_address.dart';
import 'package:ekray/models/eCommerce/cart/gift.dart';
import 'package:ekray/models/eCommerce/cart/gift_add_model.dart';
import 'package:ekray/models/eCommerce/cart/gift_item.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/checkout/components/add_address_button.dart';
import 'package:ekray/views/eCommerce/checkout/components/address_card.dart';
import 'package:ekray/views/eCommerce/checkout/components/address_modal_bottom_sheet.dart';

class GiftBottomSheet extends ConsumerStatefulWidget {
  final int productId;
  final Gift? gift;
  const GiftBottomSheet({
    super.key,
    required this.productId,
    required this.gift,
  });

  @override
  ConsumerState<GiftBottomSheet> createState() => _GiftBottomSheetState();
}

class _GiftBottomSheetState extends ConsumerState<GiftBottomSheet> {
  static final TextEditingController giftNoteController =
      TextEditingController();
  static final TextEditingController recipientController =
      TextEditingController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _handleExistingData(),
    );
    super.initState();
  }

  void _handleExistingData() {
    if (widget.gift != null) {
      ref.read(selectedGiftIdProvider.notifier).state = widget.gift?.id;
      ref.read(selectedGiftDeliveryAddress.notifier).state = _convertAddess();
      recipientController.text = widget.gift?.receiverName ?? '';
      giftNoteController.text = widget.gift?.note ?? '';
    }
  }

  AddAddress? _convertAddess() {
    if (widget.gift?.address != null) {
      return AddAddress.fromMap(widget.gift!.address!.toJson());
    }
    return null;
  }

  void _handleAddGift({
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    final GiftAddModel giftAddModel = GiftAddModel(
        productId: widget.productId,
        giftId: ref.read(selectedGiftIdProvider)!,
        receiverName: recipientController.text,
        note: giftNoteController.text,
        addressId: ref.read(selectedGiftDeliveryAddress)?.addressId);
    await ref
        .read(cartController.notifier)
        .addGiftToCart(
          giftAddModel: giftAddModel,
        )
        .then((value) {
      _cleanAll();
      context.nav.pop();
    });
  }

  void _handleRemoveTap() async {
    await ref
        .read(cartController.notifier)
        .deleteGiftFromCart(
          giftId: widget.gift!.cartId,
        )
        .then((value) {
      _cleanAll();
      context.nav.pop();
    });
  }

  void _cleanAll() {
    ref.refresh(selectedGiftIdProvider.notifier).state;
    ref.refresh(selectedGiftDeliveryAddress.notifier).state;
    recipientController.clear();
    giftNoteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GlobalFunction.getContainerColor(),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeader(context),
          Gap(14.h),
          buildGiftList(),
          Gap(16.h),
          buildTextFieldWidget(
            controller: recipientController,
            name: 'Recipient Name',
            hintText: 'Recipient Name',
          ),
          Gap(16.h),
          buildTextFieldWidget(
            controller: giftNoteController,
            name: 'Gift Note',
            hintText: 'Gift Note',
          ),
          Gap(32.h),
          buildAddressSection(),
          Gap(16.h),
          if (widget.gift == null) ...[
            buildAddGiftButton(context),
          ] else ...[
            _buildUpdateRemoveWidget(context),
          ]
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Gift Section',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (mounted) _cleanAll();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget buildGiftList() {
    return Consumer(builder: (context, ref, _) {
      final gifts = ref.watch(cartController.notifier).giftItems;
      return SizedBox(
        height: 110.h,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: gifts.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) =>
              buildGiftItem(item: gifts[index], index: index),
        ),
      );
    });
  }

  Widget buildTextFieldWidget(
      {required TextEditingController controller,
      required String name,
      required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: AppTextStyle(GlobalFunction.navigatorKey.currentContext!)
                  .bodyText
                  .copyWith(fontSize: 16.sp, fontWeight: FontWeight.w400),
            ),
            Gap(5.w),
            Text(
              "( Optional )",
              style: AppTextStyle(GlobalFunction.navigatorKey.currentContext!)
                  .bodyTextSmall
                  .copyWith(fontSize: 10.sp),
            ),
          ],
        ),
        Gap(4.h),
        CustomTextFormField(
          showName: false,
          name: name,
          textInputType: TextInputType.text,
          controller: controller,
          textInputAction: TextInputAction.done,
          validator: (value) => null,
          hintText: hintText,
        ),
      ],
    );
  }

  Widget buildAddressSection() {
    return Consumer(builder: (context, ref, _) {
      final selectedAddress = ref.watch(selectedGiftDeliveryAddress);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (selectedAddress != null) ...[
                GestureDetector(
                  onTap: () => showAddressModalBottomSheet(context),
                  child: Text(
                    'Change',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: colors(context).primaryColor,
                        ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: 180.w,
                  child: AddAddressButton(
                    onTap: () => showAddressModalBottomSheet(context),
                  ),
                ),
              ],
            ],
          ),
          Gap(16.h),
          if (selectedAddress != null)
            Stack(
              children: [
                AddressCard(address: selectedAddress),
                Positioned(
                  top: 10.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: () => ref.refresh(selectedGiftDeliveryAddress),
                    child: SvgPicture.asset(Assets.svg.trash),
                  ),
                )
              ],
            ),
          Divider(
            color:
                colors(GlobalFunction.navigatorKey.currentContext).accentColor,
          ),
        ],
      );
    });
  }

  void showAddressModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      context: context,
      builder: (context) => const AddressModalBottomSheet(
        isGift: true,
      ),
    );
  }

  Widget buildGiftItem({required ShopGift item, required int index}) {
    return Consumer(builder: (context, ref, _) {
      final selectedId = ref.watch(selectedGiftIdProvider);

      return InkWell(
        onTap: () => ref.read(selectedGiftIdProvider.notifier).state = item.id,
        child: Container(
          margin: EdgeInsets.only(right: 6.w),
          width: MediaQuery.of(context).size.width / 4.6,
          decoration: BoxDecoration(
            border: Border.all(
              color: item.id == selectedId
                  ? EcommerceAppColor.green
                  : colors(GlobalFunction.navigatorKey.currentContext)
                      .accentColor!,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.all(6.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 6,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color:
                            colors(GlobalFunction.navigatorKey.currentContext)
                                .accentColor,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: item.thumbnail,
                        errorWidget: (context, url, error) => const SizedBox(),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          color: colors(context).primaryColor,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Text(
                          item.price == 0 ? 'Free' : "\$${item.price}",
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: EcommerceAppColor.white,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(5.h),
              Flexible(
                flex: 2,
                child: Center(
                  child: Text(
                    item.name,
                    style: AppTextStyle(
                            GlobalFunction.navigatorKey.currentContext!)
                        .bodyTextSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildAddGiftButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ref.watch(cartController).isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomTransparentButton(
                buttonText: 'Add Gift',
                onTap: () {
                  if (ref.read(selectedGiftIdProvider) != null) {
                    _handleAddGift(ref: ref, context: context);
                  }
                },
                borderColor: colors(context).primaryColor,
                buttonTextColor: colors(context).primaryColor,
              );
      },
    );
  }

  Widget _buildUpdateRemoveWidget(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return ref.watch(cartController).isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Row(
              children: [
                Flexible(
                  flex: 1,
                  child: CustomTransparentButton(
                    buttonText: 'Remove',
                    onTap: () => _handleRemoveTap(),
                    borderColor: colors(context).accentColor,
                    buttonTextColor: colors(context).primaryColor,
                    buttonColor: colors(context).accentColor,
                  ),
                ),
                Gap(10.w),
                Flexible(
                  flex: 1,
                  child: CustomTransparentButton(
                    buttonText: 'Update',
                    onTap: () {
                      if (ref.read(selectedGiftIdProvider) != null) {
                        _handleAddGift(ref: ref, context: context);
                      }
                    },
                    borderColor: colors(context).primaryColor,
                    buttonTextColor: colors(context).primaryColor,
                  ),
                ),
              ],
            );
    });
  }
}

final selectedGiftIdProvider = StateProvider<int?>((ref) => null);
