import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tweech/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.controller,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.obscureText = false,
    required this.icon,
    this.iconPress,
    required this.inputType,
    this.hintText = '',
  }) : super(key: key);
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool obscureText;
  final IconData icon;
  final Function? iconPress;
  final TextInputType inputType;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          splashRadius: 20,
          onPressed: () => iconPress!(),
          icon: Icon(
            icon,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: btnColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            // color: secBgColor,
            color: inputFieldColor,
          ),
        ),
      ),
    );
  }
}
