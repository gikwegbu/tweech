import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

navigateTo(BuildContext context, route) {
  Navigator.pushNamed(context, route);
}
navigateAndClearPrev(BuildContext context, route) {
  Navigator.pushReplacementNamed(context, route);
}
