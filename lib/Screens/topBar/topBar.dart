import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cn_pocket_hr/Screens/topBar/devices/mobileTopBar.dart';
import 'package:cn_pocket_hr/Screens/topBar/devices/tabletTopBar.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class TopBar extends StatefulWidget {
  const TopBar(
      {Key? key,
      required this.extendBody,
      required this.drawerScrimColor,
      required this.drawer})
      : super(key: key);

  final extendBody;
  final drawerScrimColor;
  final drawer;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileTopBar(
          extendBody: widget.extendBody,
          drawerScrimColor: widget.drawerScrimColor,
          drawer: widget.drawer),
      tabletBody: TabletTopBar(),
    );
  }
}
