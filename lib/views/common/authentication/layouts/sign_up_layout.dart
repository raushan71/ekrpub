import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/app_logo.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_text_field.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/country_controller.dart';
import 'package:ekray/controllers/eCommerce/authentication/authentication_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/common/all_country_model/country.dart';
import 'package:ekray/models/eCommerce/authentication/sign_up.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';

import '../../../../config/app_constants.dart';
import '../../../../controllers/common/master_controller.dart';

class SignUpLayout extends StatefulWidget {
  const SignUpLayout({super.key});

  @override
  State<SignUpLayout> createState() => _SignUpLayoutState();
}

class _SignUpLayoutState extends State<SignUpLayout> {
  final List<TextEditingController> controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> fNodes = List.generate(4, (i) => FocusNode());

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  bool isChecked = false;
  Country? selectedCountry;
  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }
    super.dispose();
  }

  String? countryCode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomNavigationBar: SizedBox(
          height: 60.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).alreadyHaveAnAccount,
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Gap(5.w),
                GestureDetector(
                  onTap: () => context.nav.pop(),
                  child: Text(
                    S.of(context).login,
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors(context).primaryColor,
                        ),
                  ),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(context),
                buildBody(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: colors(context).accentColor ?? EcommerceAppColor.offWhite,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(
              0,
              2,
            ),
          )
        ],
      ),
      child: const Center(
        child: AppLogo(
          isAnimation: true,
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final materModelData =
          ref.watch(masterControllerProvider.notifier).materModel.data;
      final isPhoneRequired = materModelData.phoneRequired;
      int? phoneMinLength = materModelData.phoneMinLength;
      int? phoneMaxLength = materModelData.phoneMaxLength;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w)
            .copyWith(bottom: 20.h, top: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).signUp,
              style: AppTextStyle(context)
                  .title
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Gap(20.h),
            Text(
              S.of(context).signUpToContinue,
              style: AppTextStyle(context).bodyText.copyWith(
                  color: colors(context).bodyTextSmallColor,
                  fontWeight: FontWeight.w500),
            ),
            Gap(20.h),
            CustomTextFormField(
              name: S.of(context).fullName,
              hintText: S.of(context).enFullName,
              textInputType: TextInputType.text,
              controller: controllers[0],
              focusNode: fNodes[0],
              textInputAction: TextInputAction.next,
              validator: (value) => GlobalFunction.commonValidator(
                value: value!,
                hintText: S.of(context).fullName,
                context: context,
              ),
            ),
            Gap(20.h),
            Text(
              S.of(context).country,
              style: AppTextStyle(context)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            Gap(12.h),
            Consumer(builder: (context, ref, child) {
              return ref.watch(countryListControllerProvider).when(
                  loading: () =>
                      Center(child: const CircularProgressIndicator()),
                  error: (error, stackTrace) => Text(error.toString()),
                  data: (data) {
                    final countryList = data.data?.countries ?? [];
                    return FormBuilderDropdown(
                      name: 'country',
                      validator: (value) {
                        if (value == null) {
                          return S.of(context).selectCountry;
                        }
                        return null;
                      },
                      hint: Text(S.of(context).selectCountry),
                      onChanged: (value) {
                        setState(() {
                          selectedCountry = value as Country;
                          countryCode = selectedCountry?.phoneCode;
                        });
                        debugPrint("Selected country: $selectedCountry");
                      },
                      items: List.generate(countryList.length, (index) {
                        final country = countryList[index];
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country.name ?? ''),
                        );
                      }),
                      decoration: InputDecoration(
                        hintStyle: AppTextStyle(context).bodyText.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colors(context).hintTextColor,
                            ),
                        filled: true,
                        fillColor: colors(context).accentColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: colors(context).hintTextColor ??
                                EcommerceAppColor.lightGray,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: colors(context).accentColor ??
                                EcommerceAppColor.offWhite,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colors(context).primaryColor ??
                                EcommerceAppColor.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colors(context).errorColor ??
                                EcommerceAppColor.red,
                          ),
                        ),
                      ),
                    );
                  });
            }),
            Gap(20.h),
            Stack(
              children: [
                Text(
                  'Phone Number',
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.w),
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border:
                                Border.all(color: colors(context).accentColor!),
                          ),
                          child: Center(
                            child: Text(
                              countryCode ?? '+00',
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Gap(10.w),
                    Flexible(
                      flex: 7,
                      child: CustomTextFormField(
                        name: '',
                        hintText: S.of(context).enterPhoneNumber,
                        textInputType: TextInputType.phone,
                        controller: controllers[1],
                        focusNode: fNodes[1],
                        textInputAction: TextInputAction.next,
                        validator: (value) => GlobalFunction.phoneValidator(
                          value: value!,
                          hintText: S.of(context).phoneNumber,
                          context: context,
                          minLength: phoneMinLength,
                          maxLength: phoneMaxLength,
                          isPhoneRequired: isPhoneRequired,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Gap(20.h),
            CustomTextFormField(
              name: 'Email Address',
              hintText: S.of(context).email,
              textInputType: TextInputType.text,
              controller: controllers[2],
              focusNode: fNodes[2],
              textInputAction: TextInputAction.next,
              validator: (value) => GlobalFunction.emailValidator(
                value: value!,
                hintText: S.of(context).email,
                context: context,
              ),
            ),
            Gap(20.h),
            Consumer(builder: (context, ref, _) {
              return CustomTextFormField(
                name: S.of(context).password,
                hintText: S.of(context).createNewPass,
                textInputType: TextInputType.text,
                focusNode: fNodes[3],
                controller: controllers[3],
                textInputAction: TextInputAction.done,
                obscureText: ref.watch(obscureText1),
                widget: IconButton(
                  splashColor: Colors.transparent,
                  onPressed: () {
                    ref.read(obscureText1.notifier).state =
                        !ref.read(obscureText1);
                  },
                  icon: Icon(
                    !ref.watch(obscureText1)
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: colors(context).hintTextColor,
                  ),
                ),
                validator: (value) => GlobalFunction.passwordValidator(
                  value: value!,
                  hintText: S.of(context).password,
                  context: context,
                ),
              );
            }),
            Gap(24.h),
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 28.w),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "By tapping the ‘Sign up’ button, you agree with our ",
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                        ),
                        TextSpan(
                          text: 'Terms & Condition',
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w400,
                                color: colors(context).primaryColor,
                                fontSize: 14.sp,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.nav
                                .pushNamed(Routes.termsAndConditionsView),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy ',
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w400,
                                color: colors(context).primaryColor,
                                fontSize: 14.sp,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                context.nav.pushNamed(Routes.privacyPolicyView),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: -14,
                  top: -5,
                  child: Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      }),
                )
              ],
            ),
            Gap(30.h),
            Hero(
              tag: 'otp',
              child: Consumer(builder: (context, ref, _) {
                return ref.watch(authControllerProvider)
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        buttonText: S.of(context).signUp,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (formKey.currentState!.validate()) {
                            if (!isChecked) {
                              GlobalFunction.showCustomSnackbar(
                                message:
                                    'Please accept the terms and conditions!',
                                isSuccess: false,
                              );
                              return;
                            }

                            final email = controllers[2].text.trim();
                            final password = controllers[3].text;
                            final name = controllers[0].text.trim();
                            final phone = controllers[1].text.trim();

                            // Check if email is provided and use Firebase Auth
                            if (email.isNotEmpty && email.contains('@')) {
                              // Use Firebase Auth email/password registration
                              ref
                                  .read(authControllerProvider.notifier)
                                  .signUpWithEmailPassword(
                                    email: email,
                                    password: password,
                                    name: name,
                                    phone: phone.isNotEmpty ? phone : null,
                                  )
                                  .then((response) {
                                if (response.isSuccess) {
                                  _navigate(ref: ref);
                                } else {
                                  GlobalFunction.showCustomSnackbar(
                                    message: response.message,
                                    isSuccess: false,
                                  );
                                }
                              });
                            } else {
                              // Use existing phone/email registration
                              final SingUp singUpInfo = SingUp(
                                name: name,
                                phone: phone,
                                password: password,
                                country: selectedCountry?.name ?? "",
                                phoneCode: countryCode ?? '',
                                email: email,
                              );
                              ref
                                  .read(authControllerProvider.notifier)
                                  .singUp(singUpInfo: singUpInfo)
                                  .then((response) {
                                if (response.isSuccess) {
                                  _navigate(ref: ref);
                                } else {
                                  GlobalFunction.showCustomSnackbar(
                                    message: response.message,
                                    isSuccess: false,
                                  );
                                }
                              });
                            }
                          }
                        },
                      );
              }),
            ),
            Gap(20.h),
            // Divider with "OR"
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: colors(context).hintTextColor ?? EcommerceAppColor.lightGray,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'OR',
                    style: AppTextStyle(context).bodyText.copyWith(
                          color: colors(context).hintTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: colors(context).hintTextColor ?? EcommerceAppColor.lightGray,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            Gap(20.h),
            // Google Sign-In Button
            Consumer(builder: (context, ref, _) {
              return ref.watch(authControllerProvider)
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (!isChecked) {
                            GlobalFunction.showCustomSnackbar(
                              message: 'Please accept the terms and conditions!',
                              isSuccess: false,
                            );
                            return;
                          }
                          ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle()
                              .then((response) {
                            if (response.isSuccess) {
                              _navigate(ref: ref);
                            } else {
                              GlobalFunction.showCustomSnackbar(
                                message: response.message,
                                isSuccess: false,
                              );
                            }
                          });
                        },
                        icon: Image.asset(
                          'assets/png/google_logo.png',
                          width: 24.w,
                          height: 24.h,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.login,
                              size: 24.sp,
                              color: Colors.grey[700],
                            );
                          },
                        ),
                        label: Text(
                          'Continue with Google',
                          style: AppTextStyle(context).buttonText.copyWith(
                                color: colors(context).primaryColor,
                              ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: BorderSide(
                            color: colors(context).primaryColor ?? EcommerceAppColor.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    );
            })
          ],
        ),
      );
    });
  }

  _navigate({required WidgetRef ref}) {
    if (ref
            .read(masterControllerProvider.notifier)
            .materModel
            .data
            .registerOtpVerify ==
        true) {
      if (context.mounted) {
        context.nav.pushNamed(
          Routes.recoverPassword,
          arguments: false,
        );
      }
    } else {
      if (context.mounted) {
        context.nav.pushNamedAndRemoveUntil(
          Routes.getCoreRouteName(AppConstants.appServiceName),
          (route) => false,
        );
      }
    }
  }
}
