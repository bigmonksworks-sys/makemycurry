import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomLoaderWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const CustomLoaderWidget({
    super.key,
    this.color,
    this.size = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(
        color: color ?? Theme.of(context).primaryColor,
        radius: size / 2,
      ),
    );
  }
}

