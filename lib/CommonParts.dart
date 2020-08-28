import 'package:flutter/material.dart';

class GradientCircleIconButton extends StatelessWidget {
  final Widget icon;
  final List<Color> colors;

  GradientCircleIconButton(
      {this.icon,
      this.colors = const [
        Colors.cyan,
        Colors.indigo,
      ]});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: icon,
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

class GradientIcon extends StatelessWidget {
  final IconData iconData;
  final double size;
  final List<Color> colors;

  GradientIcon(this.iconData,
      {this.size = 24.0,
      this.colors = const [
        Colors.cyan,
        Colors.indigo,
      ]});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: FractionalOffset.centerLeft,
          end: FractionalOffset.centerRight,
          colors: colors,
        ).createShader(bounds);
      },
      child: Icon(
        iconData,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
