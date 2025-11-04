// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:ekray/views/common/authentication/layouts/create_new_password_layout.dart';

class CreateNewPasswordView extends StatelessWidget {
  final String forgotPasswordToken;
  const CreateNewPasswordView({
    super.key,
    required this.forgotPasswordToken,
  });

  @override
  Widget build(BuildContext context) {
    return CreateNewPasswordLayout(forgotPasswordToken: forgotPasswordToken);
  }
}
