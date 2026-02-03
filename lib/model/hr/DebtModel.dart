// filepath: /home/akesh/Work/new_hr/cn_pocket_hr/lib/model/hr/DebtModel.dart
class DebtInstallment {
  final num amount;
  final int installment;
  final int date;
  final String? processedIn;
  final String? processedOn;
  final bool? paid;

  DebtInstallment({
    required this.amount,
    required this.installment,
    required this.date,
    required this.processedIn,
    required this.processedOn,
    required this.paid,
  });

  factory DebtInstallment.fromJson(Map<String, dynamic> json) {
    return DebtInstallment(
      amount: (json['amount'] is num) ? (json['amount'] as num) : 0,
      installment: (json['installment'] is num)
          ? (json['installment'] as num).toInt()
          : 0,
      date: (json['date'] is num) ? (json['date'] as num).toInt() : 0,
      processedIn: json['processed_in']?.toString(),
      processedOn: json['processed_on']?.toString(),
      paid: json['paid'] as bool?,
    );
  }
}

class DebtItem {
  final String id;
  final int issuedDate;
  final String user;
  final String type; // loan | salary_advance
  final bool collected;
  final String? description;
  final num amount;
  final int? startingFrom;
  final int? settleIn;
  final List<DebtInstallment> installment;
  final String? collectedOn;
  final String? collectedIn;
  final bool? active;

  DebtItem({
    required this.id,
    required this.issuedDate,
    required this.user,
    required this.type,
    required this.collected,
    required this.description,
    required this.amount,
    required this.startingFrom,
    required this.settleIn,
    required this.installment,
    required this.collectedOn,
    required this.collectedIn,
    required this.active,
  });

  factory DebtItem.fromJson(Map<String, dynamic> json) {
    final inst = (json['installment'] as List?) ?? const [];
    return DebtItem(
      id: (json['_id'] ?? '').toString(),
      issuedDate:
          (json['issued_date'] is num) ? (json['issued_date'] as num).toInt() : 0,
      user: (json['user'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      collected: json['collected'] == true,
      description: json['description']?.toString(),
      amount: (json['amount'] is num) ? (json['amount'] as num) : 0,
      startingFrom: (json['starting_from'] is num)
          ? (json['starting_from'] as num).toInt()
          : null,
      settleIn:
          (json['settle_in'] is num) ? (json['settle_in'] as num).toInt() : null,
      installment: inst
          .whereType<Map>()
          .map((e) => DebtInstallment.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      collectedOn: json['collected_on']?.toString(),
      collectedIn: json['collected_in']?.toString(),
      active: json['active'] as bool?,
    );
  }
}
