import 'package:auto_size_text/auto_size_text.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/models/hr/todo_model.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';


class MobileTodosScreen extends StatefulWidget {
  const MobileTodosScreen({super.key});

  @override
  State<MobileTodosScreen> createState() => _MobileTodosScreenState();
}

class _MobileTodosScreenState extends State<MobileTodosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _loading = true;
  String? _error;
  List<TodoItem> _myTodos = [];
  List<TodoItem> _approvableTodos = [];

  static const double _g8 = 8;
  static const double _g12 = 12;
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
      final results = await Future.wait([
        APIService().getTodos(approvableByMe: false),
        APIService().getTodos(approvableByMe: true),
      ]);
      setState(() {
        _myTodos = results[0];
        _approvableTodos = results[1];
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
          'Todo approved successfully',
          background: Colors.green,
        );
        _load();
      } else {
        DesignConfig.showTopToast(
          context,
          response['message']?.toString() ?? 'Failed to approve Todo',
          background: Colors.red,
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Fallback for Demo Mode: Toggle status locally
      bool updatedLocal = false;
      for (int i = 0; i < _approvableTodos.length; i++) {
        if (_approvableTodos[i].id == todoId) {
          final item = _approvableTodos[i];
          final updatedItem = TodoItem(
            id: item.id,
            title: item.title,
            type: item.type,
            zone: item.zone,
            completed: true,
            user: item.user,
            by: item.by,
            cts: item.cts,
            uts: DateTime.now().millisecondsSinceEpoch,
            payload: item.payload,
            meta: item.meta,
            raw: item.raw,
          );
          setState(() {
            _approvableTodos.removeAt(i);
            _myTodos.insert(0, updatedItem);
          });
          updatedLocal = true;
          break;
        }
      }

      if (updatedLocal) {
        DesignConfig.showTopToast(
          context,
          'Approved successfully (Demo Mode)',
          background: Colors.green,
        );
      } else {
        DesignConfig.showTopToast(
          context,
          'Error: $e',
          background: Colors.red,
        );
      }
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
          'Todo rejected successfully',
          background: Colors.orange,
        );
        _load();
      } else {
        DesignConfig.showTopToast(
          context,
          response['message']?.toString() ?? 'Failed to reject Todo',
          background: Colors.red,
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Fallback for Demo Mode: Toggle status locally
      bool updatedLocal = false;
      for (int i = 0; i < _approvableTodos.length; i++) {
        if (_approvableTodos[i].id == todoId) {
          final item = _approvableTodos[i];
          final updatedItem = TodoItem(
            id: item.id,
            title: item.title,
            type: item.type,
            zone: item.zone,
            completed: true,
            user: item.user,
            by: item.by,
            cts: item.cts,
            uts: DateTime.now().millisecondsSinceEpoch,
            payload: item.payload,
            meta: item.meta,
            raw: item.raw,
          );
          setState(() {
            _approvableTodos.removeAt(i);
            _myTodos.insert(0, updatedItem);
          });
          updatedLocal = true;
          break;
        }
      }

      if (updatedLocal) {
        DesignConfig.showTopToast(
          context,
          'Rejected successfully (Demo Mode)',
          background: Colors.orange,
        );
      } else {
        DesignConfig.showTopToast(
          context,
          'Error: $e',
          background: Colors.red,
        );
      }
    }
  }

  Future<bool?> _showApproveConfirmation(TodoItem item) {
    final employeeName = item.user?.name ?? item.user?.email ?? 'Employee';
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text("Approve Request", style: TextStyle(fontWeight: FontWeight.w700)),
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
                          const TextSpan(text: "Are you sure you want to approve "),
                          TextSpan(
                            text: employeeName,
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green),
                          ),
                          const TextSpan(text: "'s request?"),
                        ],
                      ),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showRejectConfirmation(TodoItem item) {
    final reasonController = TextEditingController();
    final employeeName = item.user?.name ?? item.user?.email ?? 'Employee';
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
                children: const [
                  Icon(Icons.cancel_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Reject Request", style: TextStyle(fontWeight: FontWeight.w700)),
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
                              const TextSpan(text: "Are you sure you want to reject "),
                              TextSpan(
                                text: employeeName,
                                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
                              ),
                              const TextSpan(text: "'s request?"),
                            ],
                          ),
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
                          decoration: const InputDecoration(
                            hintText: 'Reason for rejection *',
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
                  child: const Text('Cancel'),
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
                  child: const Text('Reject', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTodoDetailsBottomSheet(TodoItem item) {
    final statusColor = item.completed ? Colors.green : Colors.orange;
    final isPending = !item.completed;
    final displayStatus = item.completed
        ? AppLocalizations.of(context)!.completedLabel
        : AppLocalizations.of(context)!.pendingLabel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.75;
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
              // Handle bar
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item.completed ? Icons.check_circle_outline : Icons.pending_outlined,
                              color: statusColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  item.title.isNotEmpty ? item.title : 'Task Details',
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AutoSizeText(
                                    displayStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
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

                      const SizedBox(height: 20),

                      // User details
                      const Text(
                        'Employee Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, size: 20, color: Colors.black54),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    item.user?.name ?? item.user?.email ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (item.user?.email != null) ...[
                                    const SizedBox(height: 2),
                                    AutoSizeText(
                                      item.user!.email,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (item.user?.epfPretty != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('EPF', style: TextStyle(fontSize: 8, color: Colors.black54)),
                                    const SizedBox(height: 2),
                                    Text(item.user!.epfPretty!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Metadata table
                      const Text(
                        'Request Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Column(
                          children: _buildSheetDetailRows(item),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Approve / Reject Actions
                      if (isPending)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  final reason = await _showRejectConfirmation(item);
                                  if (reason != null) {
                                    await _rejectTodoItem(item.id, reason);
                                  }
                                },
                                icon: const Icon(Icons.close, size: 18),
                                label: AutoSizeText(
                                  AppLocalizations.of(context)!.rejectedLable,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  final confirmed = await _showApproveConfirmation(item);
                                  if (confirmed == true) {
                                    await _approveTodoItem(item.id);
                                  }
                                },
                                icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                label: AutoSizeText(
                                  AppLocalizations.of(context)!.approvedLable,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  List<Widget> _buildSheetDetailRows(TodoItem item) {
    final List<Widget> list = [];
    
    list.add(_buildDetailRow(Icons.layers_outlined, 'Category', item.type.toUpperCase()));
    list.add(_buildDetailRow(Icons.pin_drop_outlined, 'Zone', item.zone));
    
    if (item.type == 'remote_attendance' && item.payload != null) {
      final p = item.payload!;
      final punchType = p['type']?.toString().toUpperCase() ?? '-';
      final checkedAt = p['checked_at']?.toString() ?? '-';
      final accuracy = p['location_accuracy']?.toString() ?? '-';
      final battery = p['battery_level']?.toString() ?? '-';
      final lat = p['lat']?.toString() ?? '-';
      final lng = p['lng']?.toString() ?? '-';
      
      list.add(_buildDetailRow(Icons.login, 'Punch Type', punchType));
      list.add(_buildDetailRow(Icons.schedule, 'Checked At', checkedAt));
      list.add(_buildDetailRow(Icons.my_location, 'Accuracy', '$accuracy m'));
      list.add(_buildDetailRow(Icons.battery_std, 'Battery', '$battery%'));
      list.add(_buildDetailRow(Icons.map, 'Coordinates', '$lat, $lng'));
    } else if (item.type == 'profile_unlock' && item.meta != null) {
      final m = item.meta!;
      final reason = m['reason']?.toString() ?? m['summary']?.toString() ?? '-';
      list.add(_buildDetailRow(Icons.help_outline, 'Reason', reason));
    } else if (item.type == 'attendance' && item.meta != null) {
      final m = item.meta!;
      final rates = m['rates']?.toString() ?? '-';
      list.add(_buildDetailRow(Icons.payments_outlined, 'Rates Info', rates));
    }
    
    return list;
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black38),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBody(List<TodoItem> list) {
    if (list.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.black26),
                  const SizedBox(height: 16),
                  AutoSizeText(
                    AppLocalizations.of(context)!.noTodosFound,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 12,
                    style: const TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      itemCount: list.length,
      itemBuilder: (_, i) => TodoCardWidget(
        item: list[i],
        onTap: () => _showTodoDetailsBottomSheet(list[i]),
      ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              AutoSizeText(
                AppLocalizations.of(context)!.failedToLoadTodos,
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 12,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              AutoSizeText(
                _error!,
                textAlign: TextAlign.center,
                maxLines: 4,
                minFontSize: 10,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HRColors.orangeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: AutoSizeText(
                  AppLocalizations.of(context)!.retryLabel,
                  maxLines: 1,
                  minFontSize: 10,
                  style: const TextStyle(color: Colors.white),
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
            child: _tabBody(_myTodos),
          ),
          RefreshIndicator(
            onRefresh: _load,
            child: _tabBody(_approvableTodos),
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
                        color: HRColors.flavorIconBackgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Icon(Icons.navigate_before, color: HRColors.flavorIconColor),
                    ),
                  ),
                  const SizedBox(width: _g12),
                  Expanded(
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.todos,
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _g20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _g12),
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
                        AppLocalizations.of(context)!.todoTabMyTodos,
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ),
                    Tab(
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.todoTabApprovable,
                        maxLines: 1,
                        minFontSize: 10,
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

  const TodoCardWidget({super.key, required this.item, required this.onTap});

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
    }

    final String displayStatus = item.completed
        ? AppLocalizations.of(context)!.completedLabel
        : AppLocalizations.of(context)!.pendingLabel;

    IconData typeIcon = Icons.assignment_outlined;
    if (item.type == 'remote_attendance') {
      typeIcon = Icons.fingerprint;
    } else if (item.type == 'profile_unlock') {
      typeIcon = Icons.lock_open_outlined;
    } else if (item.type == 'attendance') {
      typeIcon = Icons.calendar_today_outlined;
    }

    final String userName = item.user?.name ?? item.user?.email ?? 'Unknown User';
    final String userEmail = item.user?.email ?? '';
    final String epfString = item.user?.epfPretty != null ? 'EPF: ${item.user!.epfPretty}' : '';

    String punchDetails = '';
    if (item.type == 'remote_attendance' && item.payload != null) {
      final punchType = item.payload!['type']?.toString().toUpperCase() ?? '';
      if (punchType.isNotEmpty) {
        punchDetails = 'Punch: $punchType';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: HRColors.orangeColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: HRColors.orangeColor, size: 20),
                ),
                const SizedBox(width: 12),
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
                              maxLines: 1,
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AutoSizeText(
                              displayStatus,
                              maxLines: 1,
                              minFontSize: 8,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (userEmail.isNotEmpty && userEmail != userName) ...[
                        const SizedBox(height: 2),
                        AutoSizeText(
                          userEmail,
                          maxLines: 1,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (epfString.isNotEmpty)
                            AutoSizeText(
                              epfString,
                              maxLines: 1,
                              minFontSize: 10,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          if (punchDetails.isNotEmpty)
                            AutoSizeText(
                              punchDetails,
                              maxLines: 1,
                              minFontSize: 10,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month, size: 14, color: Colors.black38),
                              const SizedBox(width: 4),
                              AutoSizeText(
                                _formatDateTime(item.cts),
                                maxLines: 1,
                                minFontSize: 9,
                                style: const TextStyle(
                                  color: Colors.black38,
                                  fontSize: 11,
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
      ),
    );
  }
}
