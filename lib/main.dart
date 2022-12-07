import 'package:flutter/material.dart';
import 'package:tweech/screens/login_screen.dart';
import 'package:tweech/screens/onboarding_screen.dart';
import 'package:tweech/screens/signup_screen.dart';
import 'package:tweech/utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Twee-ch',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: bgColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: bgColor,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: priColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: priColor,
          )
        )
      ),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
      },
      home: const OnboardingScreen(),
    );
  }
}
