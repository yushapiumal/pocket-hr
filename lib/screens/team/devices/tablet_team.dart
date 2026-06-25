import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';
import 'package:cn_pocket_hr/helpers/format_utils.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';

class TabletTeam extends StatefulWidget {
//  final String ownerId;

  const TabletTeam({Key? key}) : super(key: key);

  @override
  State<TabletTeam> createState() => _TabletTeamState();
}

class _TabletTeamState extends State<TabletTeam> with TickerProviderStateMixin {
  // Spacing system
  static const double _g4 = 4;
  static const double _g6 = 6;
  static const double _g8 = 8;
  static const double _g12 = 12;
  static const double _g16 = 16;
  static const double _g20 = 20;
  static const double _g24 = 24;

  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

  late TabController _tabController;

  String? _selectedUserId; // null = All
  String _selectedUserLabel = 'All';

  bool _loadingTeam = true;
  String? _teamError;
  List<dynamic> _teamMembers = [];

  // Leave data
  List<dynamic> _leaveData = [];
  bool _loadingLeaves = false;
  String? _leaveError;

  // Attendance data
  List<Map<String, dynamic>> _attendanceData = [];
  bool _loadingAttendance = false;
  String? _attendanceError;
  DateTime _selectedMonth = DateTime.now();

  final _apiService = APIService();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  // Animation controllers for list items
  final Map<int, AnimationController> _leaveAnimationControllers = {};
  final Map<int, AnimationController> _attendanceAnimationControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadTabData();
        _resetAnimations();
      }
    });
    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();

    // Dispose all animation controllers
    for (var controller in _leaveAnimationControllers.values) {
      controller.dispose();
    }
    for (var controller in _attendanceAnimationControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _resetAnimations() {
    // Dispose existing animations
    for (var controller in _leaveAnimationControllers.values) {
      controller.dispose();
    }
    for (var controller in _attendanceAnimationControllers.values) {
      controller.dispose();
    }
    _leaveAnimationControllers.clear();
    _attendanceAnimationControllers.clear();
  }

  void _initLeaveAnimations(int count) {
    for (int i = 0; i < count; i++) {
      if (!_leaveAnimationControllers.containsKey(i)) {
        final controller = AnimationController(
          duration: Duration(milliseconds: 300 + (i * 50)),
          vsync: this,
        );
        _leaveAnimationControllers[i] = controller;
        controller.forward();
      }
    }
  }

  void _initAttendanceAnimations(int count) {
    for (int i = 0; i < count; i++) {
      if (!_attendanceAnimationControllers.containsKey(i)) {
        final controller = AnimationController(
          duration: Duration(milliseconds: 300 + (i * 50)),
          vsync: this,
        );
        _attendanceAnimationControllers[i] = controller;
        controller.forward();
      }
    }
  }

  Future<void> _loadTeamData() async {
    setState(() {
      _loadingTeam = true;
      _teamError = null;
    });

    try {
      final response = await _apiService.getMyTeam();
      debugPrint('Team API Response: $response');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _teamMembers = response['data'] as List<dynamic>;
          _loadingTeam = false;
        });

        // Default to "All"
        setState(() {
          _selectedUserId = null;
          _selectedUserLabel = 'All';
        });
        _loadTabData(); // Load all leaves and attendance by default
      } else {
        throw Exception(response['message'] ?? 'Failed to load team data');
      }
    } catch (e, st) {
      debugPrint('[TEAM][ERROR] $e');
      debugPrint('$st');
      setState(() {
        _teamError = e.toString();
        _loadingTeam = false;
      });
    }
  }

  String _getMemberName(Map<String, dynamic> member) {
    final fields = member['customfields'] ?? [];
    try {
      final fullName = fields.firstWhere(
            (f) => f['input_name'] == 'cf_full_name_as_per_nic_card',
            orElse: () => {},
          )['input_value'] ??
          '';
      if (fullName.toString().trim().isNotEmpty &&
          fullName.toString().trim() != ' ') {
        return fullName.toString().trim();
      }
    } catch (_) {}

    try {
      final initials = fields.firstWhere(
            (f) => f['input_name'] == 'cf_initials',
            orElse: () => {},
          )['input_value'] ??
          '';
      final lastName = fields.firstWhere(
            (f) => f['input_name'] == 'cf_last_name',
            orElse: () => {},
          )['input_value'] ??
          '';
      final name = '$initials $lastName'.trim();
      if (name.isNotEmpty && name != ' ') {
        return name;
      }
    } catch (_) {}

    return member['email']?.split('@')[0] ?? 'Team Member';
  }

  String _getMemberEPF(Map<String, dynamic> member) {
    final fields = member['customfields'] ?? [];
    try {
      return fields
              .firstWhere(
                (f) => f['input_name'] == 'cf_epf_no',
                orElse: () => {},
              )['input_value']
              ?.toString() ??
          '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _loadTabData() async {
    if (_tabController.index == 0) {
      await _loadMemberLeaves();
    } else {
      await _loadMemberAttendance();
    }
  }

  Future<void> _loadMemberLeaves() async {
    setState(() {
      _loadingLeaves = true;
      _leaveError = null;
    });

    try {
      final response = await _apiService.getTeamMemberLeaves('');
      debugPrint('Leaves API Response: $response');

      if (response['success'] == true && response['data'] != null) {
        List<dynamic> leaves = List.from(response['data']);

        // Filter only if specific user is selected
        if (_selectedUserId != null) {
          leaves = leaves
              .where((leave) => leave['userId']?.toString() == _selectedUserId)
              .toList();
        }

        // Sort by most recent date
        leaves.sort((a, b) {
          final aDates = a['dates'] as List? ?? [];
          final bDates = b['dates'] as List? ?? [];
          final aMax = aDates.isNotEmpty
              ? aDates.reduce((max, d) => d > max ? d : max)
              : 0;
          final bMax = bDates.isNotEmpty
              ? bDates.reduce((max, d) => d > max ? d : max)
              : 0;
          return bMax.compareTo(aMax);
        });

        setState(() {
          _leaveData = leaves;
          _loadingLeaves = false;
        });

        // Initialize animations after data is loaded
        if (_leaveData.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initLeaveAnimations(_leaveData.length);
          });
        }
      } else {
        setState(() {
          _leaveData = [];
          _loadingLeaves = false;
        });
      }
    } catch (e, st) {
      debugPrint('[LEAVES][ERROR] $e');
      debugPrint('$st');
      setState(() {
        _leaveError = e.toString();
        _loadingLeaves = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseAttendanceData(dynamic raw, String userId) {
    final List<Map<String, dynamic>> out = [];
    final List<dynamic> entries =
        (raw is List) ? raw : (raw != null ? [raw] : []);

    for (var record in entries) {
      if (record is! Map) continue;

      // Extract potential user id from record (prioritize explicit user id fields)
      String recordUserId = '';
      try {
        if (record['userId'] != null)
          recordUserId = record['userId'].toString();
        else if (record['user_id'] != null)
          recordUserId = record['user_id'].toString();
        else if (record['uid'] != null)
          recordUserId = record['uid'].toString();
        else if (record['user'] is String)
          recordUserId = record['user'].toString();
        else if (record['user'] is Map && record['user']['_id'] != null)
          recordUserId = record['user']['_id'].toString();
        else if (record['_id'] != null &&
            (record['attendance'] is List || record['data'] is List)) {
          // Sometimes the bucket uses _id as user id; accept it when record looks like a user bucket
          recordUserId = record['_id'].toString();
        }
      } catch (_) {}

      // Find attendance entries inside this record
      List<dynamic> attendanceList = [];
      if (record['attendance'] is List)
        attendanceList = List<dynamic>.from(record['attendance']);
      else if (record['data'] is List)
        attendanceList = List<dynamic>.from(record['data']);
      else if (record['records'] is List)
        attendanceList = List<dynamic>.from(record['records']);

      // If no attendanceList, but the record itself looks like an attendance entry, treat it as one entry
      if (attendanceList.isEmpty) {
        // Heuristic: presence of 'time', 'type', 'checkIn', 'checkOut', 'createdAt', or 'date'
        if (record.containsKey('time') ||
            record.containsKey('type') ||
            record.containsKey('checkIn') ||
            record.containsKey('checkOut') ||
            record.containsKey('createdAt') ||
            record.containsKey('date')) {
          attendanceList = [record];
        }
      }

      // If a specific userId is provided, ensure this record/bucket or its items belong to that user
      if (userId.isNotEmpty) {
        bool belongs = false;
        // Check record-level id
        if (recordUserId.isNotEmpty && recordUserId == userId) belongs = true;
        // Check each attendance item for user id fields
        if (!belongs) {
          for (var it in attendanceList) {
            try {
              if (it is Map) {
                final iu =
                    (it['userId'] ?? it['user_id'] ?? it['uid'] ?? it['user'])
                            ?.toString() ??
                        '';
                if (iu.isNotEmpty && iu == userId) {
                  belongs = true;
                  break;
                }
              }
            } catch (_) {}
          }
        }
        if (!belongs) continue; // skip this record
      }

      // Determine a base date for this record
      DateTime baseDate = DateTime.now();
      try {
        if (record['createdAt'] != null) {
          final sec = (record['createdAt'] is num)
              ? (record['createdAt'] as num).toInt()
              : int.tryParse(record['createdAt'].toString()) ?? 0;
          if (sec > 0)
            baseDate = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        } else if (record['date'] != null) {
          final sec = (record['date'] is num)
              ? (record['date'] as num).toInt()
              : int.tryParse(record['date'].toString()) ?? 0;
          if (sec > 0)
            baseDate = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        } else if (attendanceList.isNotEmpty) {
          // try infer from first attendance item time
          final first = attendanceList.first;
          if (first is Map && first['time'] != null) {
            final sec = (first['time'] is num)
                ? (first['time'] as num).toInt()
                : int.tryParse(first['time'].toString()) ?? 0;
            if (sec > 0)
              baseDate = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
          }
        }
      } catch (_) {}

      String? checkIn;
      String? checkOut;

      for (var att in attendanceList) {
        if (att is! Map) continue;
        final type = (att['type'] ?? '').toString().toLowerCase();
        final t = att['time'] ?? att['timestamp'] ?? att['ts'];
        int? epoch;
        if (t is int)
          epoch = t;
        else if (t is num)
          epoch = t.toInt();
        else
          epoch = int.tryParse(t?.toString() ?? '');
        if (epoch == null) continue;
        final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
        final timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        if (type == 'in' || type == 'checkin' || type == 'inward') {
          if (checkIn == null) checkIn = timeStr;
        } else if (type == 'out' || type == 'checkout' || type == 'outward') {
          checkOut = timeStr;
        } else {
          // unknown type: place into checkIn if empty, else checkOut
          if (checkIn == null)
            checkIn = timeStr;
          else if (checkOut == null) checkOut = timeStr;
        }
      }

      String status = 'present';
      if ((checkIn == null || checkIn.isEmpty) &&
          (checkOut == null || checkOut.isEmpty))
        status = 'pending';
      else if (checkIn == null || checkIn.isEmpty)
        status = 'missing_checkin';
      else if (checkOut == null || checkOut.isEmpty)
        status = 'missing_checkout';

      // Work hours: try common fields
      double workHoursNum = 0.0;
      String workHoursRaw = '';
      try {
        final wh = record['workedHours'] ??
            record['workHours'] ??
            record['worked_hours'] ??
            record['wrkd_hours_fmtd'];
        if (wh is num)
          workHoursNum = wh.toDouble();
        else if (wh is String) workHoursRaw = wh;
      } catch (_) {}

      String workHoursDisplay = '';
      if (workHoursNum > 0)
        workHoursDisplay = '${workHoursNum.toStringAsFixed(1)}h';
      else if (workHoursRaw.isNotEmpty) {
        final hMatch = RegExp(r'(\d+)h').firstMatch(workHoursRaw);
        final mMatch = RegExp(r'(\d+)m').firstMatch(workHoursRaw);
        if (hMatch != null || mMatch != null) {
          final h = hMatch != null ? double.parse(hMatch.group(1)!) : 0.0;
          final m = mMatch != null ? double.parse(mMatch.group(1)!) : 0.0;
          final total = h + (m / 60.0);
          if (total > 0)
            workHoursDisplay = '${total.toStringAsFixed(1)}h';
          else
            workHoursDisplay = workHoursRaw;
        } else {
          final cleaned = workHoursRaw.replaceAll(RegExp(r'[^0-9\.]'), '');
          final parsed = double.tryParse(cleaned);
          if (parsed != null && parsed > 0)
            workHoursDisplay = '${parsed.toStringAsFixed(1)}h';
          else
            workHoursDisplay = workHoursRaw;
        }
      }

      out.add({
        'date': baseDate.millisecondsSinceEpoch ~/ 1000,
        'checkIn': checkIn ?? '',
        'checkOut': checkOut ?? '',
        'status': status,
        'workHoursDisplay': workHoursDisplay,
      });
    }

    return out;
  }

  // Update the _loadMemberAttendance method to filter by month
  Future<void> _loadMemberAttendance() async {
    setState(() {
      _loadingAttendance = true;
      _attendanceError = null;
    });

    try {
      final response = await _apiService.getTeamMemberAttendance('');
      if (response['success'] != true || response['data'] == null) {
        setState(() {
          _attendanceData = [];
          _loadingAttendance = false;
        });
        return;
      }

      final List<dynamic> rawData = response['data'];
      final List<Map<String, dynamic>> processed = [];

      for (var record in rawData) {
        if (record is! Map<String, dynamic>) continue;

        final String? userId = record['user']?.toString();
        final int? epf = record['epf'] as int?;

        // Filter by selected user (if not "All")
        if (_selectedUserId != null && userId != _selectedUserId) {
          continue;
        }

        // Extract check-in and check-out
        String? checkIn;
        String? checkOut;
        DateTime? attendanceDate;

        final List<dynamic> attList = record['attendance'] ?? [];

        for (var att in attList) {
          if (att is! Map<String, dynamic>) continue;

          final String type = (att['type'] ?? '').toString().toLowerCase();
          final dynamic timeVal = att['time'];

          if (timeVal == null) continue;

          final int timestamp = (timeVal is num)
              ? timeVal.toInt()
              : int.tryParse(timeVal.toString()) ?? 0;
          if (timestamp <= 0) continue;

          final DateTime dt =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

          // Use the FIRST timestamp as the attendance date (usually the check-in)
          attendanceDate ??= DateTime(dt.year, dt.month, dt.day);

          final String timeStr =
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

          if (type == 'in' || type == 'checkin') {
            checkIn = timeStr;
          } else if (type == 'out' || type == 'checkout') {
            checkOut = timeStr;
          }
        }

        // Fallback date from firstCheckIn or lastCheckOut if no attendance array
        if (attendanceDate == null) {
          final int? firstIn = record['firstCheckIn'] as int?;
          if (firstIn != null && firstIn > 0) {
            final dt = DateTime.fromMillisecondsSinceEpoch(firstIn * 1000);
            attendanceDate = DateTime(dt.year, dt.month, dt.day);
          }
        }

        if (attendanceDate == null) continue;

        // Filter by selected month
        if (attendanceDate.year != _selectedMonth.year ||
            attendanceDate.month != _selectedMonth.month) {
          continue;
        }

        // Determine status
        final bool hasIn = checkIn != null && checkIn.isNotEmpty;
        final bool hasOut = checkOut != null && checkOut.isNotEmpty;

        String status = 'pending';
        if (hasIn && hasOut) {
          status = 'present';
        } else if (hasIn) {
          status = 'missing_checkout';
        } else if (hasOut) {
          status = 'missing_checkin';
        }

        // Work hours - prefer the clean "workedHours" field
        String workHoursDisplay = record['workedHours']?.toString() ?? '';
        if (workHoursDisplay == '0h 0m' || workHoursDisplay.isEmpty) {
          final int? workedSec = record['workedSeconds'] as int?;
          if (workedSec != null && workedSec > 0) {
            final hours = workedSec / 3600.0;
            workHoursDisplay = '${hours.toStringAsFixed(1)}h';
          }
        }

        // Get member name for "All" view
        String memberName = 'Unknown';
        if (_teamMembers.isNotEmpty) {
          final member = _teamMembers.firstWhere(
            (m) =>
                m['_id']?.toString() == userId ||
                _getMemberEPF(m) == epf?.toString(),
            orElse: () => <String, dynamic>{},
          );
          if (member.isNotEmpty) {
            memberName = _getMemberName(member as Map<String, dynamic>);
          }
        }

        processed.add({
          'date': attendanceDate.millisecondsSinceEpoch ~/ 1000,
          'checkIn': checkIn ?? '',
          'checkOut': checkOut ?? '',
          'status': status,
          'workHoursDisplay': workHoursDisplay,
          'memberName': memberName,
          'epf': epf,
          'userId': userId,
        });
      }

      // Sort by date descending
      processed.sort((a, b) {
        final da = a['date'] as int;
        final db = b['date'] as int;
        return db.compareTo(da);
      });

      setState(() {
        _attendanceData = processed;
        _loadingAttendance = false;
      });

      if (processed.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initAttendanceAnimations(processed.length);
        });
      }
    } catch (e, st) {
      debugPrint('[ATTENDANCE][ERROR] $e');
      debugPrint('$st');
      setState(() {
        _attendanceError = e.toString();
        _loadingAttendance = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
    _loadMemberAttendance(); // Reload attendance for new month
  }

  Future<void> _markAttendance(
      String date, String checkIn, String checkOut) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
            child: CupertinoActivityIndicator(
                radius: 16.0, color: HRColors.darkOrangeColor)),
      );

      final response = await _apiService.markAttendance(
          _selectedUserId!, date, checkIn, checkOut);
      Navigator.pop(context);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: AutoSizeText('Attendance marked successfully'),
              backgroundColor: Colors.green),
        );
        await _loadMemberAttendance();
      } else {
        throw Exception(response['message'] ?? 'Failed to mark attendance');
      }
    } catch (e, st) {
      Navigator.pop(context);
      debugPrint('[ATTENDANCE_MARK][ERROR] $e');
      debugPrint('$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: AutoSizeText('Error: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showMarkAttendanceDialog(Map<String, dynamic> attendanceRecord) {
    final date = attendanceRecord['date'] ?? 0;
    final formattedDate = FormatUtils.dateFromUnixSeconds(date);

    _checkInController.clear();
    _checkOutController.clear();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: AutoSizeText('Mark Attendance for $formattedDate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _checkInController,
                decoration: const InputDecoration(
                  labelText: 'Check In Time *',
                  hintText: 'e.g., 09:00',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: _g12),
              TextField(
                controller: _checkOutController,
                decoration: const InputDecoration(
                  labelText: 'Check Out Time *',
                  hintText: 'e.g., 17:00',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  AutoSizeText("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final checkIn = _checkInController.text.trim();
                final checkOut = _checkOutController.text.trim();
                if (checkIn.isEmpty || checkOut.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: AutoSizeText(
                            'Please provide both check-in and check-out times'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                _markAttendance(formattedDate, checkIn, checkOut);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: HRColors.orangeColor),
              child: AutoSizeText("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _approveLeave(String leaveId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
            child: CupertinoActivityIndicator(
                radius: 16.0, color: HRColors.darkOrangeColor)),
      );

      final response = await _apiService.approveLeave(leaveId);
      Navigator.pop(context);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: AutoSizeText('Leave approved successfully'),
              backgroundColor: Colors.green),
        );
        await _loadMemberLeaves();
      } else {
        throw Exception(response['message'] ?? 'Failed to approve leave');
      }
    } catch (e, st) {
      Navigator.pop(context);
      debugPrint('[APPROVE][ERROR] $e');
      debugPrint('$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: AutoSizeText('Error: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectLeave(String leaveId, String reason) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
            child: CupertinoActivityIndicator(
                radius: 16.0, color: HRColors.darkOrangeColor)),
      );

      final response = await _apiService.rejectLeave(leaveId, reason);
      Navigator.pop(context);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: AutoSizeText('Leave rejected successfully'),
              backgroundColor: Colors.orange),
        );
        await _loadMemberLeaves();
      } else {
        throw Exception(response['message'] ?? 'Failed to reject leave');
      }
    } catch (e, st) {
      Navigator.pop(context);
      debugPrint('[REJECT][ERROR] $e');
      debugPrint('$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: AutoSizeText('Error: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showLeaveDetailsBottomSheet(Map<String, dynamic> leave) {
    final dates = leave['dates'] as List? ?? [];
    final status = leave['status'] ?? 'pending';
    final type = leave['type'] ?? 'casual';
    final reason = leave['reason'] ?? '';
    final leaveId = leave['_id'] ?? '';
    final employeeName =
        leave['employeeName']?.split('(')[0].trim() ?? 'Employee';
    final statusColor = _getLeaveStatusColor(status);
    final isPending = status.toLowerCase() == 'pending';

    // Try to extract EPF from a few possible locations on the leave object
    String epf = '';
    try {
      if (leave['epf'] != null)
        epf = leave['epf'].toString();
      else if (leave['employeeEPF'] != null)
        epf = leave['employeeEPF'].toString();
      else if (leave['employeeEpf'] != null)
        epf = leave['employeeEpf'].toString();
      else if (leave['employee'] is Map) {
        final emp = leave['employee'] as Map;
        if (emp['epf'] != null)
          epf = emp['epf'].toString();
        else if (emp['employeeEPF'] != null)
          epf = emp['employeeEPF'].toString();
        else if (emp['customfields'] is List) {
          final fields = List.from(emp['customfields']);
          final f = fields.firstWhere(
            (ff) =>
                ff is Map &&
                (ff['input_name'] == 'cf_epf_no' ||
                    ff['input_name'] == 'cf_epf'),
            orElse: () => null,
          );
          if (f is Map && f['input_value'] != null)
            epf = f['input_value'].toString();
        }
      } else if (leave['customfields'] is List) {
        final fields = List.from(leave['customfields']);
        final f = fields.firstWhere(
          (ff) =>
              ff is Map &&
              (ff['input_name'] == 'cf_epf_no' || ff['input_name'] == 'cf_epf'),
          orElse: () => null,
        );
        if (f is Map && f['input_value'] != null)
          epf = f['input_value'].toString();
      }
    } catch (_) {
      epf = '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final sheetHeight = MediaQuery.of(context).size.height *
            0.80; // fixed height (75% of screen)
        return Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: _g12, bottom: _g8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(_g16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          status == 'approved'
                              ? Icons.check_circle_outline
                              : status == 'rejected'
                                  ? Icons.cancel_outlined
                                  : Icons.pending_outlined,
                          color: statusColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: _g12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              _getLeaveTypeLabel(context, type),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: _g4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: _g8, vertical: _g4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AutoSizeText(
                                status == 'approved'
                                    ? AppLocalizations.of(context)!
                                        .approvedLable
                                        .toUpperCase()
                                    : status == 'rejected'
                                        ? AppLocalizations.of(context)!
                                            .rejectedLable
                                            .toUpperCase()
                                        : AppLocalizations.of(context)!
                                            .pendindingLable
                                            .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Employee info
                Padding(
                  padding: const EdgeInsets.all(_g16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        AppLocalizations.of(context)!.employeeDetails,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: _g12),
                      Container(
                        padding: const EdgeInsets.all(_g12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 20, color: Colors.black54),
                            const SizedBox(width: _g12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    employeeName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: _g4),
                                  AutoSizeText(
                                    leave['employeeName'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (epf.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    AutoSizeText('EPF',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54)),
                                    const SizedBox(height: 2),
                                    AutoSizeText(epf,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Leave details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _g16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        AppLocalizations.of(context)!.leaveDetails,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: _g12),
                      Container(
                        padding: const EdgeInsets.all(_g12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.black54),
                                const SizedBox(width: _g12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        AppLocalizations.of(context)!
                                            .leaveDuration,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: _g4),
                                      AutoSizeText(
                                        '${dates.length} ${dates.length > 1 ? AppLocalizations.of(context)!.daysLabel : AppLocalizations.of(context)!.days}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: _g12),
                            Row(
                              children: [
                                const Icon(Icons.event_note,
                                    size: 18, color: Colors.black54),
                                const SizedBox(width: _g12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        AppLocalizations.of(context)!
                                            .leaveTypeLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: _g4),
                                      AutoSizeText(
                                        _getLeaveTypeLabel(context, type),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Dates list
                if (dates.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_g16, _g16, _g16, _g8),
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.leaveDates,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Full width container (occupies the available sheet width)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: _g12, left: _g16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: _g16, vertical: _g12),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      // Wrap will flow to multiple lines; this makes the area expand full width
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dates.map<Widget>((date) {
                          final label = FormatUtils.dateFromUnixSeconds(date);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: AutoSizeText(
                              label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],

                // Reason
                if (reason.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_g16, _g16, _g16, _g8),
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.reason,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: _g16),
                    padding: const EdgeInsets.all(_g12),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AutoSizeText(
                      reason,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: _g16),

                // Action buttons for pending leaves
                if (isPending) ...[
                  Padding(
                    padding: const EdgeInsets.all(_g16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showRejectConfirmation(
                                  context, leaveId, employeeName);
                            },
                            icon: const Icon(Icons.close, size: 18),
                            label: AutoSizeText(
                                AppLocalizations.of(context)!.rejectedLable),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding:
                                  const EdgeInsets.symmetric(vertical: _g12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: _g12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showApproveConfirmation(
                                  context, leaveId, employeeName);
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: AutoSizeText(
                                AppLocalizations.of(context)!.approvedLable),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding:
                                  const EdgeInsets.symmetric(vertical: _g12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: _g24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApproveConfirmation(
      BuildContext context, String leaveId, String employeeName) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              AutoSizeText("Approve Leave",
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          const TextSpan(
                              text: "Are you sure you want to approve "),
                          TextSpan(
                            text: employeeName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.green),
                          ),
                          const TextSpan(text: "'s leave request?"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: _g12),
                ],
              ),
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(_g12, 8, _g12, _g12),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: AutoSizeText('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _approveLeave(leaveId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: AutoSizeText('Approve',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRejectConfirmation(
      BuildContext context, String leaveId, String employeeName) {
    _reasonController.clear();
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isValid = _reasonController.text.trim().isNotEmpty;
            return AlertDialog(
              backgroundColor:
                  _surface, // use page surface color for popup background
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: Colors.red),
                  const SizedBox(width: 8),
                  AutoSizeText("Reject Leave",
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              const TextSpan(
                                  text: "Are you sure you want to reject "),
                              TextSpan(
                                text: employeeName,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: HRColors.darkOrangeColor),
                              ),
                              const TextSpan(text: "'s leave request?"),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: _g12),

                      // Small boxed reason input with background using _surface
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          maxLength: 300,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Reason for rejection *',
                            counterText: '',
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),

                      const SizedBox(height: _g8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          '${_reasonController.text.trim().length}/300',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: EdgeInsets.fromLTRB(_g12, 8, _g12, _g12),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: AutoSizeText('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isValid
                      ? () {
                          final reason = _reasonController.text.trim();
                          Navigator.of(ctx).pop();
                          _rejectLeave(leaveId, reason);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.red.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: AutoSizeText('Reject',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getLeaveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getLeaveTypeLabel(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;

    switch (type.toLowerCase()) {
      case 'casual':
        return l10n.casualLabel;

      case 'nopay':
        return l10n.nopayLabel; // ⚠️ add this in ARB

      case 'sick':
        return l10n.medicalLabel; // already exists

      case 'annual':
        return l10n.annualLabel;

      default:
        return type;
    }
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave, int index) {
    final l10n = AppLocalizations.of(context)!;

    final dates = leave['dates'] as List? ?? [];
    final status = (leave['status'] ?? 'pending').toString().toLowerCase();
    final type = leave['type'] ?? 'casual';
    final leaveId = leave['_id'] ?? '';
    final employeeName =
        leave['employeeName']?.toString().split('(')[0].trim() ?? 'Employee';

    String epf = '';
    if (leave['epf'] != null) {
      epf = leave['epf'].toString();
    } else {
      final match = RegExp(r"\(([^)]+)\)")
          .firstMatch(leave['employeeName']?.toString() ?? '');
      if (match != null) epf = match.group(1) ?? '';
    }

    final isPending = status == 'pending';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';
    final animation = _leaveAnimationControllers[index];

    IconData trailingIcon;
    Color trailingBg;
    Color trailingFg;
    Color statusColor = _getLeaveStatusColor(status);

    if (isApproved) {
      trailingIcon = Icons.check_rounded;
      trailingBg = Colors.green.withOpacity(0.12);
      trailingFg = Colors.green;
    } else if (isRejected) {
      trailingIcon = Icons.close_rounded;
      trailingBg = Colors.red.withOpacity(0.12);
      trailingFg = Colors.red;
    } else {
      trailingIcon = Icons.hourglass_bottom_rounded;
      trailingBg = Colors.orange.withOpacity(0.14);
      trailingFg = Colors.orange.shade800;
    }

    final String dateText =
        '${dates.length} ${dates.length > 1 ? l10n.daysLabel : 'day'}';

    Widget card = Container(
      margin: const EdgeInsets.symmetric(horizontal: _g12, vertical: _g6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Slidable(
          key: ValueKey(leaveId),
          enabled: isPending,
          startActionPane: isPending
              ? ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.6,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _showApproveConfirmation(
                        context,
                        leaveId,
                        employeeName,
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.check,
                      label: l10n.approvedLable,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                  ],
                )
              : null,
          endActionPane: isPending
              ? ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.26,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _showRejectConfirmation(
                        context,
                        leaveId,
                        employeeName,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.close,
                      label: l10n.rejectedLable,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                  ],
                )
              : null,
          child: Material(
            color: _surface,
            child: InkWell(
              onTap: () => _showLeaveDetailsBottomSheet(leave),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            _getLeaveTypeLabel(context, type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (employeeName.isNotEmpty) ...[
                            AutoSizeText(
                              epf.isNotEmpty
                                  ? '$employeeName ($epf)'
                                  : employeeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 5),
                              AutoSizeText(
                                dateText,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AutoSizeText(
                            status == 'approved'
                                ? l10n.approvedLable.toUpperCase()
                                : status == 'rejected'
                                    ? l10n.rejectedLable.toUpperCase()
                                    : l10n.pendindingLable.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        if (isPending) ...[
                          const SizedBox(height: 10),
                          const Icon(
                            Icons.swipe_left_rounded,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (animation != null && !animation.isDismissed) {
      card = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildAttendanceCard(Map<String, dynamic> attendance, int index) {
    final date = attendance['date'] ?? 0;
    final checkIn = attendance['checkIn'] ?? '';
    final checkOut = attendance['checkOut'] ?? '';
    final status = attendance['status'] ?? 'pending';
    final workHoursDisplay = attendance['workHoursDisplay'] ?? '';
    final memberName = attendance['memberName'] ?? '';

    final formattedDate = FormatUtils.dateFromUnixSeconds(date);

    // Determine if it's truly pending or partially marked
    final bool hasCheckIn = checkIn.isNotEmpty;
    final bool hasCheckOut = checkOut.isNotEmpty;
    final bool isFullyPresent = hasCheckIn && hasCheckOut;

    bool needsMarking = !isFullyPresent;

    String statusText = 'PENDING';
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.edit_calendar;

    if (isFullyPresent) {
      statusText = 'PRESENT';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
      needsMarking = false;
    } else if (hasCheckIn && !hasCheckOut) {
      statusText = 'IN ONLY';
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.login;
    } else if (!hasCheckIn && hasCheckOut) {
      statusText = 'OUT ONLY';
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.logout;
    }

    // Card Content
    Widget cardContent = GestureDetector(
      onTap: needsMarking ? () => _showMarkAttendanceDialog(attendance) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: _g12, vertical: _g6),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: needsMarking
                ? Colors.orange.withOpacity(0.4)
                : Colors.black.withOpacity(0.05),
            width: needsMarking ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(_g12),
          child: Row(
            children: [
              // Status Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: _g12),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date + Member Name (when All selected)
                    AutoSizeText(
                      _selectedUserId == null && memberName.isNotEmpty
                          ? '$formattedDate • $memberName'
                          : formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: _g4),

                    // Show IN / OUT if available (This is the main change you wanted)
                    if (hasCheckIn || hasCheckOut)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (hasCheckIn)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: AutoSizeText(
                                '${AppLocalizations.of(context)!.checkIn} $checkIn',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          if (hasCheckOut)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: AutoSizeText(
                                '${AppLocalizations.of(context)!.checkOut} $checkOut',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          if (workHoursDisplay.isNotEmpty && isFullyPresent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: AutoSizeText(
                                workHoursDisplay,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      AutoSizeText(
                        'Tap to mark attendance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // Status Badge
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //   decoration: BoxDecoration(
              //     color: statusColor.withOpacity(0.12),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: AutoSizeText(
              //     statusText,
              //     style: TextStyle(
              //       fontSize: 11,
              //       fontWeight: FontWeight.w700,
              //       color: statusColor,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );

    // Animation wrapper
    final animation = _attendanceAnimationControllers[index];
    if (animation != null && !animation.isDismissed) {
      cardContent = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(
          opacity: animation,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loadingTeam) {
      body = Center(
          child: CupertinoActivityIndicator(
              radius: 16.0, color: HRColors.darkOrangeColor));
    } else if (_teamError != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(_g16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(_teamError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: _g12),
              ElevatedButton(
                  onPressed: _loadTeamData,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: HRColors.orangeColor),
                  child: AutoSizeText('Retry')),
            ],
          ),
        ),
      );
    } else {
      body = TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
              onRefresh: _loadMemberLeaves, child: _buildLeavesContent()),
          RefreshIndicator(
              onRefresh: _loadMemberAttendance,
              child: _buildAttendanceContent()),
        ],
      );
    }

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_g12, _g16, _g12, _g8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            HRColors.flavorIconBackgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Icon(Icons.navigate_before,
                          color: HRColors.flavorIconColor),
                    ),
                  ),
                  const SizedBox(width: _g12),
                  Expanded(
                    child: AutoSizeText(AppLocalizations.of(context)!.myTeam,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _g12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _g12),
              child: Container(
                padding: const EdgeInsets.all(_g12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.selectTeamMember,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: _g8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedUserId == null
                              ? null
                              : (_teamMembers.any((m) =>
                                      (m['_id'] ?? m['id'])?.toString() ==
                                      _selectedUserId)
                                  ? _selectedUserId
                                  : null),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          menuMaxHeight: 320,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.black54,
                            ),
                          ),
                          selectedItemBuilder: (context) {
                            return [
                              // Selected view for "All team members"
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        HRColors.darkOrangeColor.withOpacity(0.12),
                                    child: Icon(
                                      Icons.group,
                                      size: 18,
                                      color: HRColors.darkOrangeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          AppLocalizations.of(context)!
                                              .allTeamMembers,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        AutoSizeText(
                                          '${_teamMembers.length} ${AppLocalizations.of(context)!.members}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Selected view for each member
                              ..._teamMembers.map<Widget>((member) {
                                final m = member as Map<String, dynamic>;
                                final name = _getMemberName(m);
                                final epf = _getMemberEPF(m);

                                String initials() {
                                  final parts = name
                                      .trim()
                                      .split(' ')
                                      .where((e) => e.isNotEmpty)
                                      .toList();
                                  if (parts.length >= 2) {
                                    return '${parts[0][0]}${parts[1][0]}'
                                        .toUpperCase();
                                  }
                                  if (name.isNotEmpty) return name[0].toUpperCase();
                                  return '?';
                                }

                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.blueGrey.shade50,
                                      child: AutoSizeText(
                                        initials(),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(
                                            name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (epf.isNotEmpty)
                                            AutoSizeText(
                                              'EPF: $epf',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ];
                          },
                          onChanged: (selected) {
                            setState(() {
                              _selectedUserId = selected;
                              _selectedUserLabel = selected == null
                                  ? 'All'
                                  : _getMemberName(
                                      (_teamMembers.firstWhere(
                                        (m) =>
                                            (m['_id'] ?? m['id'])?.toString() ==
                                            selected,
                                        orElse: () => <String, dynamic>{},
                                      ) as Map<String, dynamic>),
                                    );
                            });
                            _loadTabData();
                          },
                          items: <DropdownMenuItem<String?>>[
                            // Opened menu item for "All team members"
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        HRColors.darkOrangeColor.withOpacity(0.12),
                                    child: Icon(
                                      Icons.group,
                                      color: HRColors.darkOrangeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          AppLocalizations.of(context)!
                                              .allTeamMembers,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        AutoSizeText(
                                          '${_teamMembers.length} ${AppLocalizations.of(context)!.members}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedUserId == null)
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                ],
                              ),
                            ),

                            // Opened menu items for members
                            ..._teamMembers.map<DropdownMenuItem<String?>>((member) {
                              final m = member as Map<String, dynamic>;
                              final id = (m['_id'] ?? m['id'])?.toString();
                              final name = _getMemberName(m);
                              final epf = _getMemberEPF(m);

                              String initials() {
                                final parts = name
                                    .trim()
                                    .split(' ')
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                                if (parts.length >= 2) {
                                  return '${parts[0][0]}${parts[1][0]}'
                                      .toUpperCase();
                                }
                                if (name.isNotEmpty) return name[0].toUpperCase();
                                return '?';
                              }

                              return DropdownMenuItem<String?>(
                                value: id,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.blueGrey.shade50,
                                      child: AutoSizeText(
                                        initials(),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(
                                            name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (epf.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            AutoSizeText(
                                              'EPF: $epf',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (id != null && id == _selectedUserId)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: _g12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.transparent,
                        // Make the indicator span the full tab and give it some horizontal padding
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        indicator: BoxDecoration(
                          color: HRColors.tabColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: HRColors.tabLabelColor,
                        unselectedLabelColor: Colors.black54,
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.teamLeavesText),
                          Tab(text: AppLocalizations.of(context)!.teamAttendanceText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _g12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _buildLeavesContent() {
    if (_loadingLeaves) {
      return Center(
          child: CupertinoActivityIndicator(
              radius: 16.0, color: HRColors.darkOrangeColor));
    }
    if (_leaveError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText(_leaveError!,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: _g12),
            ElevatedButton(
                onPressed: _loadMemberLeaves,
                style: ElevatedButton.styleFrom(
                    backgroundColor: HRColors.orangeColor),
                child: AutoSizeText('Retry')),
          ],
        ),
      );
    }
    if (_leaveData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            AutoSizeText('No leave records found',
                style: TextStyle(color: Colors.black54))
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: _leaveData.length,
      itemBuilder: (context, index) =>
          _buildLeaveCard(_leaveData[index], index),
    );
  }

  Widget _buildAttendanceContent() {
    if (_loadingAttendance) {
      return Center(
          child: CupertinoActivityIndicator(
              radius: 16.0, color: HRColors.darkOrangeColor));
    }
    if (_attendanceError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoSizeText(_attendanceError!,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: _g12),
            ElevatedButton(
              onPressed: _loadMemberAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: HRColors.orangeColor,
              ),
              child: AutoSizeText('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: _g12, vertical: _g8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: _surface,
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              AutoSizeText(
                '${_selectedMonth.year} - ${_selectedMonth.month.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: _surface,
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _attendanceData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      AutoSizeText(
                        '${AppLocalizations.of(context)!.noRecords} ${_selectedMonth.year} - ${_selectedMonth.month.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: _attendanceData.length,
                  itemBuilder: (context, index) =>
                      _buildAttendanceCard(_attendanceData[index], index),
                ),
        ),
      ],
    );
  }
}
