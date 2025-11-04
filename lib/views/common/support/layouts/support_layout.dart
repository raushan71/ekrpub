import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/components/ecommerce/custom_button.dart';
import 'package:ekray/components/ecommerce/custom_text_field.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/controllers/common/other_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportLayout extends StatelessWidget {
  const SupportLayout({super.key});

  static TextEditingController subjectController = TextEditingController();
  static TextEditingController messageController = TextEditingController();
  static List<FocusNode> fList = [FocusNode(), FocusNode()];
  static final GlobalKey<FormBuilderState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).support),
          ),
          backgroundColor: GlobalFunction.getBackgroundColor(context: context),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context: context),
                Gap(8.h),
                _buildContactForm(context: context),
                Gap(8.h),
                _buildContactBody(context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).getInTouch,
            style: AppTextStyle(context)
                .title
                .copyWith(fontSize: 28.sp, fontWeight: FontWeight.w700),
          ),
          Gap(8.h),
          Text(
            S.of(context).alwaysWithYourReach,
            style: AppTextStyle(context).bodyText.copyWith(fontSize: 14.sp),
          )
        ],
      ),
    );
  }

  Widget _buildContactForm({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            CustomTextFormField(
              name: S.of(context).subject,
              textInputType: TextInputType.text,
              focusNode: fList[0],
              controller: subjectController,
              textInputAction: TextInputAction.next,
              validator: (value) => GlobalFunction.commonValidator(
                value: value!,
                hintText: 'Subject',
                context: context,
              ),
              hintText: S.of(context).writeSubjectHere,
            ),
            Gap(20.h),
            CustomTextFormField(
              name: S.of(context).message,
              textInputType: TextInputType.multiline,
              focusNode: fList[1],
              minLines: 4,
              maxLines: 4,
              controller: messageController,
              textInputAction: TextInputAction.newline,
              validator: (value) => GlobalFunction.commonValidator(
                value: value!,
                hintText: 'Message',
                context: context,
              ),
              hintText: S.of(context).startWriting,
            ),
            Gap(20.h),
            Consumer(builder: (context, ref, _) {
              return ref.watch(supportControllerProvider)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CustomButton(
                      buttonText: S.of(context).send,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(supportControllerProvider.notifier)
                              .support(
                                subject: subjectController.text,
                                message: messageController.text,
                              )
                              .then((value) {
                            subjectController.clear();
                            messageController.clear();
                          });
                        }
                      },
                    );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildContactBody({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      child: Column(
        children: [
          Consumer(builder: (context, ref, _) {
            return ref.watch(contactUsControllerProvider).when(
                  data: (data) {
                    if (data.data.phone == null &&
                        data.data.messenger == null &&
                        data.data.whatsapp == null) {
                      return Container();
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: colors(context).accentColor,
                              ),
                            ),
                            Gap(5.w),
                            Text(
                              S.of(context).contactVia,
                              style: AppTextStyle(context).bodyText.copyWith(
                                  fontSize: 12.sp, fontWeight: FontWeight.w700),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: colors(context).accentColor,
                              ),
                            ),
                          ],
                        ),
                        Gap(36.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (data.data.phone != null)
                              GestureDetector(
                                onTap: () => launchUrl(
                                    Uri.parse("tel://${data.data.phone}")),
                                child: Assets.png.call.image(width: 48.w),
                              ),
                            Gap(28.w),
                            if (data.data.messenger != null)
                              GestureDetector(
                                onTap: () => launchUrl(
                                    Uri.parse(data.data.messenger ?? '')),
                                child: Assets.png.messenger.image(width: 48.w),
                              ),
                            Gap(28.w),
                            if (data.data.whatsapp != null)
                              GestureDetector(
                                onTap: () => _whatsAppService(
                                    phoneNumber: data.data.whatsapp ?? '',
                                    message: ''),
                                child: Assets.png.whatsapp.image(width: 48.w),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, s) => Text(error.toString()),
                );
          }),
          Gap(36.h),
        ],
      ),
    );
  }

  Future<void> _whatsAppService(
      {required String phoneNumber, required String message}) async {
    final String encodedPhoneNumber = Uri.encodeComponent(phoneNumber);
    final String encodedMessage = Uri.encodeComponent(message);
    final String whatsappUrl =
        "whatsapp://send?phone=$encodedPhoneNumber&text=$encodedMessage";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      throw 'Could not launch';
    }
  }
}
