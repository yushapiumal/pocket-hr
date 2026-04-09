import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/ui/break_points.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobileBody,
    required this.tabletBody,
    //  this.desktopBody,
  });

  final Widget mobileBody;
  final Widget tabletBody;
  // final Widget desktopBody;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (constraint.maxWidth >= TabletBreakePoint) {
        return tabletBody;
      }
      return mobileBody;
    });
  }
}
