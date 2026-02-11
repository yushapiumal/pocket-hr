import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight "liquid" side menu animation using a curved reveal clip.
///
/// Usage:
/// LiquidSideMenu(
///   menu: DesignConfig.drawerContent(scaffoldKey, context),
///   child: YourScreenBody(...),
/// )
class LiquidSideMenu extends StatefulWidget {
  final Widget menu;
  final Widget child;
  final double menuWidth;
  final Duration duration;

  const LiquidSideMenu({
    super.key,
    required this.menu,
    required this.child,
    this.menuWidth = 300,
    this.duration = const Duration(milliseconds: 520),
  });

  static LiquidSideMenuState? of(BuildContext context) {
    return context.findAncestorStateOfType<LiquidSideMenuState>();
  }

  @override
  State<LiquidSideMenu> createState() => LiquidSideMenuState();
}

class LiquidSideMenuState extends State<LiquidSideMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  bool get isOpen => _c.value > 0.5;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void open() => _c.forward();
  void close() => _c.reverse();
  void toggle() => isOpen ? close() : open();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (isOpen) {
          close();
          return false;
        }
        return true;
      },
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final p = _t.value;
          final dx = widget.menuWidth * p;
          final scale = 1.0 - (0.05 * p);
          final radius = 24.0 * p;

          return Stack(
            children: [
              // Menu (revealed with liquid clip)
              ClipPath(
                clipper: _LiquidClipper(progress: p, width: widget.menuWidth),
                child: SizedBox(
                  width: widget.menuWidth,
                  height: mq.size.height,
                  child: widget.menu,
                ),
              ),

              // Dim overlay
              if (p > 0)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: close,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withOpacity(0.12 * p),
                    ),
                  ),
                ),

              // Main content (slides + slight scale + rounded corners)
              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: AbsorbPointer(
                      absorbing: p > 0.0,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LiquidClipper extends CustomClipper<Path> {
  final double progress;
  final double width;

  _LiquidClipper({required this.progress, required this.width});

  @override
  Path getClip(Size size) {
    final w = width * progress;
    final h = size.height;

    // Wave bulge to feel "liquid".
    final bulge = 56.0 * math.sin(progress * math.pi);
    final x = (w + bulge).clamp(0.0, size.width);

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(x, 0);

    // Curved edge
    path.cubicTo(
      x - 40 * progress,
      h * 0.25,
      x + 40 * progress,
      h * 0.75,
      x,
      h,
    );

    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _LiquidClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.width != width;
  }
}
