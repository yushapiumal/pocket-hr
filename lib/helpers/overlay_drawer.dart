import 'dart:ui';

import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const CustomDrawer({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic).value;
        final scrimOpacity = progress * 0.6;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: progress * 5, sigmaY: progress * 5),
          child: Stack(
            children: [
              // Scrim
              GestureDetector(
                onTap: () {
                  // Close the drawer when tapping on the scrim
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.black.withOpacity(scrimOpacity),
                ),
              ),
              // Drawer content
              Transform.translate(
                offset: Offset(-300 * (1 - progress), 0),
                child: SingleChildScrollView(child: child),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}