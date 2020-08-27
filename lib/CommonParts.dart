import 'package:flutter/material.dart';

class MyGradientIcon extends StatelessWidget {
  final IconData iconData;
  final List<Color> colors;

  MyGradientIcon(
      {this.iconData,
      this.colors = const [
        Colors.cyan,
        Colors.indigo,
      ]});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(iconData),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: FractionalOffset.centerLeft,
          end: FractionalOffset.centerRight,
          colors: colors,
        ),
      ),
    );
  }
}
