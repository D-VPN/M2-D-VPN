import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AniProps { opacity, translateX }

class FadeIn extends StatefulWidget {
  final double delay;
  final Widget child;
  FadeIn({
    Key key,
    this.delay,
    this.child,
  }) : super(key: key);

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  @override
  Widget build(BuildContext context) {
    var tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, Tween(begin: 0.0, end: 1.0),
          Duration(milliseconds: 1000))
      ..add(
        AniProps.translateX,
        Tween(begin: 130.0, end: 0.0),
        Duration(milliseconds: 1000),
        Curves.easeOut,
      );
    return PlayAnimation<MultiTweenValues<AniProps>>(
      tween: tween,
      duration: tween.duration,
      child: widget.child,
      delay: Duration(milliseconds: (300 * widget.delay).round()),
      builder: (context, child, value) {
        return Opacity(
          opacity: value.get(AniProps.opacity),
          child: Transform.translate(
            offset: Offset(value.get(AniProps.translateX), 0),
            child: child,
          ),
        );
      },
    );
  }
}
