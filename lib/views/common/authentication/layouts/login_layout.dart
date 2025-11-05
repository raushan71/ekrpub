import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/app_logo.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_text_field.dart';
import 'package:ekray/config/app_color.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/eCommerce/address/address_controller.dart';
import 'package:ekray/controllers/eCommerce/authentication/authentication_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';

class LoginLayout extends StatefulWidget {
  const LoginLayout({super.key});

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout> {
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final List<FocusNode> fNodes = [FocusNode(), FocusNode()];

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    phoneController.text = '';
    passwordController.text = 'secret';
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                  S.of(context).dontHaveAccount,
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Gap(5.w),
                GestureDetector(
                  onTap: () => context.nav.pushNamed(Routes.singUp),
                  child: Text(
                    S.of(context).signUp,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w)
          .copyWith(bottom: 20.h, top: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).welcomeBack,
            style: AppTextStyle(context)
                .title
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Gap(20.h),
          CustomTextFormField(
            name: S.of(context).emailOrPhone,
            hintText: S.of(context).emailOrPhone,
            textInputType: TextInputType.emailAddress,
            controller: phoneController,
            focusNode: fNodes[0],
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email or phone';
              }
              // Check if it's an email
              final isEmail = value.contains('@') && value.contains('.');
              if (isEmail) {
                return GlobalFunction.emailValidator(
                  value: value,
                  hintText: S.of(context).emailOrPhone,
                  context: context,
                );
              }
              // Otherwise validate as phone
              return GlobalFunction.commonValidator(
                value: value,
                hintText: S.of(context).emailOrPhone,
                context: context,
              );
            },
          ),
          Gap(20.h),
          Consumer(builder: (context, ref, _) {
            return CustomTextFormField(
              name: S.of(context).password,
              hintText: S.of(context).password,
              textInputType: TextInputType.text,
              focusNode: fNodes[1],
              controller: passwordController,
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
          Gap(20.h),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => context.nav.pushNamed(
                Routes.recoverPassword,
                arguments: true,
              ),
              child: Text(
                S.of(context).forgotPassword,
                style: AppTextStyle(context).bodyText,
              ),
            ),
          ),
          Gap(30.h),
          Consumer(builder: (context, ref, _) {
            return ref.watch(authControllerProvider)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : CustomButton(
                    buttonText: S.of(context).login,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (formKey.currentState!.validate()) {
                        final input = phoneController.text.trim();
                        final isEmail = input.contains('@') && input.contains('.');

                        if (isEmail) {
                          // Use Firebase Auth email/password login
                          ref
                              .read(authControllerProvider.notifier)
                              .signInWithEmailPassword(
                                email: input,
                                password: passwordController.text,
                              )
                              .then((response) {
                            if (response.isSuccess) {
                              ref
                                  .read(addressControllerProvider.notifier)
                                  .getAddress();
                              context.nav.pushNamed(Routes.getCoreRouteName(
                                  AppConstants.appServiceName));
                            } else {
                              GlobalFunction.showCustomSnackbar(
                                message: response.message,
                                isSuccess: false,
                              );
                            }
                          });
                        } else {
                          // Use existing phone/password login
                          ref
                              .read(authControllerProvider.notifier)
                              .login(
                                phone: input,
                                password: passwordController.text,
                              )
                              .then((response) {
                            if (response.isSuccess) {
                              ref
                                  .read(addressControllerProvider.notifier)
                                  .getAddress();
                              context.nav.pushNamed(Routes.getCoreRouteName(
                                  AppConstants.appServiceName));
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
                        ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle()
                            .then((response) {
                          if (response.isSuccess) {
                            ref
                                .read(addressControllerProvider.notifier)
                                .getAddress();
                            context.nav.pushNamed(Routes.getCoreRouteName(
                                AppConstants.appServiceName));
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
          }),
          Gap(30.h),
          Consumer(
            builder: (context, ref, _) {
              return Align(
                alignment: Alignment.center,
                child: Visibility(
                  visible: !ref.read(hiveServiceProvider).userIsLoggedIn(),
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: TextButton(
                      onPressed: () {
                        context.nav.pushNamed(
                          Routes.getCoreRouteName(AppConstants.appServiceName),
                        );
                      },
                      child: Text(
                        S.of(context).skip,
                        style: AppTextStyle(context).buttonText,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
