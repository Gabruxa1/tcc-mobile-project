import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color indicatorColor;

  const LoadingIndicator({
    super.key,
    this.indicatorColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          color: indicatorColor,
        ),
      ),
    );
  }
}
