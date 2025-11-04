import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ekray/components/ecommerce/custom_transparent_button.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/controllers/eCommerce/address/address_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/address/add_address.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/checkout/components/address_card.dart';

class AddressModalBottomSheet extends ConsumerStatefulWidget {
  final bool? isGift;
  const AddressModalBottomSheet({super.key, this.isGift});

  @override
  ConsumerState<AddressModalBottomSheet> createState() =>
      _AddressModalBottomSheetState();
}

class _AddressModalBottomSheetState
    extends ConsumerState<AddressModalBottomSheet> {
  final EdgeInsets _edgeInsets =
      EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 20.h, top: 60.h);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressControllerProvider.notifier).getAddress();
    });
  }

  void _handleEditTap(BuildContext context, AddAddress address) {
    context.nav.popAndPushNamed(
      Routes.getAddUpdateAddressViewRouteName(AppConstants.appServiceName),
      arguments: address,
    );
  }

  void _handleTap(AddAddress address) {
    if (widget.isGift == true) {
      ref.read(selectedGiftDeliveryAddress.notifier).state = address;
    } else {
      ref.read(selectedDeliveryAddress.notifier).state = address;
    }
    context.nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final addressList =
        ref.watch(addressControllerProvider.notifier).addressList;
    final isLoading = ref.watch(addressControllerProvider);

    return Stack(
      children: [
        _buildAddressList(context, addressList, isLoading),
        _buildHeader(context),
        _buildAddNewButton(context),
      ],
    );
  }

  Widget _buildAddressList(
      BuildContext context, List<AddAddress> addressList, bool isLoading) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.8,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: _edgeInsets,
              child: Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 60.h),
                  itemCount: addressList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final address = addressList[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: AddressCard(
                        editTap: () => _handleEditTap(context, address),
                        onTap: () => _handleTap(address),
                        address: address,
                        showEditButton: true,
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      left: 20.w,
      right: 12.w,
      top: 5.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).savedAddress,
            style: AppTextStyle(context).subTitle,
          ),
          IconButton(
            onPressed: () {
              context.nav.pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: Container(
        padding: EdgeInsets.all(8),
        color: GlobalFunction.getContainerColor(),
        child: CustomTransparentButton(
          buttonText: S.of(context).addNew,
          onTap: () {
            context.nav.popAndPushNamed(
              Routes.getAddUpdateAddressViewRouteName(
                  AppConstants.appServiceName),
            );
          },
          borderColor: EcommerceAppColor.primary,
          buttonTextColor: EcommerceAppColor.primary,
        ),
      ),
    );
  }
}
