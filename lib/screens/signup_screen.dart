import 'package:flutter/material.dart';
import 'package:tweech/resources/auth_methods.dart';
import 'package:tweech/screens/home_screen.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';
import 'package:tweech/widget/custom_textfield.dart';
import 'package:tweech/utils/regex.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  static const routeName = '/signup-screen';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late FocusNode _passwordFocus;
  bool _passwordFocusHasFocus = false;
  bool _revealPassword = true;
  bool _signingUp = false;
  final AuthMethods _authMethods = AuthMethods();

  @override
  void initState() {
    _passwordFocus = FocusNode();
    _passwordFocus.addListener(() {
      _passwordFocusHasFocus = _passwordFocus.hasFocus;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                const Text(
                  "Email",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  inputType: TextInputType.emailAddress,
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (val) {
                    if (!val!.isValidEmail) {
                      return 'Enter valid email';
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Username",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  inputType: TextInputType.text,
                  icon: Icons.account_circle_outlined,
                  controller: _usernameController,
                  validator: (val) {
                    if (!val!.isNotEmpty) {
                      return "Username can't be empty";
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  inputType: TextInputType.visiblePassword,
                  icon:
                      _revealPassword ? Icons.visibility_off : Icons.visibility,
                  controller: _passwordController,
                  obscureText: _revealPassword,
                  validator: (val) {
                    if (!val!.isValidPassword) {
                      return "Invalid password";
                    }
                  },
                  focusNode: _passwordFocus,
                  iconPress: () {
                    _revealPassword = !_revealPassword;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                AnimatedOpacity(
                  opacity: _passwordFocusHasFocus ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: !_passwordFocusHasFocus
                      ? Container()
                      : const Text(
                          "Must contain at least:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                AnimatedOpacity(
                  opacity: _passwordFocusHasFocus ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: !_passwordFocusHasFocus
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(
                              height: 3,
                            ),
                            Text("one upper case"),
                            SizedBox(
                              height: 3,
                            ),
                            Text("one lower case"),
                            SizedBox(
                              height: 3,
                            ),
                            Text("one digit"),
                            SizedBox(
                              height: 3,
                            ),
                            Text("one Special character"),
                            SizedBox(
                              height: 3,
                            ),
                            Text("8 characters in length"),
                          ],
                        ),
                ),
                const SizedBox(
                  height: 30,
                ),
                if (_signingUp)
                  const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                Visibility(
                  visible: !_signingUp,
                  child: CustomButton(
                    text: 'Signup',
                    press: userSignup,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordFocus.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void userSignup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _signingUp = true;
      });

      bool res = await _authMethods.signupUser(
        context,
        _emailController.text,
        _usernameController.text,
        _passwordController.text,
      );

      if (res) {
        navigateAndClearPrev(context, HomeScreen.routeName);
      }
      setState(() {
        _signingUp = false;
      });
    }
  }
}
