import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AnimatedColor { Color1, Color2 }

class AnimatedBackground extends StatelessWidget {
  final Widget child;

  const AnimatedBackground({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AnimatedColor>()
      ..add(
          AnimatedColor.Color1,
          ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900),
          Duration(seconds: 3))
      ..add(
          AnimatedColor.Color2,
          ColorTween(begin: Color(0xffA83279), end: Colors.blue.shade600),
          Duration(seconds: 3));
    return MirrorAnimation<MultiTweenValues<AnimatedColor>>(
      tween: tween,
      duration: tween.duration,
      child: child,
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                value.get(AnimatedColor.Color1),
                value.get(AnimatedColor.Color2)
              ])),
          child: child,
        );
      },
    );
  }
}
