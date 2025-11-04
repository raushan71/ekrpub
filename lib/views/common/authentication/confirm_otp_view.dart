import 'package:flutter/material.dart';
import 'package:ekray/views/common/authentication/layouts/confirm_otp_layout.dart';

class ConfirmOTPView extends StatelessWidget {
  final ConfirmOTPScreenArguments arguments;
  const ConfirmOTPView({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return ConfirmOTPLayout(arguments: arguments);
  }
}
