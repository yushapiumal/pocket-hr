// filepath: /home/akesh/Work/new_hr/cn_pocket_hr/lib/Screens/debtsAndLoans/DebtsAndLoansScreen.dart
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/Screens/debtsAndLoans/devices/MobileDebtsAndLoansScreen.dart';

class HRDebtsAndLoans extends StatefulWidget {
  static String routeName = '/debts-loans';

  @override
  State<HRDebtsAndLoans> createState() => _HRDebtsAndLoansState();
}

class _HRDebtsAndLoansState extends State<HRDebtsAndLoans> {
  @override
  Widget build(BuildContext context) {
    return MobileDebtsAndLoansScreen();
  }
}
