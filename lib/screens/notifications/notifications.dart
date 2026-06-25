import 'package:auto_size_text/auto_size_text.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/services/fcm_service.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class HRNotifications extends StatefulWidget {
  static String routeName = "/HRNotifications";

  const HRNotifications({Key? key}) : super(key: key);

  @override
  _HRNotificationsState createState() => _HRNotificationsState();
}

class _HRNotificationsState extends State<HRNotifications> {
  final LocalStorage _storage = LocalStorage('pocketHR');
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Transfer any background-queued notifications before reading storage
    await FCMService.transferPendingNotifications();
    await _loadNotifications();
    // Sync badge to reflect actual unread count in storage
    await FCMService.loadUnreadCount();
  }

  Future<void> _loadNotifications() async {
    await _storage.ready;
    final raw = _storage.getItem('fcm_notifications');
    final List<Map<String, dynamic>> items = [];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          items.add(Map<String, dynamic>.from(item));
        }
      }
    }
    if (mounted) {
      setState(() {
        _notifications = items;
        _loading = false;
      });
    }
  }

  Future<void> _markRead(int index) async {
    final n = _notifications[index];
    if (n['read'] == true) return;
    await FCMService.markNotificationRead(n['id']?.toString() ?? '');
    if (mounted) {
      setState(() {
        _notifications[index] = Map<String, dynamic>.from(n)..['read'] = true;
      });
    }
  }

  void _showDetail(Map<String, dynamic> n, Color primary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationDetailSheet(n: n, primary: primary),
    );
  }

  Future<void> _clearAll() async {
    await _storage.ready;
    await _storage.deleteItem('fcm_notifications');
    FCMService.unreadCount.value = 0;
    if (mounted) setState(() => _notifications = []);
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = FlavorConfig.instance.primaryColor;
    return Scaffold(
      backgroundColor: HRColors.white,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HRColors.flavorIconBackgroundColor ?? Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: HRColors.flavorIconColor, size: 18),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)?.notificationsTitle ?? 'Notifications',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                  AppLocalizations.of(context)?.notificationClearAll ?? 'Clear all',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) =>
                        _buildCard(_notifications[index], primary, index),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> n, Color primary, int index) {
    final isUnread = n['read'] == false;
    return GestureDetector(
      onTap: () async {
        await _markRead(index);
        if (mounted) _showDetail(_notifications[index], primary);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? primary.withOpacity(0.07) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isUnread
              ? Border.all(color: primary.withOpacity(0.25), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: primary.withOpacity(0.12),
                child: Icon(Icons.notifications_outlined,
                    color: primary, size: 22),
              ),
              if (isUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          title: AutoSizeText(
            n['title']?.toString().isNotEmpty == true
                ? n['title'].toString()
                : (AppLocalizations.of(context)?.notificationText ?? 'Notification'),
            maxLines: 1,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
              fontSize: 14,
              color: isUnread ? primary : HRColors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (n['body']?.toString().isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: AutoSizeText(
                    n['body'].toString(),
                    maxLines: 2,
                    style: TextStyle(
                        color: HRColors.black.withOpacity(0.65), fontSize: 13),
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  AutoSizeText(
                    _formatTime(n['timestamp']?.toString()),
                    style: TextStyle(
                        color: HRColors.black.withOpacity(0.4), fontSize: 11),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.newText ?? 'NEW',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: HRColors.black.withOpacity(0.3),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.notificationNoNotificationsYet ?? 'No notifications yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.notificationAllCaughtUp ?? "You're all caught up!",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail bottom sheet
// ---------------------------------------------------------------------------
class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({
    required this.n,
    required this.primary,
  });

  final Map<String, dynamic> n;
  final Color primary;

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _getLocalizedLabel(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return key;

    final cleanKey = key.toLowerCase().replaceAll('_', '').replaceAll('-', '');
    switch (cleanKey) {
      case 'targetusername':
        return l10n.notificationDetailEmployeeName;
      case 'triggeredbyname':
        return l10n.notificationDetailPerformedBy;
      case 'triggeredby':
        return l10n.notificationDetailPerformerEmail;
      case 'triggeredbyepfno':
        return l10n.notificationDetailPerformerEpfNo;
      case 'targetuserepfno':
        return l10n.notificationDetailEmployeeEpfNo;
      case 'ip':
        return l10n.notificationDetailIpAddress;
      case 'time':
        return l10n.notificationDetailTime;
      default:
        // Fallback formatting: capitalize words, remove underscores/dashes
        String fallback = key.replaceAll('_', ' ').replaceAll('-', ' ');
        if (fallback.isNotEmpty) {
          fallback = fallback.split(' ').map((word) {
            if (word.isEmpty) return '';
            return '${word[0].toUpperCase()}${word.substring(1)}';
          }).join(' ');
        }
        return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = n['title']?.toString().isNotEmpty == true
        ? n['title'].toString()
        : (AppLocalizations.of(context)?.notificationText ?? 'Notification');
    final body = n['body']?.toString() ?? '';
    final timestamp = _formatTime(n['timestamp']?.toString());
    final data = n['data'];
    final Map<String, dynamic> extraData =
        (data is Map) ? Map<String, dynamic>.from(data) : {};

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.06),
                border: Border(
                  bottom:
                      BorderSide(color: primary.withOpacity(0.12), width: 1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primary.withOpacity(0.15),
                    radius: 22,
                    child: Icon(Icons.notifications_outlined,
                        color: primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        if (timestamp.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                timestamp,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  if (body.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context)?.notificationMessageLabel ?? 'Message',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Text(
                        body,
                        style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.55,
                            color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (extraData.isNotEmpty) ...[
                    (() {
                      final filteredEntries = extraData.entries.where((e) {
                        final key = e.key.toLowerCase();
                        if (key == 'tenant' ||
                            key == 'click_action' ||
                            key == 'key' ||
                            key == 'tkey' ||
                            key == 'alertid' ||
                            key == 'alert_id' ||
                            key.startsWith('google.') ||
                            key.startsWith('gcm.')) {
                          return false;
                        }
                        return e.value != null && e.value.toString().isNotEmpty;
                      }).toList();

                      if (filteredEntries.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.notificationDetailsLabel ?? 'Details',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!, width: 1),
                            ),
                            child: Column(
                              children: filteredEntries.map((e) {
                                final cleanLabel = _getLocalizedLabel(e.key, context);
                                
                                // Format time string if needed to be user readable instead of raw ISO format
                                String cleanValue = e.value.toString();
                                if (e.key.toLowerCase() == 'time') {
                                  final formatted = _formatTime(cleanValue);
                                  if (formatted.isNotEmpty) {
                                    cleanValue = formatted;
                                  }
                                }

                                return _DetailRow(
                                  label: cleanLabel,
                                  value: cleanValue,
                                  primary: primary,
                                  isLast: e.key == filteredEntries.last.key,
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    })(),
                  ],
                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                          AppLocalizations.of(context)?.notificationCloseButton ?? 'Close',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.primary,
    required this.isLast,
  });

  final String label;
  final String value;
  final Color primary;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }
}
