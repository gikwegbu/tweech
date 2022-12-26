import 'package:flutter/material.dart';

extension sample on Container {
  // Container roundedCorner([Color? color, int? x]) {
  //   return Container(
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(x?.toDouble() ?? 20),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           border: Border.all(),
  //         ),
  //         child: this,
  //       ),
  //     ),
  //   );
  // }

  Container addGradient(Color colorStart, Color colorEnd) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorStart, colorEnd]),
      ),
      child: this,
    );
  }
}
