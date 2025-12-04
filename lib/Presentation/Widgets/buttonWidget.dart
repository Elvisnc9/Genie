import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key, required this.child, required this.push, required this.color});

  final Widget child;
  final VoidCallback push;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: push,
      child: Container(
        height: 7.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color
        ),
        child: child,
      ),
    );
  }
}
