class TodoUser {
  final String id;
  final String name;
  final String email;
  final String? epfPretty;

  TodoUser({
    required this.id,
    required this.name,
    required this.email,
    this.epfPretty,
  });

  factory TodoUser.fromJson(Map<String, dynamic> json) {
    final epf = json['epf'];
    String? epfPretty;
    if (epf is Map) {
      epfPretty = epf['pretty']?.toString();
    }
    final nameStr = (json['name'] ?? '').toString().trim();
    final emailStr = (json['email'] ?? '').toString().trim();
    return TodoUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: nameStr.isNotEmpty ? nameStr : (emailStr.isNotEmpty ? emailStr : 'Unknown User'),
      email: emailStr,
      epfPretty: epfPretty,
    );
  }
}

class TodoItem {
  final String id;
  final String title;
  final String type;
  final String zone;
  final bool completed;
  final TodoUser? user;
  final TodoUser? by;
  final int? cts; // Created timestamp
  final int? uts; // Updated timestamp
  final Map<String, dynamic>? payload;
  final Map<String, dynamic>? meta;
  final bool waitingForPreviousStage;
  final Map<String, dynamic> raw;

  TodoItem({
    required this.id,
    required this.title,
    required this.type,
    required this.zone,
    required this.completed,
    this.user,
    this.by,
    this.cts,
    this.uts,
    this.payload,
    this.meta,
    this.waitingForPreviousStage = false,
    required this.raw,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final byJson = json['by'];
    final payloadJson = json['payload'];
    final metaJson = json['meta'];

    return TodoItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
      completed: json['completed'] == true,
      user: userJson is Map ? TodoUser.fromJson(Map<String, dynamic>.from(userJson)) : null,
      by: byJson is Map ? TodoUser.fromJson(Map<String, dynamic>.from(byJson)) : null,
      cts: json['cts'] is num ? (json['cts'] as num).toInt() : null,
      uts: json['uts'] is num ? (json['uts'] as num).toInt() : null,
      payload: payloadJson is Map ? Map<String, dynamic>.from(payloadJson) : null,
      meta: metaJson is Map ? Map<String, dynamic>.from(metaJson) : null,
      waitingForPreviousStage: json['waiting_for_previous_stage'] == true,
      raw: json,
    );
  }
}
