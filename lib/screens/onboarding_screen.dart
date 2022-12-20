import 'package:flutter/material.dart';
import 'package:tweech/responsive/responsive.dart';
import 'package:tweech/screens/login_screen.dart';
import 'package:tweech/screens/signup_screen.dart';
import 'package:tweech/utils/utils.dart';
import 'package:tweech/widget/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  static const routeName = '/onboarding-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                "Twee-ch",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              const Spacer(),
              CustomButton(
                text: 'Login',
                press: () {
                  navigateTo(context, LoginScreen.routeName);
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButton(
                text: 'Sign Up',
                press: () {
                  navigateTo(context, SignupScreen.routeName);
                },
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
