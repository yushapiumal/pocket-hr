import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cn_pocket_hr/screens/team/devices/mobile_team.dart';
import 'package:cn_pocket_hr/screens/team/devices/tablet_team.dart';
import 'package:cn_pocket_hr/ui/responsive_layout.dart';
import 'package:localstorage/localstorage.dart';


class HRTeam extends StatefulWidget {
  static String routeName = "/team";

  const HRTeam({Key? key}) : super(key: key);

  @override
  State<HRTeam> createState() => _HRTeamState();
}

class _HRTeamState extends State<HRTeam> {
  @override
  Widget build(BuildContext context) {

    final LocalStorage storage = LocalStorage('pocketHR');
   // final String activeId = storage.getItem('uid')?.toString() ?? 'owner_001';
  //    final String activeId = 'owner_001';


    return ResponsiveLayout(
      mobileBody: MobileTeam(),
      tabletBody: TabletTeam(),  
    );
  }
}
