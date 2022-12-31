import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tweech/resources/auth_methods.dart';
import 'package:tweech/responsive/responsive.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';
import 'package:tweech/widget/custom_textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _resettingPassword = false;
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SingleChildScrollView(
          child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("A Reset link will be sent to the below email"),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  inputType: TextInputType.emailAddress,
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  hintText: "Enter email...",
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please provide email";
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_resettingPassword)
                  const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                Visibility(
                  visible: !_resettingPassword,
                  child: CustomButton(
                    text: 'Reset Password',
                    press: _resetPassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  void _resetPassword() async {
    toggleKeypad(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _resettingPassword = true;
      });

      bool res =
          await _authMethods.passwordReset(context, _emailController.text);

      if (res) {
        // Show dialog....
        _showLogoutDialog(context);
        // Set a timer, the go back to login...
      }
      setState(() {
        _resettingPassword = false;
      });
    }
  }

  _showLogoutDialog(BuildContext context) {
    String title = "Link Sent";
    String content = "A link has been sent to ${_emailController.text}.";
    // set up the buttons
    Widget continueButton = TextButton(
      child: const Text(
        "Continue",
      ),
      onPressed: () {
        navigateBack(context);
        navigateBack(context);
      },
    );

    // set up the AlertDialog
    final alert = Platform.isAndroid
        ? AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              continueButton,
            ],
          )
        : CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              continueButton,
            ],
          );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
