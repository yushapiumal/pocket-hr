import 'dart:convert';
import 'package:cn_pocket_hr/api/api_client.dart';
import 'package:cn_pocket_hr/models/hr/debt_model.dart';
import 'package:flutter/foundation.dart';

class DebtService {
  static Future<List<DebtItem>> getDebts() async {
    try {
      final uid = await ApiClient.getResolvedUserId();
      if (uid == null || uid.isEmpty) throw Exception('Missing user id');

      final url = 'https://api.human.go.digitable.io/human/v2/api/debts/$uid';
      final res = await ApiClient.get(url);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Failed to load debts (${res.statusCode})');
      }

      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => DebtItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e, st) {
      debugPrint('[DEBT SERVICE] error: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }
}
