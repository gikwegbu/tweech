import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweech/models/user_model.dart' as model;
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/auth_methods.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';
import 'package:tweech/widget/custom_textfield.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({
    Key? key,
  }) : super(key: key);

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool _updatingPassword = false;
  bool _revealCurrentPassword = true;
  bool _revealNewPassword = true;
  final AuthMethods _authMethods = AuthMethods();

  late final _userProvider;
  late final model.User _user;

  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _user = _userProvider.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Current Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 3,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: currentPasswordController,
              inputType: TextInputType.visiblePassword,
              icon: _revealCurrentPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              obscureText: _revealCurrentPassword,
              iconPress: () {
                _revealCurrentPassword = !_revealCurrentPassword;
                setState(() {});
              },
            ),
            const Text(
              "New Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 3,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: newPasswordController,
              inputType: TextInputType.visiblePassword,
              icon:
                  _revealNewPassword ? Icons.visibility_off : Icons.visibility,
              obscureText: _revealNewPassword,
              iconPress: () {
                _revealNewPassword = !_revealNewPassword;
                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            if (_updatingPassword)
              const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            Visibility(
              visible: !_updatingPassword,
              child: CustomButton(
                text: 'Update Password',
                press: _updatePassword,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  _updatePassword() async {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty) {
      showSnackBar(context, "Oops!!! field can't be empty");
      return;
    }
    _updatingPassword = true;
    setState(() {});
    // call the firestore code here
    await _authMethods.updatePassword(
        context, currentPasswordController.text, newPasswordController.text);
    _updatingPassword = false;
    setState(() {});
    // currentPasswordController.clear();
    // newPasswordController.clear();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }
}
