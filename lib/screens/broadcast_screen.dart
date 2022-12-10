import 'package:flutter/material.dart';

class BroadCastScreen extends StatefulWidget {
  const BroadCastScreen({Key? key}) : super(key: key);
  static String routeName = "broadcast_screen";

  @override
  State<BroadCastScreen> createState() => _BroadCastScreenState();
}

class _BroadCastScreenState extends State<BroadCastScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text("Hellooooooo"),);
  }
}
