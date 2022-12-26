import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tweech/components/change_username.dart';
import 'package:tweech/providers/user_provider.dart';
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
    final _user = Provider.of<UserProvider>(context, listen: true).user;
    final _size = MediaQuery.of(context).size;
    return SizedBox(
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
            Text(
              _user.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              _user.email,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 50,
            ),
            CustomButton(
              text: "Change Password",
              buttonColor: Colors.transparent,
              press: () {
                _bottomSheet(0);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButton(
              text: "Change Username",
              press: () {
                _bottomSheet(1);
              },
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
  }

  _bottomSheet(int index) async {
    // You'd have different views for change password and username,
    // Use the index to return which one you wanna show...
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Platform.isAndroid ? 5 : 25.0),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: getView(index: 0),
          );
        });
  }

  Widget getView({required int index}) {
    /* 
      Get the index, fetch the corresponding extracted widget, using a switch statment...
     */
    switch (index) {
      case 0:
        return const UpdateUsername();
      default:
        return const UpdateUsername();
    }
  }
}
