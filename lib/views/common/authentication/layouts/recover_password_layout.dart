// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/animate_image.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_text_field.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/common/authentication/layouts/confirm_otp_layout.dart';

class RecoverPasswordLayout extends ConsumerStatefulWidget {
  final bool isPasswordRecover;
  const RecoverPasswordLayout({
    super.key,
    required this.isPasswordRecover,
  });

  @override
  ConsumerState<RecoverPasswordLayout> createState() =>
      _RecoverPasswordLayoutState();
}

class _RecoverPasswordLayoutState extends ConsumerState<RecoverPasswordLayout> {
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materModelData =
        ref.watch(masterControllerProvider.notifier).materModel.data;

    int? phoneMinLength = materModelData.phoneMinLength;
    int? phoneMaxLength = materModelData.phoneMaxLength;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedImage(
                          imageSize: 100.w,
                          imageWidget: SvgPicture.asset(
                            Assets.svg.recoverpPassword,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Gap(30.h),
                        if (widget.isPasswordRecover) ...[
                          Text(
                            S.of(context).recoverPassword,
                            style: AppTextStyle(context)
                                .title
                                .copyWith(fontWeight: FontWeight.bold),
                          )
                        ] else ...[
                          Text(
                            S.of(context).verification,
                            style: AppTextStyle(context)
                                .title
                                .copyWith(fontWeight: FontWeight.bold),
                          )
                        ],
                        Gap(16.h),
                        if (widget.isPasswordRecover) ...[
                          Text(
                            configData(ref: ref, context: context)['type'] ==
                                    'phone'
                                ? S.of(context).recoverPassDes
                                : S.of(context).enterThePhoneNumber,
                            textAlign: TextAlign.center,
                            style: AppTextStyle(context).bodyText.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ] else ...[
                          Text(
                            configData(ref: ref, context: context)['type'] ==
                                    'phone'
                                ? S.of(context).enterThePhoneNumber
                                : S.of(context).enterTheEmailAddress,
                            // 'Enter the phone number or Email that you used when register your account.  You will receive a OTP code.',
                            style: AppTextStyle(context).bodyText.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                        Gap(40.h),
                        CustomTextFormField(
                          name: configData(ref: ref, context: context)['title'],
                          hintText:
                              configData(ref: ref, context: context)['title'],
                          textInputType:
                              configData(ref: ref, context: context)['type'] ==
                                      'phone'
                                  ? TextInputType.phone
                                  : TextInputType.text,
                          controller: phoneController,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              configData(ref: ref, context: context)['type'] ==
                                      'phone'
                                  ? GlobalFunction.phoneValidator(
                                      value: value!,
                                      hintText: S.of(context).phoneNumber,
                                      context: context,
                                      minLength: phoneMinLength,
                                      maxLength: phoneMaxLength,
                                    )
                                  : GlobalFunction.emailValidator(
                                      value: value!,
                                      hintText: S.of(context).email,
                                      context: context,
                                    ),
                        ),
                        Gap(30.h),
                        CustomButton(
                          buttonText: S.of(context).sendOtp,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.nav.pushNamed(
                                Routes.confirmOTP,
                                arguments: ConfirmOTPScreenArguments(
                                  phoneNumber: phoneController.text,
                                  isPasswordRecover: widget.isPasswordRecover,
                                ),
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 26.h,
              left: 16.w,
              child: IconButton(
                onPressed: () {
                  context.nav.pop();
                },
                icon: Icon(
                  Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Map configData({required WidgetRef ref, required BuildContext context}) {
    if (widget.isPasswordRecover == true) {
      return {
        'title': ref
                    .read(masterControllerProvider.notifier)
                    .materModel
                    .data
                    .forgotOtpType ==
                'email'
            ? S.of(context).email
            : S.of(context).phone,
        'type': ref
                    .read(masterControllerProvider.notifier)
                    .materModel
                    .data
                    .forgotOtpType ==
                'email'
            ? 'email'
            : 'phone'
      };
    } else {
      return {
        'title': ref
                    .read(masterControllerProvider.notifier)
                    .materModel
                    .data
                    .registerOtpType ==
                'email'
            ? S.of(context).email
            : S.of(context).phone,
        'type': ref
                    .read(masterControllerProvider.notifier)
                    .materModel
                    .data
                    .registerOtpType ==
                'email'
            ? 'email'
            : 'phone'
      };
    }
  }
}
