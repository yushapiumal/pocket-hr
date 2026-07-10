import 'package:auto_size_text/auto_size_text.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/models/hr/todo_model.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';



class TabletTodosScreen extends StatefulWidget {
  const TabletTodosScreen({super.key});

  @override
  State<TabletTodosScreen> createState() => _TabletTodosScreenState();
}

class _TabletTodosScreenState extends State<TabletTodosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final AutoSizeGroup _tabGroup = AutoSizeGroup();
  bool _loading = true;
  String? _error;
  List<TodoItem> _remoteAttendanceTodos = [];
  List<TodoItem> _otherTodos = [];

  static const double _g8 = 8;
  static const double _g16 = 16;
  static const double _g20 = 20;
  static const double _g24 = 24;

  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await APIService().getTodos(approvableByMe: true);
      setState(() {
        _remoteAttendanceTodos = results.where((e) => e.type == 'remote_attendance').toList();
        _otherTodos = results.where((e) => e.type != 'remote_attendance').toList();
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[TODOS][ERROR] $e');
      debugPrint('$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _approveTodoItem(String todoId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await APIService().approveTodo(todoId);
      
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        DesignConfig.showTopToast(
          context,
          AppLocalizations.of(context)!.todoApproveSuccess,
          background: Colors.green,
        );
        _load();
      } else {
        DesignConfig.showTopToast(
          context,
          response['message']?.toString() ?? AppLocalizations.of(context)!.todoApproveFailed,
          background: Colors.red,
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      DesignConfig.showTopToast(
        context,
        AppLocalizations.of(context)!.errorPrefix(e.toString()),
        background: Colors.red,
      );
    }
  }

  Future<void> _rejectTodoItem(String todoId, String reason) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await APIService().rejectTodo(todoId, reason);
      
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        DesignConfig.showTopToast(
          context,
          AppLocalizations.of(context)!.todoRejectSuccess,
          background: Colors.orange,
        );
        _load();
      } else {
        DesignConfig.showTopToast(
          context,
          response['message']?.toString() ?? AppLocalizations.of(context)!.todoRejectFailed,
          background: Colors.red,
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      DesignConfig.showTopToast(
        context,
        AppLocalizations.of(context)!.errorPrefix(e.toString()),
        background: Colors.red,
      );
    }
  }

  Future<bool?> _showApproveConfirmation(TodoItem item) {
    final employeeName = item.user?.name ?? 'Employee';
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.todoApproveTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
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
                    child: Text(
                      AppLocalizations.of(context)!.todoApproveConfirmMessage(employeeName),
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(AppLocalizations.of(context)!.cancelLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                AppLocalizations.of(context)!.approvedLable,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showRejectConfirmation(TodoItem item) {
    final reasonController = TextEditingController();
    final employeeName = item.user?.name ?? 'Employee';
    return showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isValid = reasonController.text.trim().isNotEmpty;
            return AlertDialog(
              backgroundColor: _surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.todoRejectTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
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
                        child: Text(
                          AppLocalizations.of(context)!.todoRejectConfirmMessage(employeeName),
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: TextField(
                          controller: reasonController,
                          maxLines: 3,
                          maxLength: 300,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.todoReasonHint,
                            counterText: '',
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${reasonController.text.trim().length}/300',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(AppLocalizations.of(context)!.cancelLabel),
                ),
                ElevatedButton(
                  onPressed: isValid
                      ? () {
                          final reason = reasonController.text.trim();
                          Navigator.of(ctx).pop(reason);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.red.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.rejectedLable,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTodoDetailsBottomSheet(TodoItem item) {
    if (item.type == 'remote_attendance') {
      _showRemoteAttendanceBottomSheet(item);
    } else if (item.type == 'profile_unlock') {
      _showProfileUnlockBottomSheet(item);
    } else {
      _showOtherTodoBottomSheet(item);
    }
  }

  String _formatDateTime(int? timestamp) {
    if (timestamp == null || timestamp <= 0) return '-';
    int milliseconds = timestamp;
    if (timestamp <= 9999999999) {
      milliseconds = timestamp * 1000;
    }
    final dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  void _showRemoteAttendanceBottomSheet(TodoItem item) {
    final statusColor = item.completed
        ? Colors.green
        : (item.waitingForPreviousStage ? Colors.red : Colors.orange);
    final isPending = !item.completed;
    final displayStatus = item.completed
        ? AppLocalizations.of(context)!.completedLabel
        : (item.waitingForPreviousStage
            ? AppLocalizations.of(context)!.todoWaitingForPreviousStage
            : AppLocalizations.of(context)!.todoPending);
    final l10n = AppLocalizations.of(context)!;
    final p = item.payload ?? {};

    final punchTypeRaw = p['type']?.toString().toUpperCase() ?? '-';
    String punchType = punchTypeRaw;
    Color punchColor = HRColors.orangeColor;
    IconData punchIcon = Icons.login;
    if (punchTypeRaw == 'CHECK_IN' || punchTypeRaw == 'CHECKIN' || punchTypeRaw == 'IN') {
      punchType = l10n.checkIn;
      punchColor = Colors.green;
      punchIcon = Icons.login;
    } else if (punchTypeRaw == 'CHECK_OUT' || punchTypeRaw == 'CHECKOUT' || punchTypeRaw == 'OUT') {
      punchType = l10n.checkOut;
      punchColor = Colors.blue;
      punchIcon = Icons.logout;
    }

    final checkedAtRaw = p['checked_at'];
    String checkedAt = '-';
    if (checkedAtRaw != null) {
      if (checkedAtRaw is int) {
        checkedAt = _formatDateTime(checkedAtRaw);
      } else if (checkedAtRaw is String) {
        final parsed = DateTime.tryParse(checkedAtRaw);
        if (parsed != null) {
          checkedAt = DateFormat('yyyy-MM-dd hh:mm a').format(parsed.toLocal());
        } else {
          checkedAt = checkedAtRaw;
        }
      } else {
        checkedAt = checkedAtRaw.toString();
      }
    }

    final rawAccuracy = p['location_accuracy'];
    String accuracy = '-';
    if (rawAccuracy != null) {
      final parsed = double.tryParse(rawAccuracy.toString());
      if (parsed != null) {
        accuracy = parsed.toStringAsFixed(2);
      } else {
        accuracy = rawAccuracy.toString();
      }
    }
    final battery = p['battery_level']?.toString() ?? '-';
    final lat = p['lat']?.toString() ?? '-';
    final lng = p['lng']?.toString() ?? '-';
    final deviceId = p['device_id']?.toString() ?? '-';

    final completedByJson = item.raw['completed_by'];
    TodoUser? completedBy = completedByJson is Map ? TodoUser.fromJson(Map<String, dynamic>.from(completedByJson)) : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.82;
        return Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.contains(':') ? item.title.split(':').first.trim() : item.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              displayStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, thickness: 1),
                      Text(
                        l10n.employeeDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildEmployeeCard(item),
                      const SizedBox(height: 24),
                      Text(
                        l10n.todoRequestDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: punchColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(punchIcon, size: 20, color: punchColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        punchType,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: punchColor),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.pin_drop_outlined, size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  item.zone,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1),
                            _buildInfoRow(Icons.schedule, l10n.todoDetailCheckedAt, checkedAt),
                            _buildInfoRow(Icons.devices, l10n.todoDetailDeviceId, deviceId),
                            _buildInfoRow(Icons.calendar_today_outlined, l10n.todoDetailRequestedAt, _formatDateTime(item.cts)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildBadge(Icons.my_location, l10n.todoDetailAccuracy, '$accuracy m'),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildBadge(Icons.battery_std, l10n.todoDetailBattery, '$battery%'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildClickableInfoRow(
                              Icons.map,
                              l10n.todoDetailCoordinates,
                              '$lat, $lng',
                              onTap: () async {
                                if (lat != '-' && lng != '-') {
                                  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                }
                              },
                            ),
                            if (completedBy != null) ...[
                              const Divider(height: 24, thickness: 1),
                              _buildInfoRow(
                                Icons.person_outline,
                                l10n.todoDetailCompletedBy,
                                completedBy.name,
                              ),
                              _buildInfoRow(Icons.done_all, l10n.todoDetailCompletedAt, _formatDateTime(item.uts)),
                            ],
                          ],
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.todoActionsTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: _buildActionButtons(item, ctx),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileUnlockBottomSheet(TodoItem item) {
    final statusColor = item.completed
        ? Colors.green
        : (item.waitingForPreviousStage ? Colors.red : Colors.orange);
    final isPending = !item.completed;
    final displayStatus = item.completed
        ? AppLocalizations.of(context)!.completedLabel
        : (item.waitingForPreviousStage
            ? AppLocalizations.of(context)!.todoWaitingForPreviousStage
            : AppLocalizations.of(context)!.todoPending);
    final l10n = AppLocalizations.of(context)!;
    final m = item.meta ?? {};
    final reason = m['reason']?.toString() ?? m['summary']?.toString() ?? '-';
    final summary = m['summary']?.toString() ?? '-';
    final action = m['action']?.toString() ?? '-';

    TodoUser? requestedForUser = item.user;
    if (requestedForUser == null && item.meta != null && item.meta!['user_id'] != null) {
      requestedForUser = TodoUser(
        id: item.meta!['user_id']?.toString() ?? '',
        name: item.meta!['user_name']?.toString() ?? item.meta!['user_email']?.toString() ?? '',
        email: item.meta!['user_email']?.toString() ?? '',
        epfPretty: item.meta!['user_epf_no']?.toString(),
      );
    }

    TodoUser? requestedByUser = item.by;
    if (requestedByUser == null && item.meta != null && item.meta!['requested_by_user_id'] != null) {
      requestedByUser = TodoUser(
        id: item.meta!['requested_by_user_id']?.toString() ?? '',
        name: item.meta!['requested_by_name']?.toString() ?? item.meta!['requested_by_email']?.toString() ?? '',
        email: item.meta!['requested_by_email']?.toString() ?? '',
        epfPretty: null,
      );
    }

    final completedByJson = item.raw['completed_by'];
    TodoUser? completedBy = completedByJson is Map ? TodoUser.fromJson(Map<String, dynamic>.from(completedByJson)) : null;
    final epfPretty = requestedForUser?.epfPretty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.82;
        return Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              displayStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, thickness: 1),
                      Text(
                        l10n.todoDetailRequestedFor,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, size: 24, color: Colors.black54),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    requestedForUser?.name ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (epfPretty != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('EPF', style: TextStyle(fontSize: 9, color: Colors.black54)),
                                    const SizedBox(height: 2),
                                    Text(epfPretty, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.todoRequestDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.layers_outlined, l10n.todoDetailCategory, item.type.toUpperCase()),
                            _buildInfoRow(Icons.pin_drop_outlined, l10n.todoDetailZone, item.zone),
                            _buildInfoRow(Icons.info_outline, l10n.todoDetailSummary, summary),
                            _buildInfoRow(Icons.touch_app_outlined, 'Action', action),
                            if (requestedByUser != null)
                              _buildInfoRow(
                                Icons.person,
                                l10n.todoDetailRequestedBy,
                                requestedByUser.name,
                              ),
                            _buildInfoRow(Icons.calendar_today_outlined, l10n.todoDetailRequestedAt, _formatDateTime(item.cts)),
                            if (completedBy != null) ...[
                              const Divider(height: 24, thickness: 1),
                              _buildInfoRow(
                                Icons.person_outline,
                                l10n.todoDetailCompletedBy,
                                completedBy.name,
                              ),
                              _buildInfoRow(Icons.done_all, l10n.todoDetailCompletedAt, _formatDateTime(item.uts)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.todoDetailReason,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.format_quote, color: Colors.orange, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.todoActionsTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: _buildActionButtons(item, ctx),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOtherTodoBottomSheet(TodoItem item) {
    final statusColor = item.completed
        ? Colors.green
        : (item.waitingForPreviousStage ? Colors.red : Colors.orange);
    final isPending = !item.completed;
    final displayStatus = item.completed
        ? AppLocalizations.of(context)!.completedLabel
        : (item.waitingForPreviousStage
            ? AppLocalizations.of(context)!.todoWaitingForPreviousStage
            : AppLocalizations.of(context)!.todoPending);
    final l10n = AppLocalizations.of(context)!;

    final completedByJson = item.raw['completed_by'];
    TodoUser? completedBy = completedByJson is Map ? TodoUser.fromJson(Map<String, dynamic>.from(completedByJson)) : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.82;
        return Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              displayStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, thickness: 1),
                      Text(
                        l10n.employeeDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildEmployeeCard(item),
                      const SizedBox(height: 24),
                      Text(
                        l10n.todoRequestDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.layers_outlined, l10n.todoDetailCategory, item.type.toUpperCase()),
                            _buildInfoRow(Icons.pin_drop_outlined, l10n.todoDetailZone, item.zone),
                            if (item.by != null)
                              _buildInfoRow(
                                Icons.person,
                                l10n.todoDetailRequestedBy,
                                item.by!.name,
                              ),
                            _buildInfoRow(Icons.calendar_today_outlined, l10n.todoDetailRequestedAt, _formatDateTime(item.cts)),
                            if (item.type == 'attendance' && item.meta != null) ...[
                              const Divider(height: 24, thickness: 1),
                              if (item.meta!['rates'] is Map) ...[
                                _buildInfoRow(
                                  Icons.lock_clock_outlined,
                                  l10n.todoDetailPunctualityIncentive,
                                  item.meta!['rates']['punctuality_incentive'] == true ? l10n.yesLabel : l10n.noLabel,
                                ),
                                _buildInfoRow(
                                  Icons.payments_outlined,
                                  l10n.todoDetailAttendanceAllowance,
                                  item.meta!['rates']['attendance_allowance'] == true ? l10n.yesLabel : l10n.noLabel,
                                ),
                              ] else ...[
                                _buildInfoRow(Icons.payments_outlined, l10n.todoDetailRatesInfo, item.meta!['rates']?.toString() ?? '-'),
                              ]
                            ],
                            if (completedBy != null) ...[
                              const Divider(height: 24, thickness: 1),
                              _buildInfoRow(
                                Icons.person_outline,
                                l10n.todoDetailCompletedBy,
                                completedBy.name,
                              ),
                              _buildInfoRow(Icons.done_all, l10n.todoDetailCompletedAt, _formatDateTime(item.uts)),
                            ],
                          ],
                        ),
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.todoActionsTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: _buildActionButtons(item, ctx),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmployeeCard(TodoItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 24, color: Colors.black54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  item.user?.name ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (item.user?.epfPretty != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('EPF', style: TextStyle(fontSize: 9, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(item.user!.epfPretty!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black38),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableInfoRow(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black38),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              color: HRColors.orangeColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: HRColors.orangeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new,
                          size: 15,
                          color: HRColors.orangeColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TodoItem item, BuildContext ctx) {
    final l10n = AppLocalizations.of(context)!;
    final isEnabled = !item.waitingForPreviousStage;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isEnabled ? () async {
              final navigator = Navigator.of(ctx);
              final reason = await _showRejectConfirmation(item);
              if (reason != null) {
                navigator.pop();
                await _rejectTodoItem(item.id, reason);
              }
            } : null,
            icon: const Icon(Icons.close, size: 20),
            label: AutoSizeText(
              l10n.rejectedLable,
              style: const TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isEnabled ? Colors.red : Colors.grey,
              side: BorderSide(color: isEnabled ? Colors.red : Colors.grey),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isEnabled ? () async {
              final navigator = Navigator.of(ctx);
              final confirmed = await _showApproveConfirmation(item);
              if (confirmed == true) {
                navigator.pop();
                await _approveTodoItem(item.id);
              }
            } : null,
            icon: Icon(Icons.check, size: 20, color: isEnabled ? Colors.white : Colors.grey),
            label: AutoSizeText(
              l10n.approvedLable,
              style: TextStyle(color: isEnabled ? Colors.white : Colors.grey, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? Colors.green : Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabBody(List<TodoItem> list) {
    if (list.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.black26),
                  const SizedBox(height: 20),
                  AutoSizeText(
                    AppLocalizations.of(context)!.noTodosFound,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 14,
                    style: const TextStyle(color: Colors.black45, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 40),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = list[i];
        return TodoCardWidget(
          item: item,
          onTap: () => _showTodoDetailsBottomSheet(item),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              AutoSizeText(
                AppLocalizations.of(context)!.failedToLoadTodos,
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 14,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              AutoSizeText(
                _error!,
                textAlign: TextAlign.center,
                maxLines: 4,
                minFontSize: 12,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HRColors.orangeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: AutoSizeText(
                  AppLocalizations.of(context)!.retryLabel,
                  maxLines: 1,
                  minFontSize: 12,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = TabBarView(
        controller: _tab,
        children: [
          RefreshIndicator(
            onRefresh: _load,
            child: _tabBody(_remoteAttendanceTodos),
          ),
          RefreshIndicator(
            onRefresh: _load,
            child: _tabBody(_otherTodos),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_g16, _g20, _g16, _g8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: HRColors.flavorIconBackgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Icon(Icons.navigate_before, color: HRColors.flavorIconColor, size: 28),
                    ),
                  ),
                  const SizedBox(width: _g16),
                  Expanded(
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.todos,
                      maxLines: 1,
                      minFontSize: 20,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _g20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _g16),
              child: Container(
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: TabBar(
                  controller: _tab,
                  dividerColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(6),
                  indicator: BoxDecoration(
                    color: HRColors.orangeColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.todoTabRemoteAttendance,
                        maxLines: 1,
                        minFontSize: 14,
                        group: _tabGroup,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Tab(
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.todoTabOthers,
                        maxLines: 1,
                        minFontSize: 14,
                        group: _tabGroup,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _g24),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

class TodoCardWidget extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onTap;

  const TodoCardWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  String _formatDateTime(int? timestamp) {
    if (timestamp == null || timestamp <= 0) return '-';
    int milliseconds = timestamp;
    if (timestamp <= 9999999999) {
      milliseconds = timestamp * 1000;
    }
    final dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor = Colors.orange.shade100;
    Color textColor = Colors.orange.shade800;
    
    if (item.completed) {
      badgeColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else if (item.waitingForPreviousStage) {
      badgeColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    }

    final String displayStatus = item.completed
        ? AppLocalizations.of(context)!.completedLabel
        : (item.waitingForPreviousStage
            ? AppLocalizations.of(context)!.todoWaitingForPreviousStage
            : AppLocalizations.of(context)!.todoPending);

    IconData typeIcon = Icons.assignment_outlined;
    if (item.type == 'remote_attendance') {
      typeIcon = Icons.fingerprint;
    } else if (item.type == 'profile_unlock') {
      typeIcon = Icons.lock_open_outlined;
    } else if (item.type == 'attendance') {
      typeIcon = Icons.calendar_today_outlined;
    }

    final String userName = item.user?.name ?? 'Unknown User';
    final String epfString = item.user?.epfPretty != null ? 'EPF: ${item.user!.epfPretty}' : '';

    String punchDetails = '';
    if (item.type == 'remote_attendance' && item.payload != null) {
      final punchType = item.payload!['type']?.toString().toUpperCase() ?? '';
      if (punchType.isNotEmpty) {
        punchDetails = 'Punch: $punchType';
      }
    }

    final cardWidget = Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      color: const Color.fromARGB(255, 248, 250, 252),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HRColors.orangeColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: HRColors.orangeColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            userName,
                            minFontSize: 13,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AutoSizeText(
                            displayStatus,
                            maxLines: 1,
                            minFontSize: 10,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (epfString.isNotEmpty)
                          AutoSizeText(
                            epfString,
                            maxLines: 1,
                            minFontSize: 12,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        if (punchDetails.isNotEmpty)
                          AutoSizeText(
                            punchDetails,
                            maxLines: 1,
                            minFontSize: 12,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: Colors.black38),
                            const SizedBox(width: 6),
                            AutoSizeText(
                              _formatDateTime(item.cts),
                              maxLines: 1,
                              minFontSize: 10,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: cardWidget,
    );
  }
}
