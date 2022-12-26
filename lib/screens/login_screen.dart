import 'package:flutter/material.dart';
import 'package:tweech/resources/auth_methods.dart';
import 'package:tweech/responsive/responsive.dart';
import 'package:tweech/screens/home_screen.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';
import 'package:tweech/widget/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _revealPassword = true;
  bool _signingin = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
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
                      if (val!.isEmpty) {
                        return "Please provide email";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
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
                    icon: _revealPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    controller: _passwordController,
                    obscureText: _revealPassword,
                    iconPress: () {
                      _revealPassword = !_revealPassword;
                      setState(() {});
                    },
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please provide password";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_signingin)
                    const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  Visibility(
                    visible: !_signingin,
                    child: CustomButton(
                      text: 'Login',
                      press: _login,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    toggleKeypad(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _signingin = true;
      });

      bool res = await _authMethods.signInUser(
        context,
        _emailController.text,
        _passwordController.text,
      );

      if (res) {
        navigateAndClearPrev(context, HomeScreen.routeName);
      }
      setState(() {
        _signingin = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
