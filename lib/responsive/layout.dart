import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  const Layout({Key? key, required this.mobileLayout, required this.desktopLayout}) : super(key: key);
  final Widget mobileLayout;
  final Widget desktopLayout;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if(constraints.maxWidth < 600) {
        return mobileLayout;
      }
      return desktopLayout;
    });
  }
}
