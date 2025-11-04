import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ekray/components/ecommerce/custom_transparent_button.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/address/address_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/address/add_address.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/checkout/components/address_card.dart';

class ManageAddressLayout extends ConsumerStatefulWidget {
  const ManageAddressLayout({super.key});

  @override
  ConsumerState<ManageAddressLayout> createState() =>
      _ManageAddressLayoutState();
}

class _ManageAddressLayoutState extends ConsumerState<ManageAddressLayout> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(addressControllerProvider.notifier).getAddress();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors(context).accentColor,
        appBar: AppBar(
          title: Text(S.of(context).manageAddress),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        bottomNavigationBar: _buildBottomNavigationWidget(context: context),
        body: Column(
          children: [
            Divider(
              thickness: 10,
              color: colors(context).accentColor,
            ),
            Expanded(
              child: ref.watch(addressControllerProvider)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: ref
                          .watch(addressControllerProvider.notifier)
                          .addressList
                          .length,
                      itemBuilder: ((context, index) {
                        final AddAddress address = ref
                            .watch(addressControllerProvider.notifier)
                            .addressList[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 5.h),
                          child: AddressCard(
                            cardColor: GlobalFunction.getContainerColor(),
                            showEditButton: true,
                            onTap: () {
                              // context.nav.pushNamed(
                              //     Routes.getAddUpdateAddressViewRouteName(
                              //         AppConstants.appServiceName),
                              //     arguments: address);
                            },
                            editTap: () {
                              context.nav.pushNamed(
                                  Routes.getAddUpdateAddressViewRouteName(
                                      AppConstants.appServiceName),
                                  arguments: address);
                            },
                            address: address,
                          ),
                        );
                      }),
                    ),
            ),
          ],
        ));
  }

  Widget _buildBottomNavigationWidget({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14),
      height: 86.h,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: GlobalFunction.getContainerColor(),
            width: 2.0,
          ),
        ),
      ),
      child: CustomTransparentButton(
        buttonText: S.of(context).addNew,
        onTap: () {
          context.nav.pushNamed(Routes.getAddUpdateAddressViewRouteName(
              AppConstants.appServiceName));
        },
        borderColor: colors(context).primaryColor,
        buttonTextColor: colors(context).primaryColor,
      ),
    );
  }
}
