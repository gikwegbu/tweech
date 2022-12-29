import 'package:flutter/material.dart';
import 'package:tweech/utils/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    required this.press,
    this.buttonColor = btnColor,
  }) : super(key: key);
  final String text;
  final Color buttonColor;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // primary: btnColor,
        primary: buttonColor,
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: press,
      child: Text(
        text,
        style: TextStyle(
          color:
              buttonColor == Colors.transparent ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
