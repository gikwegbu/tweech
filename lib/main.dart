import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/resources/auth_methods.dart';
import 'package:tweech/screens/homeScreen.dart';
import 'package:tweech/screens/login_screen.dart';
import 'package:tweech/screens/onboarding_screen.dart';
import 'package:tweech/screens/signup_screen.dart';
import 'package:tweech/utils/colors.dart';
import 'package:tweech/models/user_model.dart' as model;
import 'package:tweech/widget/loadingIndicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
          ),
        ),
      ),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      home: FutureBuilder(
        future: AuthMethods()
            .getCurrentUser(FirebaseAuth.instance.currentUser != null
                ? FirebaseAuth.instance.currentUser!.uid
                : null)
            .then((value) {
          if (value != null) {
            Provider.of<UserProvider>(context, listen: false).setUser(
              model.User.fromMap(value),
            );
          }
          return value;
        }),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapShot.hasData) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
