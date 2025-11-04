import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_text_field.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/master_controller.dart';
import 'package:ekray/controllers/common/other_controller.dart';
import 'package:ekray/controllers/eCommerce/authentication/authentication_controller.dart';
import 'package:ekray/controllers/misc/misc_controller.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/models/eCommerce/authentication/user.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/services/common/hive_service_provider.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/common/authentication/components/country_model_bottom_sheet.dart';
import 'package:ekray/views/common/authentication/layouts/confirm_otp_layout.dart';

class ProfileLayout extends ConsumerStatefulWidget {
  const ProfileLayout({super.key});

  @override
  ConsumerState<ProfileLayout> createState() => _ProfileLayoutState();
}

class _ProfileLayoutState extends ConsumerState<ProfileLayout> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController countryController;
  late TextEditingController phoneCodeController;
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  @override
  void initState() {
    initializeControllers();
    if (ref.read(selectedUserProfileImage) != null) {
      ref.refresh(selectedUserProfileImage.notifier).state;
    }
    ref.read(hiveServiceProvider).getUserInfo().then((userInfo) {
      if (userInfo != null) {
        nameController.text = userInfo.name!;
        phoneController.text = userInfo.phone!;
        emailController.text = userInfo.email ?? '';
        countryController.text = userInfo.country ?? '';
        phoneCodeController.text = userInfo.phoneCode ?? '';
        setState(() {});
      }
    });
    super.initState();
  }

  void initializeControllers() {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    countryController = TextEditingController();
    phoneCodeController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materModelData =
        ref.watch(masterControllerProvider.notifier).materModel.data;
    final isPhoneRequired = materModelData.phoneRequired;
    int? phoneMinLength = materModelData.phoneMinLength;
    int? phoneMaxLength = materModelData.phoneMaxLength;
    final registerOtpType = materModelData.registerOtpType;
    return Scaffold(
        backgroundColor: colors(context).accentColor,
        appBar: AppBar(
          title: Text(S.of(context).myProfile),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: colors(context).accentColor!),
            ),
          ),
          height: 90.h,
          child: ref.watch(authControllerProvider)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CustomButton(
                  buttonText: S.of(context).updateProfile,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final User userInfo = User.fromMap({}).copyWith(
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        country: countryController.text,
                        phoneCode: phoneCodeController.text,
                      );
                      ref
                          .read(authControllerProvider.notifier)
                          .updateProfile(
                            userInfo: userInfo,
                            file: ref.read(selectedUserProfileImage) != null
                                ? File(ref.read(selectedUserProfileImage)!.path)
                                : null,
                          )
                          .then((response) {
                        if (response.isSuccess) {
                          GlobalFunction.showCustomSnackbar(
                            message: response.message,
                            isSuccess: response.isSuccess,
                          );
                        }
                      });
                    }
                  },
                ),
        ),
        body: ref.watch(profileInfoControllerProvider).when(
              data: (user) {
                final isUserVerified = user.accountVerified ?? false;
                return FormBuilder(
                  key: formKey,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        child: ClipPath(
                          clipper: CustomShape(),
                          child: Stack(
                            children: [
                              Container(
                                color: GlobalFunction.getContainerColor(),
                                child: Center(
                                  child: Stack(
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable:
                                            Hive.box(AppConstants.userBox)
                                                .listenable(),
                                        builder: (context, box, _) {
                                          Map<dynamic, dynamic>? userInfo =
                                              box.get(AppConstants.userData);
                                          Map<String, dynamic>
                                              userInfoStringKeys =
                                              userInfo!.cast<String, dynamic>();
                                          User user =
                                              User.fromMap(userInfoStringKeys);
                                          return Container(
                                            height: 100.h,
                                            width: 100.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: ref.watch(
                                                            selectedUserProfileImage) !=
                                                        null
                                                    ? FileImage(
                                                        File(ref
                                                            .watch(
                                                                selectedUserProfileImage
                                                                    .notifier)
                                                            .state!
                                                            .path),
                                                      ) as ImageProvider
                                                    : CachedNetworkImageProvider(
                                                        user.profilePhoto!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        bottom: 5,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            GlobalFunction.pickImageFromGallery(
                                                ref: ref);
                                          },
                                          child: CircleAvatar(
                                            radius: 16.r,
                                            backgroundColor:
                                                colors(context).primaryColor,
                                            child: Center(
                                              child: Icon(
                                                Icons.photo_camera,
                                                color: GlobalFunction
                                                    .getContainerColor(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 10,
                                child: GestureDetector(
                                  onTap: isUserVerified == true
                                      ? null
                                      : () {
                                          if (registerOtpType == 'email') {
                                            if (user.email == null) {
                                              GlobalFunction.showCustomSnackbar(
                                                  message:
                                                      "Please update your profile with email to verify your account",
                                                  isSuccess: false);
                                            } else {
                                              context.nav.pushNamed(
                                                Routes.confirmOTP,
                                                arguments:
                                                    ConfirmOTPScreenArguments(
                                                        phoneNumber:
                                                            user.email!,
                                                        isPasswordRecover:
                                                            false,
                                                        isFromCheckoutScreen:
                                                            true),
                                              );
                                            }
                                          } else if (registerOtpType ==
                                              'phone') {
                                            if (user.email == null) {
                                              GlobalFunction.showCustomSnackbar(
                                                  message:
                                                      "Please update your profile with phone number to verify your account",
                                                  isSuccess: false);
                                            } else {
                                              context.nav.pushNamed(
                                                Routes.confirmOTP,
                                                arguments:
                                                    ConfirmOTPScreenArguments(
                                                        phoneNumber:
                                                            user.phone!,
                                                        isPasswordRecover:
                                                            false,
                                                        isFromCheckoutScreen:
                                                            true),
                                              );
                                            }
                                          }
                                        },
                                  child: VerificationStatusWidget(
                                    isVerified: isUserVerified,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Gap(2.h),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          color: GlobalFunction.getContainerColor(),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                CustomTextFormField(
                                  name: S.of(context).name,
                                  hintText: 'Name',
                                  textInputType: TextInputType.text,
                                  controller: nameController,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) =>
                                      GlobalFunction.commonValidator(
                                          value: value!,
                                          hintText: 'Name',
                                          context: context),
                                ),
                                Gap(20.h),
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              CountryModelBottomSheet(
                                            onChangeCountry: (country) {
                                              setState(() {
                                                phoneCodeController.text =
                                                    country['phone_code'];
                                              });
                                              return countryController.text =
                                                  country['name'];
                                            },
                                          ),
                                        );
                                      },
                                      child: CustomTextFormField(
                                        name: 'Country',
                                        hintText: 'Country',
                                        textInputType: TextInputType.text,
                                        controller: countryController,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) =>
                                            GlobalFunction.commonValidator(
                                          value: value!,
                                          hintText: 'Country',
                                          context: context,
                                        ),
                                        widget: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey,
                                        ),
                                        readOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(20.h),
                                Stack(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Phone Number',
                                          style: AppTextStyle(context)
                                              .bodyText
                                              .copyWith(
                                                  fontWeight: FontWeight.w500),
                                        ),
                                        isUserVerified == true &&
                                                registerOtpType == 'phone'
                                            ? VerificationStatusWidget(
                                                horizontalGap: 8.w,
                                                verticalGap: 2.h,
                                                iconWidth: 16.w,
                                                isVerified: true,
                                                verifiedIcon:
                                                    "assets/svg/phone.svg",
                                                unverifiedIcon:
                                                    "assets/svg/phone.svg",
                                              )
                                            : isUserVerified == false &&
                                                    registerOtpType == 'phone'
                                                ? GestureDetector(
                                                    onTap: () {
                                                      if (user.phone == null) {
                                                        GlobalFunction
                                                            .showCustomSnackbar(
                                                                message:
                                                                    "Please update your profile with phone number to verify your account",
                                                                isSuccess:
                                                                    false);
                                                      } else {
                                                        context.nav.pushNamed(
                                                          Routes.confirmOTP,
                                                          arguments: ConfirmOTPScreenArguments(
                                                              phoneNumber:
                                                                  user.phone!,
                                                              isPasswordRecover:
                                                                  false,
                                                              isFromCheckoutScreen:
                                                                  true),
                                                        );
                                                      }
                                                    },
                                                    child:
                                                        VerificationStatusWidget(
                                                      horizontalGap: 8.w,
                                                      verticalGap: 2.h,
                                                      iconWidth: 16.w,
                                                      isVerified: false,
                                                      verifiedIcon:
                                                          "assets/svg/phone.svg",
                                                      unverifiedIcon:
                                                          "assets/svg/phone.svg",
                                                    ))
                                                : SizedBox.shrink()
                                      ],
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
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                    color: colors(context)
                                                        .accentColor!),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  phoneCodeController.text,
                                                  style: AppTextStyle(context)
                                                      .bodyText
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                            hintText:
                                                S.of(context).enterPhoneNumber,
                                            textInputType: TextInputType.phone,
                                            controller: phoneController,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) =>
                                                GlobalFunction.phoneValidator(
                                              value: value!,
                                              hintText:
                                                  S.of(context).phoneNumber,
                                              context: context,
                                              minLength: phoneMinLength,
                                              maxLength: phoneMaxLength,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Gap(20.h),
                                Stack(
                                  children: [
                                    CustomTextFormField(
                                      name: S.of(context).email,
                                      hintText: 'Email',
                                      textInputType: TextInputType.text,
                                      controller: emailController,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) => null,
                                    ),
                                    isUserVerified == true &&
                                            registerOtpType == 'email'
                                        ? Positioned(
                                            top: 0,
                                            right: 0,
                                            child: VerificationStatusWidget(
                                              iconWidth: 16.w,
                                              horizontalGap: 8.w,
                                              verticalGap: 2.h,
                                              isVerified: true,
                                              verifiedIcon:
                                                  "assets/svg/envelope.svg",
                                              unverifiedIcon:
                                                  "assets/svg/envelope.svg",
                                            ))
                                        : isUserVerified == false &&
                                                registerOtpType == 'email'
                                            ? Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      if (user.email == null) {
                                                        GlobalFunction
                                                            .showCustomSnackbar(
                                                                message:
                                                                    "Please update your profile with email to verify your account",
                                                                isSuccess:
                                                                    false);
                                                      } else {
                                                        context.nav.pushNamed(
                                                          Routes.confirmOTP,
                                                          arguments: ConfirmOTPScreenArguments(
                                                              phoneNumber:
                                                                  user.email!,
                                                              isPasswordRecover:
                                                                  false,
                                                              isFromCheckoutScreen:
                                                                  true),
                                                        );
                                                      }
                                                    },
                                                    child:
                                                        VerificationStatusWidget(
                                                      horizontalGap: 8.w,
                                                      verticalGap: 2.h,
                                                      iconWidth: 16.w,
                                                      isVerified: false,
                                                      verifiedIcon:
                                                          "assets/svg/envelope.svg",
                                                      unverifiedIcon:
                                                          "assets/svg/envelope.svg",
                                                    )),
                                              )
                                            : SizedBox.shrink()
                                  ],
                                ),
                                Gap(20.h),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ));
  }

  final String profieImge =
      'https://media.istockphoto.com/id/1336647287/photo/portrait-of-handsome-indian-businessman-with-mustache-wearing-hat-against-plain-wall.jpg?s=612x612&w=0&k=20&c=XOuLIyFb2DBO8voUXecWkYNxwRrIMYcTRU4QlK9ILks=';
}

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, height - 25);
    path.quadraticBezierTo(width / 2, height, width, height - 25);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class VerificationStatusWidget extends StatelessWidget {
  final bool isVerified;
  final Color verifiedColor;
  final Color unverifiedColor;
  final String verifiedText;
  final String unverifiedText;
  final String verifiedIcon;
  final String unverifiedIcon;
  final double? horizontalGap;
  final double? verticalGap;
  final double? iconWidth;

  const VerificationStatusWidget({
    super.key,
    required this.isVerified,
    this.verifiedColor = Colors.blue,
    this.unverifiedColor = Colors.red,
    this.verifiedText = 'Verified',
    this.unverifiedText = 'Unverified',
    this.verifiedIcon = "assets/svg/shield-check.svg",
    this.unverifiedIcon = "assets/svg/shield-times.svg",
    this.horizontalGap,
    this.verticalGap,
    this.iconWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isVerified
            ? verifiedColor.withOpacity(0.1)
            : unverifiedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalGap ?? 16.w, vertical: verticalGap ?? 8.h),
        child: Row(
          children: [
            SvgPicture.asset(
              isVerified ? verifiedIcon : unverifiedIcon,
              width: iconWidth ?? 18.w,
              colorFilter: ColorFilter.mode(
                isVerified ? verifiedColor : unverifiedColor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              isVerified ? verifiedText : unverifiedText,
              style: TextStyle(
                color: isVerified ? verifiedColor : unverifiedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
