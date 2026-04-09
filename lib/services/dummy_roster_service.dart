import 'dart:async';

import 'package:flutter/material.dart';

class DummyRosterItem {
  final String title;
  final DateTime from;
  final DateTime to;
  final Color color;
  final bool isAllDay;

  const DummyRosterItem({
    required this.title,
    required this.from,
    required this.to,
    required this.color,
    this.isAllDay = false,
  });
}

class DummyRosterService {
  DummyRosterService._();
  static final DummyRosterService instance = DummyRosterService._();

  Future<List<DummyRosterItem>> fetchRoster() async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime day(int addDays) => today.add(Duration(days: addDays));
    DateTime at(DateTime base, int hour, int minute) =>
        DateTime(base.year, base.month, base.day, hour, minute);

    // Month view is clearer with some all-day events + a timed meeting.
    final d0 = day(0);
    final d1 = day(1);
    final d2 = day(2);

    return <DummyRosterItem>[
      DummyRosterItem(
        title: 'Shift: Morning',
        from: d0,
        to: d0,
        color: const Color(0xFF2563EB),
        isAllDay: true,
      ),
      DummyRosterItem(
        title: 'Shift: Afternoon',
        from: d1,
        to: d1,
        color: const Color(0xFFF97316),
        isAllDay: true,
      ),
      DummyRosterItem(
        title: 'Shift: Night',
        from: d2,
        to: d2,
        color: const Color(0xFF7C3AED),
        isAllDay: true,
      ),
      DummyRosterItem(
        title: 'Team Meeting',
        from: at(d1, 10, 30),
        to: at(d1, 11, 15),
        color: const Color(0xFF16A34A),
      ),
    ];
  }
}
