// filepath: /home/akesh/Work/new_hr/cn_pocket_hr/lib/model/hr/VariableModel.dart
class VariableItem {
  final String id;
  final String allowance;
  final String user;
  final int issuedDate;
  final num amount;
  final bool processed;
  final String type; // allowance | deduction
  final bool epfEnabled;
  final int? cts;
  final int? uts;
  final String? processedOn;
  final String? processedIn;

  VariableItem({
    required this.id,
    required this.allowance,
    required this.user,
    required this.issuedDate,
    required this.amount,
    required this.processed,
    required this.type,
    required this.epfEnabled,
    required this.cts,
    required this.uts,
    required this.processedOn,
    required this.processedIn,
  });

  factory VariableItem.fromJson(Map<String, dynamic> json) {
    return VariableItem(
      id: (json['_id'] ?? '').toString(),
      allowance: (json['allowance'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      issuedDate: (json['issued_date'] is num)
          ? (json['issued_date'] as num).toInt()
          : 0,
      amount: (json['amount'] is num) ? (json['amount'] as num) : 0,
      processed: json['processed'] == true,
      type: (json['type'] ?? '').toString(),
      epfEnabled: json['epf_enabled'] == true,
      cts: (json['cts'] is num) ? (json['cts'] as num).toInt() : null,
      uts: (json['uts'] is num) ? (json['uts'] as num).toInt() : null,
      processedOn: json['processed_on']?.toString(),
      processedIn: json['processed_in']?.toString(),
    );
  }
}

class VariablesResponse {
  final List<VariableItem> variables;

  VariablesResponse({required this.variables});

  factory VariablesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['variables'] as List?) ?? const [];
    return VariablesResponse(
      variables: list
          .whereType<Map>()
          .map((e) => VariableItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
