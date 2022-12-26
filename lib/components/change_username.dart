import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweech/models/user_model.dart' as model;
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/firestore_methods.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';
import 'package:tweech/widget/custom_textfield.dart';

class UpdateUsername extends StatefulWidget {
  const UpdateUsername({
    Key? key,
  }) : super(key: key);

  @override
  State<UpdateUsername> createState() => _UpdateUsernameState();
}

class _UpdateUsernameState extends State<UpdateUsername> {
  TextEditingController usernameController = TextEditingController();
  bool _updatingUsername = false;
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  late final _userProvider;
  late final model.User _user;

  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _user = _userProvider.user;
    usernameController.text = _userProvider.user.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Change Username",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 3,
            ),
          ),
          CustomTextField(
            controller: usernameController,
            icon: Icons.account_circle_outlined,
            inputType: TextInputType.text,
          ),
          const SizedBox(
            height: 20,
          ),
          if (_updatingUsername)
            const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          Visibility(
            visible: !_updatingUsername,
            child: CustomButton(
              text: 'Update Username',
              press: _updateusername,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  _updateusername() async {
    if (usernameController.text.isEmpty) {
      showSnackBar(context, "Oops!!! field can't be empty");
      return;
    }
    _updatingUsername = true;
    setState(() {});
    // call the firestore code here
    await _firestoreMethods.updateUsername(context, usernameController.text);
    _updatingUsername = false;
    setState(() {});
    navigateBack(context);
    showSnackBar(context, "Update Successfull");
    // once it returns, update your local provider copyWith...
    await _userProvider
        .updateUser(_user.copyWith(username: usernameController.text));
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }
}
