import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tweech/utils/mediaUtils.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        MediaFileUtils.loadingIndicatorLottie,
        width: 20,
      ),
    );
  }
}
