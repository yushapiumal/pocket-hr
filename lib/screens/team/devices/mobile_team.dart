import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';
import 'package:cn_pocket_hr/helpers/format_utils.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';

class MobileTeam extends StatefulWidget {
//  final String ownerId;

  const MobileTeam({
    Key? key,
  }) : super(key: key);

  @override
  State<MobileTeam> createState() => _MobileTeamState();
}

class _MobileTeamState extends State<MobileTeam> with TickerProviderStateMixin {
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

  // Animation controllers for list items
  final Map<int, AnimationController> _leaveAnimationControllers = {};
  final Map<int, AnimationController> _attendanceAnimationControllers = {};
  String? _expandedLeaveId;

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

  void showTopToast(
    String message, {
    Color? background,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);

    final animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final animation =
        CurvedAnimation(parent: animController, curve: Curves.easeOut);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 12,
          right: 12,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  try {
                    animController.reverse();
                  } catch (_) {}
                  try {
                    entry.remove();
                  } catch (_) {}
                  try {
                    animController.dispose();
                  } catch (_) {}
                  if (onTap != null) onTap();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: background ?? const Color(0xFF323232),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          message,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    animController.forward();

    Future.delayed(duration, () async {
      try {
        await animController.reverse();
      } catch (_) {}
      try {
        entry.remove();
      } catch (_) {}
      try {
        animController.dispose();
      } catch (_) {}
    });
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
          _selectedUserId = null;
          _selectedUserLabel = "All";
        });

        _loadTabData();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showTopToast(
            AppLocalizations.of(context)!.teamDataLoadedSuccessfully,
            background: Colors.green,
          );
        });
      } else {
        throw Exception(
          response['message']?.toString() ??
              AppLocalizations.of(context)!.failedToLoadTeamData,
        );
      }
    } catch (e, st) {
      debugPrint('[TEAM][ERROR] $e');
      debugPrint('$st');

      setState(() {
        _teamError = e.toString();
        _loadingTeam = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showTopToast(
          AppLocalizations.of(context)!.errorPrefix(e.toString()),
          background: Colors.red,
        );
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

  String _getMemberNickname(Map<String, dynamic> member) {
    final fields = member['customfields'] ?? [];
    try {
      final nickname = fields.firstWhere(
            (f) => f['input_name'] == 'cf_nickname',
            orElse: () => {},
          )['input_value'] ??
          '';
      if (nickname.toString().trim().isNotEmpty) {
        return nickname.toString().trim();
      }
    } catch (_) {}

    try {
      final firstName = fields.firstWhere(
            (f) => f['input_name'] == 'cf_first_name',
            orElse: () => {},
          )['input_value'] ??
          '';
      if (firstName.toString().trim().isNotEmpty) {
        return firstName.toString().trim();
      }
    } catch (_) {}

    return _getMemberName(member).split(' ').first;
  }

  Map<String, dynamic>? _findMember(String? userId, String? epf) {
    if (_teamMembers.isEmpty) return null;
    for (var member in _teamMembers) {
      if (member is! Map<String, dynamic>) continue;
      final id = (member['_id'] ?? member['id'])?.toString();
      final mEpf = _getMemberEPF(member);
      if ((userId != null && id == userId) || (epf != null && epf.isNotEmpty && mEpf == epf)) {
        return member;
      }
    }
    return null;
  }

  Widget _buildMemberNameAndEpf(String nickname, String epf, String fullName, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.black87,
              ),
            ),
            if (epf.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: HRColors.orangeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AutoSizeText(
                  epf,
                  style: TextStyle(
                    color: HRColors.orangeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (fullName.isNotEmpty) ...[
          const SizedBox(height: 2),
          AutoSizeText(
            fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ],
    );
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

      int? minInEpoch;
      int? maxOutEpoch;

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
        if (epoch == null || epoch <= 0) continue;

        if (type == 'in' || type == 'checkin' || type == 'inward') {
          if (minInEpoch == null || epoch < minInEpoch) minInEpoch = epoch;
        } else if (type == 'out' || type == 'checkout' || type == 'outward') {
          if (maxOutEpoch == null || epoch > maxOutEpoch) maxOutEpoch = epoch;
        } else {
          if (minInEpoch == null) minInEpoch = epoch;
          else if (maxOutEpoch == null || epoch > maxOutEpoch) maxOutEpoch = epoch;
        }
      }

      if (minInEpoch != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(minInEpoch * 1000);
        checkIn =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      if (maxOutEpoch != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(maxOutEpoch * 1000);
        checkOut =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
        final dynamic epfRaw = record['epf'];
        final int? epf = epfRaw == null
            ? null
            : (epfRaw is int ? epfRaw : int.tryParse(epfRaw.toString()));

        // Filter by selected user (if not "All")
        if (_selectedUserId != null && userId != _selectedUserId) {
          continue;
        }

        // Extract check-in and check-out
        String? checkIn;
        String? checkOut;
        DateTime? attendanceDate;

        int? firstInTimestamp;
        int? lastOutTimestamp;

        // Check top-level record fields if provided by API
        final dynamic topFirstIn = record['firstCheckIn'] ?? record['first_check_in'];
        if (topFirstIn != null) {
          firstInTimestamp = (topFirstIn is num) ? topFirstIn.toInt() : int.tryParse(topFirstIn.toString());
        }
        final dynamic topLastOut = record['lastCheckOut'] ?? record['last_check_out'];
        if (topLastOut != null) {
          lastOutTimestamp = (topLastOut is num) ? topLastOut.toInt() : int.tryParse(topLastOut.toString());
        }

        final List<dynamic> attList = record['attendance'] ?? [];

        for (var att in attList) {
          if (att is! Map<String, dynamic>) continue;

          final String type = (att['type'] ?? '').toString().toLowerCase();
          final dynamic timeVal = att['time'] ?? att['timestamp'];

          if (timeVal == null) continue;

          final int timestamp = (timeVal is num)
              ? timeVal.toInt()
              : int.tryParse(timeVal.toString()) ?? 0;
          if (timestamp <= 0) continue;

          final DateTime dt =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

          attendanceDate ??= DateTime(dt.year, dt.month, dt.day);

          if (type == 'in' || type == 'checkin' || type == 'inward') {
            if (firstInTimestamp == null || timestamp < firstInTimestamp) {
              firstInTimestamp = timestamp;
            }
          } else if (type == 'out' || type == 'checkout' || type == 'outward') {
            if (lastOutTimestamp == null || timestamp > lastOutTimestamp) {
              lastOutTimestamp = timestamp;
            }
          }
        }

        if (firstInTimestamp != null && firstInTimestamp > 0) {
          final dtIn = DateTime.fromMillisecondsSinceEpoch(firstInTimestamp * 1000);
          checkIn = '${dtIn.hour.toString().padLeft(2, '0')}:${dtIn.minute.toString().padLeft(2, '0')}';
          attendanceDate ??= DateTime(dtIn.year, dtIn.month, dtIn.day);
        }
        if (lastOutTimestamp != null && lastOutTimestamp > 0) {
          final dtOut = DateTime.fromMillisecondsSinceEpoch(lastOutTimestamp * 1000);
          checkOut = '${dtOut.hour.toString().padLeft(2, '0')}:${dtOut.minute.toString().padLeft(2, '0')}';
          attendanceDate ??= DateTime(dtOut.year, dtOut.month, dtOut.day);
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

  Future<void> _approveLeave(String leaveId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CupertinoActivityIndicator(
            radius: 16.0,
            color: HRColors.darkOrangeColor,
          ),
        ),
      );

      final response = await _apiService.approveLeave(leaveId);

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        showTopToast(
          AppLocalizations.of(context)!.leaveApproved,
          background: Colors.green,
        );
        await _loadMemberLeaves();
      } else {
        showTopToast(
          response['message']?.toString() ??
              AppLocalizations.of(context)!.leaveApproveFailed,
          background: Colors.red,
        );
      }
    } catch (e, st) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('[APPROVE][ERROR] $e');
      debugPrint('$st');

      showTopToast(
        AppLocalizations.of(context)!.errorPrefix(e.toString()),
        background: Colors.red,
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
            radius: 16.0,
            color: HRColors.darkOrangeColor,
          ),
        ),
      );

      final response = await _apiService.rejectLeave(leaveId, reason);

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        showTopToast(
          AppLocalizations.of(context)!.leaveReject,
          background: Colors.orange,
        );
        await _loadMemberLeaves();
      } else {
        showTopToast(
          response['message']?.toString() ??
              AppLocalizations.of(context)!.leaveRejectFailed,
          background: Colors.red,
        );
      }
    } catch (e, st) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('[REJECT][ERROR] $e');
      debugPrint('$st');

      showTopToast(
        AppLocalizations.of(context)!.errorPrefix(e.toString()),
        background: Colors.red,
      );
    }
  }



  Future<bool?> _showApproveConfirmation(
      BuildContext context, String leaveId, String employeeName) {
    return showDialog<bool>(
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
              Text("Approve Leave",
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
              onPressed: () => Navigator.of(ctx).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showRejectConfirmation(
      BuildContext context, String leaveId, String employeeName) {
    _reasonController.clear();
    return showDialog<String>(
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
                  Text("Reject Leave",
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
                        child: Text(
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
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isValid
                      ? () {
                          final reason = _reasonController.text.trim();
                          Navigator.of(ctx).pop(reason);
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
                  child: Text('Reject', style: TextStyle(color: Colors.white)),
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
    final reason = leave['reason'] ?? '';

    String epf = '';
    if (leave['epf'] != null) {
      epf = leave['epf'].toString();
    } else {
      final match = RegExp(r"\(([^)]+)\)")
          .firstMatch(leave['employeeName']?.toString() ?? '');
      if (match != null) epf = match.group(1) ?? '';
    }

    final String? userId = leave['userId']?.toString();
    final member = _findMember(userId, epf);
    final String nickname = member != null ? _getMemberNickname(member) : employeeName;
    final String fullName = member != null ? _getMemberName(member) : employeeName;
    final String finalEpf = member != null ? _getMemberEPF(member) : epf;

    final isPending = status == 'pending';
    final animation = _leaveAnimationControllers[index];

    Color statusColor = _getLeaveStatusColor(status);

    final String dateText =
        '${dates.length} ${dates.length > 1 ? l10n.daysLabel : 'day'}';

    final bool isExpanded = _expandedLeaveId == leaveId;

    Widget card = Container(
      margin: const EdgeInsets.symmetric(horizontal: _g12, vertical: _g6),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.white : _surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isExpanded ? statusColor.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                  dismissible: DismissiblePane(
                    confirmDismiss: () async {
                      final confirmed = await _showApproveConfirmation(
                          context, leaveId, employeeName);
                      if (confirmed == true) await _approveLeave(leaveId);
                      return false;
                    },
                    onDismissed: () {},
                  ),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        Slidable.of(_)?.close();
                        final confirmed = await _showApproveConfirmation(
                          context,
                          leaveId,
                          employeeName,
                        );
                        if (confirmed == true) await _approveLeave(leaveId);
                      },
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
                  dismissible: DismissiblePane(
                    confirmDismiss: () async {
                      final reason = await _showRejectConfirmation(
                          context, leaveId, employeeName);
                      if (reason != null) await _rejectLeave(leaveId, reason);
                      return false;
                    },
                    onDismissed: () {},
                  ),
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        Slidable.of(_)?.close();
                        final reason = await _showRejectConfirmation(
                          context,
                          leaveId,
                          employeeName,
                        );
                        if (reason != null) await _rejectLeave(leaveId, reason);
                      },
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
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (_expandedLeaveId == leaveId) {
                    _expandedLeaveId = null;
                  } else {
                    _expandedLeaveId = leaveId;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      _getLeaveTypeLabel(context, type),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (nickname.isNotEmpty) ...[
                                _buildMemberNameAndEpf(
                                  nickname,
                                  finalEpf,
                                  fullName,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                            if (isPending && !isExpanded) ...[
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
                    if (isExpanded) ...[
                      const SizedBox(height: _g12),
                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: _g12),
                      if (dates.isNotEmpty) ...[
                        AutoSizeText(
                          l10n.leaveDates,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(_g12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                          ),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: dates.map<Widget>((date) {
                              final label = FormatUtils.dateFromUnixSeconds(date);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                                ),
                                child: AutoSizeText(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      if (reason.isNotEmpty) ...[
                        const SizedBox(height: _g12),
                        AutoSizeText(
                          l10n.reason,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(_g12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black.withOpacity(0.05)),
                          ),
                          child: AutoSizeText(
                            reason,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                      if (isPending) ...[
                        const SizedBox(height: _g16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final pageCtx = context;
                                  final rejectedReason = await _showRejectConfirmation(
                                      pageCtx, leaveId, employeeName);
                                  if (rejectedReason != null) {
                                    await _rejectLeave(leaveId, rejectedReason);
                                  }
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: AutoSizeText(
                                  l10n.rejectedLable,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: _g12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final pageCtx = context;
                                  final confirmed = await _showApproveConfirmation(
                                      pageCtx, leaveId, employeeName);
                                  if (confirmed == true) {
                                    await _approveLeave(leaveId);
                                  }
                                },
                                icon: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: AutoSizeText(
                                  l10n.approvedLable,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
    final workHoursDisplay = attendance['workHoursDisplay'] ?? '';
    final memberName = attendance['memberName'] ?? '';

    final String? userId = attendance['userId']?.toString();
    final String? epf = attendance['epf']?.toString();
    final member = _findMember(userId, epf);

    final formattedDate = FormatUtils.dateFromUnixSeconds(date);

    // Determine status
    final bool hasCheckIn = checkIn.isNotEmpty;
    final bool hasCheckOut = checkOut.isNotEmpty;
    final bool isFullyPresent = hasCheckIn && hasCheckOut;

    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.edit_calendar;

    if (isFullyPresent) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (hasCheckIn && !hasCheckOut) {
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.login;
    } else if (!hasCheckIn && hasCheckOut) {
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.logout;
    }

    // Card Content
    Widget cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: _g12, vertical: _g6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
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
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (_selectedUserId == null && memberName.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildMemberNameAndEpf(
                      member != null ? _getMemberNickname(member) : memberName,
                      member != null ? _getMemberEPF(member) : (epf ?? ''),
                      member != null ? _getMemberName(member) : memberName,
                    ),
                  ],
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
                      'No records',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
                              ..._teamMembers.where((member) {
                                final m = member as Map<String, dynamic>;
                                return (m['_id'] ?? m['id']) != null;
                              }).map<Widget>((member) {
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
                                      child: _buildMemberNameAndEpf(
                                        _getMemberNickname(m),
                                        epf,
                                        name,
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
                            ..._teamMembers.where((member) {
                              final m = member as Map<String, dynamic>;
                              final id = (m['_id'] ?? m['id'])?.toString();
                              return id != null;
                            }).map<DropdownMenuItem<String?>>((member) {
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
                                      child: _buildMemberNameAndEpf(
                                        _getMemberNickname(m),
                                        epf,
                                        name,
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
              child: AutoSizeText(AppLocalizations.of(context)!.retryLabel),
            )
          ],
        ),
      );
    }
    if (_leaveData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            AutoSizeText(AppLocalizations.of(context)!.noRecords,
                style: TextStyle(color: Colors.black54)),
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
