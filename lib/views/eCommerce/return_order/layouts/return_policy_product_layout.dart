import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_text_field.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/order/order_controller.dart';
import 'package:ekray/controllers/eCommerce/return_policy/return_policy_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/return_policy/return_order_submit_model.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/eCommerce/order_details/components/order_product_card.dart';
import 'package:ekray/views/eCommerce/return_order/componants/return_success_dialouge.dart';

class ReturnPolicyProductLayout extends ConsumerStatefulWidget {
  final int orderId;

  const ReturnPolicyProductLayout({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<ReturnPolicyProductLayout> createState() =>
      _ReturnPolicyLayoutState();
}

class _ReturnPolicyLayoutState
    extends ConsumerState<ReturnPolicyProductLayout> {
  final _formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final collectionLocationController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (result, t) {
        ref.invalidate(selectedReturnProductProvider);
      },
      child: Scaffold(
        backgroundColor: colors(context).accentColor,
        appBar: AppBar(
          title: Text("Return Your Product"),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: GlobalFunction.getContainerColor(),
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: ref.watch(returnSubmitControllerProvider)
              ? SizedBox(
                  height: 60.w,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ))
              : CustomButton(
                  buttonText: S.of(context).next,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate()) {
                      final selectedProducts =
                          ref.watch(selectedReturnProductProvider);
                      final submitReturnModel = ReturnOrderSubmitModel(
                        orderId: widget.orderId,
                        bankAccountNo: accountController.text,
                        retrunAddress: collectionLocationController.text,
                        reason: reasonController.text,
                        productIds: selectedProducts.map((e) => e.id).toList(),
                      );

                      ref
                          .read(returnSubmitControllerProvider.notifier)
                          .submitReturnProduct(
                            returnOrder: submitReturnModel,
                          )
                          .then(
                        (response) {
                          if (response.isSuccess) {
                            ref.invalidate(orderDetailsControllerProvider);
                            ref.invalidate(selectedReturnProductProvider);
                            ref
                                .read(selectedReturnProductProvider.notifier)
                                .clearSelection();
                            Future(() async {
                              await ref
                                  .read(orderControllerProvider.notifier)
                                  .getOrders(
                                    orderStatus: null,
                                    page: 1,
                                    perPage: 20,
                                    isPagination: false,
                                  );

                              debugPrint("myorderapicall Done");
                            });
                            if (context.mounted) {
                              showReturnSuccessDialog(
                                context: context,
                                message: S.of(context).orderReturnSuccess,
                                orderId: widget.orderId.toString(),
                                returnAddress:
                                    collectionLocationController.text,
                                onGoToOrders: () {
                                  context.nav.popUntil(
                                    ModalRoute.withName(
                                      Routes.getMyOrderViewRouteName(
                                          AppConstants.appServiceName),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      );
                    } else {
                      GlobalFunction.showCustomSnackbar(
                        message: "Please fill all fields",
                        isSuccess: false,
                      );
                    }
                  },
                ),
        ),
        body: SingleChildScrollView(
          // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(8.h),

                /// Return Items List
                _buildServiceItemsWidget(
                  context,

                  false, // showCheckbox
                  null,
                  false, // showButton
                ),

                Gap(8.h),

                /// Account Number
                Container(
                  decoration: BoxDecoration(
                    color: GlobalFunction.getContainerColor(),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Column(
                    children: [
                      CustomTextFormField(
                        name: S.of(context).accountNumber,
                        hintText: S.of(context).accountNo,
                        textInputType: TextInputType.number,
                        controller: accountController,
                        fillColor: Colors.transparent,
                        textInputAction: TextInputAction.next,
                        validator: (value) => GlobalFunction.commonValidator(
                          value: value!,
                          hintText: S.of(context).accountNumber,
                          context: context,
                        ),
                      ),
                      Gap(16.h),
                      CustomTextFormField(
                        name: S.of(context).collectionLocation,
                        hintText: S.of(context).location,
                        textInputType: TextInputType.text,
                        controller: collectionLocationController,
                        textInputAction: TextInputAction.next,
                        fillColor: Colors.transparent,
                        validator: (value) => GlobalFunction.commonValidator(
                          value: value!,
                          hintText: S.of(context).collectionLocation,
                          context: context,
                        ),
                      ),
                      Gap(16.h),
                      CustomTextFormField(
                        name: S.of(context).reasonForReturn,
                        secondTitle: "(View Our Return Policy)",
                        hintText: S.of(context).reason,
                        textInputType: TextInputType.multiline,
                        controller: reasonController,
                        textInputAction: TextInputAction.newline,
                        fillColor: Colors.transparent,
                        maxLines: 3,
                        minLines: 3,
                        validator: (value) => GlobalFunction.commonValidator(
                          value: value!,
                          hintText: S.of(context).reasonForReturn,
                          context: context,
                        ),
                        secondTitleOnTap: () {
                          context.nav.pushNamed(Routes.refundPolicyView);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItemsWidget(
    BuildContext context,
    bool? showCheckbox,
    Function(int)? onTap,
    bool? showButton,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedProducts = ref.watch(selectedReturnProductProvider);
        return Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          color: GlobalFunction.getContainerColor(),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${S.of(context).retrunItem} (${selectedProducts.length})',
                style: AppTextStyle(context).subTitle.copyWith(fontSize: 16.sp),
              ),
              Gap(14.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: onTap == null
                      ? null
                      : () {
                          debugPrint("tap");

                          onTap(index);
                        },
                  child: OrderProductCard(
                    addPadding: false,
                    padding: EdgeInsets.only(top: 5.h, bottom: 10.h),
                    orderId: widget.orderId,
                    product: selectedProducts[index],
                    orderStatus: "",
                    index: index,
                    showCheckbox: showCheckbox,
                    isSelected:
                        selectedProducts.contains(selectedProducts[index]),
                  ),
                ),
              ),
              Gap(30.h),
            ],
          ),
        );
      },
    );
  }
}
