import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tweech/resources/auth_methods.dart';
import 'package:tweech/screens/onboarding_screen.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80,
            ),
            SizedBox(
              height: _size.height * 0.2,
              child: Lottie.asset('assets/animations/user.json'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              height: 100,
            ),
            CustomButton(
              text: "Change Password",
              buttonColor: Colors.transparent,
              press: () {},
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButton(
              text: "Change Username",
              press: () {},
              buttonColor: Colors.transparent,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButton(
              text: "Logout",
              press: () {
                _showLogoutDialog(context);
              },
              buttonColor: Colors.red,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  _showLogoutDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        "Continue",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: _logout,
    );

    // set up the AlertDialog
    final alert = Platform.isAndroid
        ? AlertDialog(
            title: const Text("Log Out"),
            content: const Text("Are you sure you want to Log out?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          )
        : CupertinoAlertDialog(
            title: const Text("Log Out"),
            content: const Text("Are you sure you want to Log out?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _logout() async {
    bool res = await _authMethods.signOutUser(context);
    Navigator.pop(context);
    navigateAndClearPrev(context, OnboardingScreen.routeName);
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute<void>(
    //     builder: (BuildContext context) => const OnboardingScreen(),
    //   ),
    //   ModalRoute.withName('/'),
    // );
    print(res);
  }
}
