import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/helper/apiConfig.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/model/hr/AttendanceModel.dart';
import 'package:cn_pocket_hr/model/hr/LeaveModel.dart';
import 'package:cn_pocket_hr/model/hr/MeModel.dart';

class APIService {
  final LocalStorage storage = LocalStorage('pocketHR');
  final APIConfig api = APIConfig();
Future login(String email, String password) async {
  try {
    var url = api.api() + "login";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: {'email': email, 'password': password},
      encoding: Encoding.getByName("utf-8"),
    );

    print("RAW RESPONSE => ${response.body}");

    // 🔐 Check JSON first
    if (!response.headers['content-type']
        .toString()
        .contains("application/json")) {
      print("Server returned HTML, not JSON");
      return null;
    }

    var values = jsonDecode(response.body);

    if (values == null) return null;

    if (values['status'] == true) {

      await storage.ready; // IMPORTANT

      if (values['result'] != null &&
          values['result']['user'] != null) {

        // TOKEN
        await storage.setItem('token', values['result']['token']);

        // PAYROLL
        await storage.setItem(
            'payroll_active_tag',
            values['result']['payroll_tags']['active']['tag']);

        await storage.setItem(
            'payroll_active_id',
            values['result']['payroll_tags']['active']['id']);

        await storage.setItem(
            'payroll_past_tag',
            values['result']['payroll_tags']['past']['tag']);

        await storage.setItem(
            'payroll_past_id',
            values['result']['payroll_tags']['past']['id']);

        // USER
        final userAny = values['result']['user'];
        final userMap = (userAny is Map) ? Map<String, dynamic>.from(userAny) : <String, dynamic>{};
        final legacyId = (userMap['id'] ?? '').toString();
        final humanId = (userMap['_id'] ?? userMap['human_id'] ?? userMap['user_id'] ?? '').toString();

        // Keep legacy id for old APIs/UI
        if (legacyId.isNotEmpty) {
          await storage.setItem('uid', legacyId);
        }
        // Store v2 attendance user id separately (Mongo _id)
        if (humanId.isNotEmpty) {
          await storage.setItem('human_user_id', humanId);
        }

        await storage.setItem('full_name',
            values['result']['user']['full_name']);

        await storage.setItem('fname',
            values['result']['user']['first_name']);

        await storage.setItem('lname',
            values['result']['user']['last_name']);

        await storage.setItem('initials',
            values['result']['user']['initials']);

        await storage.setItem('avatar',
            values['result']['user']['avatar']);

        await storage.setItem('dob',
            values['result']['user']['cf_dob']);

        await storage.setItem('nic',
            values['result']['user']['cf_nic']);

        await storage.setItem('contact',
            values['result']['user']['cf_phone']);

        await storage.setItem('address',
            values['result']['user']['address']);

        await storage.setItem('apiation',
            values['result']['user']['apiation']);

        await storage.setItem('biostarId',
            values['result']['user']['cf_biostar_id']);

        // LEAVE QUOTA
        await storage.setItem('annualQuota',
            values['result']['leave_quota']['annual']);

        await storage.setItem('casualQuota',
            values['result']['leave_quota']['casual']);

        await storage.setItem('medicalQuota',
            values['result']['leave_quota']['medical']);

        // LEAVE BALANCE
        await storage.setItem('leaveAnnual',
            values['result']['leave_balance']['annual']);

        await storage.setItem('leaveCasual',
            values['result']['leave_balance']['casual']);

        await storage.setItem('leaveMedical',
            values['result']['leave_balance']['medical']);

        await storage.setItem('leaveNopay',
            values['result']['leave_balance']['nopay']);

        // LOGIN FLAG
        await storage.setItem('login', true); // ✅ correct
      }

    } else {
      showToast(values['message']);
      apiFailedRedirect();
    }

    return values;

  } catch (e) {
    print("LOGIN ERROR => $e");
  }
}

  Future showToast(text) async {
    String msg;
    try {
      if (text is List) {
        msg = text.map((e) => e?.toString() ?? '').join('\n');
      } else if (text is Map) {
        msg = text.toString();
      } else {
        msg = text?.toString() ?? '';
      }
    } catch (_) {
      msg = text.toString();
    }

    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Color.fromARGB(255, 211, 211, 211),
        textColor: Colors.black);
  }

  Future checkInCheckout(date, type, {String? latitude, String? longitude, String? address}) async {
    String url = "https://api.human.go.digitable.io/human/v2/api/attendance/check-in";

    await storage.ready;
    String uid = storage.getItem('uid')?.toString() ?? '';

    if (uid.isEmpty) {
      final token = storage.getItem('token')?.toString();
      final access = storage.getItem('access_token')?.toString();
      if ((access == null || access.isEmpty) && token != null && token.isNotEmpty) {
        await storage.setItem('access_token', token);
      }
      final ensured = await ensureUidFromAccessToken();
      if (ensured != null && ensured.isNotEmpty) {
        uid = ensured;
      }
      if (uid.isEmpty) {
        final me = await fetchMeProfileWithBearer();
        if (me != null) {
          final dataAny = me['data'] ?? me['result'] ?? me['user'];
          if (dataAny is Map) {
            final data = Map<String, dynamic>.from(dataAny);
            final id = (data['_id'] ?? data['id'] ?? '').toString();
            if (id.isNotEmpty) {
              uid = id;
              await storage.setItem('uid', uid);
            }
          }
        }
      }
    }

    var data = {
      'uid': uid,
      'checked_at': date,
      'user-id': uid,
    };

    if (type == 'checkout') {
      url = "https://api.human.go.digitable.io/human/v2/api/attendance/check-out";
      data = {
        'uid': uid,
        'checkout_at': date,
        'user-id': uid,
      };
    }
    if (latitude != null && latitude.isNotEmpty) {
      data['lat'] = latitude; 
    }
    if (longitude != null && longitude.isNotEmpty) {
      data['lng'] = longitude; 
    }
    if (address != null && address.isNotEmpty) data['address'] = address;
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    };
    final oauthToken = storage.getItem('token')?.toString();
    final accessToken = storage.getItem('access_token')?.toString();
    if (oauthToken != null && oauthToken.isNotEmpty) headers['Oauth-Token'] = oauthToken;
    if (accessToken != null && accessToken.isNotEmpty) headers['Authorization'] = 'Bearer $accessToken';
    try {
      print('[CHECK] POST $url');
      print('[CHECK] headers => ' + headers.toString());
      print('[CHECK] body => ' + data.toString());
    } catch (_) {}

    final response = await http.post(Uri.parse(url), headers: headers, body: data, encoding: Encoding.getByName("utf-8"));

    var values = json.decode(response.body);
    print('[CHECK] response => ' + response.body);
    if (values is Map && values.containsKey('message')) print(values['message']);
    showToast(values['message']);
    print(values);
  }



  Future leave(details) async {
    try {
      await storage.ready;
      final url = api.api() + "leave/store";

      // Safe extraction of fields
      final uidStr = storage.getItem('uid')?.toString() ?? '';
      final tokenStr = storage.getItem('token')?.toString() ?? '';

      final leaveTitle = details is Map && details['leave_title'] != null
          ? details['leave_title'].toString()
          : '';
      final fromDate = details is Map && details['from_date'] != null
          ? details['from_date'].toString()
          : '';
      final toDate = details is Map && details['to_date'] != null
          ? details['to_date'].toString()
          : '';
      final leaveType = details is Map && details['leave_type'] != null
          ? details['leave_type'].toString()
          : '';
      final typeStr = details is Map && details['type'] != null
          ? details['type'].toString()
          : '';
      final session = details is Map && details['session'] != null
          ? details['session'].toString()
          : '';
      final description = details is Map && details['description'] != null
          ? details['description'].toString()
          : '';

      final data = {
        'leave_title': leaveTitle,
        'from_date': fromDate,
        'to_date': toDate,
        'user-id': uidStr,
        'leave_type': leaveType,
        'type': typeStr,
        'session': session,
        'description': description,
      };

      final headers = {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      
       "Oauth-Token": "4rMVDI0iOGifKm5Thi3hbxbhya3r8w"
      };

      // Debug
      print('[LEAVE] POST $url');
      print('[LEAVE] headers => ' + headers.toString());
      print('[LEAVE] body => ' + data.toString());

      final response = await http.post(Uri.parse(url),
          headers: headers, body: data, encoding: Encoding.getByName("utf-8"));

      print('[LEAVE] response => ' + response.body);
      final values = json.decode(response.body);
      if (values is Map && values['status'] == true) {
        showToast(values['message'] ?? 'Submitted');
        return true;
      } else {
        // If API indicates failure, show message and return false
        if (values is Map) showToast(values['message'] ?? 'Failed');
        return false;
      }
    } catch (e, st) {
      print('[LEAVE] ERROR => $e');
      print(st);
      showToast('Failed to submit leave.');
      return false;
    }
  }

  Future<List<MeSubsModel>> getMeSubs() async {
    String url = api.api() + "me";

    final uidStr = storage.getItem('uid')?.toString() ?? '';
    final tokenStr = storage.getItem('token')?.toString() ?? '';
    Map<String, String> qParams = {
      'user-id': uidStr,
    };
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "Oauth-token": tokenStr
    };

    Uri uri = Uri.parse(url);
    final finalUri = uri.replace(queryParameters: qParams); //USE THIS
    final response = await http.get(
      finalUri,
      headers: header,
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status']) {
        final detail = (jsonData['result']['subs'] as List)
            .map((data) => MeSubsModel.fromJson(data))
            .toList();
        return detail;
      } else {
        return [];
      }
    } else {
      // showToast("Failed to load leaves");
      throw Exception("Failed to load leaves");
    }
  }

  Future<List<MyLeavesModel>> getMyLeaves(anotherPerson) async {
    try {
      await storage.ready;

      String url = "";
      if (anotherPerson is String && anotherPerson.isNotEmpty) {
        url = api.api() + "leave/list/" + anotherPerson;
      } else {
        url = api.api() + "leave/list";
      }

      final uidStr = storage.getItem('uid')?.toString() ?? '';
      final tokenStr = storage.getItem('token')?.toString() ?? '';
      final accessToken = storage.getItem('access_token')?.toString() ?? '';

      Map<String, String> qParams = {
        'user-id': uidStr,
      };
      Map<String, String> header = {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Oauth-Token": "4rMVDI0iOGifKm5Thi3hbxbhya3r8w"
      };
      if (accessToken.isNotEmpty) header['Authorization'] = 'Bearer $accessToken';

      Uri uri = Uri.parse(url);
      final finalUri = uri.replace(queryParameters: qParams);
      final response = await http.get(
        finalUri,
        headers: header,
      );

      print('[LEAVE] GET $finalUri status=${response.statusCode}');
      print('[LEAVE] body=${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData != null && jsonData['status'] == true) {
          final detail = (jsonData['result']['leaves'] as List)
              .map((data) => MyLeavesModel.fromJson(data))
              .toList();
          return detail;
        }
        return [];
      }

      // Non-200 -> return empty list (avoid throwing)
      return [];
    } catch (e, st) {
      print('[LEAVE] ERROR => $e');
      print(st);
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchMeProfileWithBearer() async {
    try {
      await storage.ready;

      final accessToken = storage.getItem('access_token');
      if (accessToken == null || accessToken.toString().isEmpty) {
        print('[ME] Missing access_token in storage');
        return null;
      }

      final url = "https://api.human.go.digitable.io/human/v2/api/auth/me";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );

      print('[ME] GET $url status=${response.statusCode}');
      print('[ME] body=${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      await storage.setItem('me_profile', decoded);

      // Persist uid if present in bearer profile response
      final dataAny = decoded['data'] ?? decoded['result'] ?? decoded['user'];
      if (dataAny is Map) {
        final data = Map<String, dynamic>.from(dataAny);
        final id = (data['_id'] ?? data['id'] ?? '').toString();
        if (id.isNotEmpty) {
          await storage.setItem('uid', id);
        }

        // Persist leave quotas if available in profile response
        try {
          // 1) Newer APIs may provide leave_quota directly
          if (data.containsKey('leave_quota') && data['leave_quota'] is Map) {
            final lq = Map<String, dynamic>.from(data['leave_quota']);
            if (lq.containsKey('annual')) await storage.setItem('annualQuota', lq['annual']);
            if (lq.containsKey('casual')) await storage.setItem('casualQuota', lq['casual']);
            if (lq.containsKey('medical')) await storage.setItem('medicalQuota', lq['medical']);
          }

          // 2) Some profiles include package -> leave
          final pkgAny = data['package'];
          if (pkgAny is Map && pkgAny.containsKey('leave') && pkgAny['leave'] is Map) {
            final lp = Map<String, dynamic>.from(pkgAny['leave']);
            if (lp.containsKey('annual')) await storage.setItem('annualQuota', lp['annual']);
            if (lp.containsKey('casual')) await storage.setItem('casualQuota', lp['casual']);
            if (lp.containsKey('medical')) await storage.setItem('medicalQuota', lp['medical']);
          }

          // Persist leave balances if provided, otherwise default to 0
          if (data.containsKey('leave_balance') && data['leave_balance'] is Map) {
            final lb = Map<String, dynamic>.from(data['leave_balance']);
            if (lb.containsKey('annual')) await storage.setItem('leaveAnnual', lb['annual']);
            if (lb.containsKey('casual')) await storage.setItem('leaveCasual', lb['casual']);
            if (lb.containsKey('medical')) await storage.setItem('leaveMedical', lb['medical']);
            if (lb.containsKey('nopay')) await storage.setItem('leaveNopay', lb['nopay']);
          } else {
            // Ensure keys exist with default 0 so UI doesn't show null
            await storage.setItem('leaveAnnual', storage.getItem('leaveAnnual') ?? 0);
            await storage.setItem('leaveCasual', storage.getItem('leaveCasual') ?? 0);
            await storage.setItem('leaveMedical', storage.getItem('leaveMedical') ?? 0);
            await storage.setItem('leaveNopay', storage.getItem('leaveNopay') ?? 0);
          }
        } catch (_) {}
      }

      return decoded;
    } catch (e) {
      print('[ME] ERROR => $e');
      return null;
    }
  }

  Future<List<dynamic>> fetchVariablesForUser(String userId) async {
    await storage.ready;

    final accessToken = storage.getItem('access_token');
    if (accessToken == null || accessToken.toString().isEmpty) {
      throw Exception('Missing access_token');
    }

    final url =
        'https://api.human.go.digitable.io/human/v2/api/variables/variables/605b4f4c277bf8660c7b23df';  //$userId
    final res = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer $accessToken',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to load variables (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map && decoded['variables'] is List) {
      print(decoded);
      return List<dynamic>.from(decoded['variables']);
    }
    // Some backends might return list directly.
    if (decoded is List) return decoded;

    return const [];
  }

  Future<List<dynamic>> fetchDebtsForUser(String userId) async {
      await storage.ready;

      final accessToken = storage.getItem('access_token');
      if (accessToken == null || accessToken.toString().isEmpty) {
        throw Exception('Missing access_token');
      }

      final oauthToken = storage.getItem('token')?.toString() ?? '';
      final uid = (userId).toString().isNotEmpty ? userId.toString() : '605b4f4c277bf8660c7b23df';
 
      final url = 'https://api.human.go.digitable.io/human/v2/api/debts/605b4f4c277bf8660c7b23df';
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken.toString()}',
          if (oauthToken.isNotEmpty) 'Oauth-Token': oauthToken,
        },
      );
 
      if (res.statusCode < 200 || res.statusCode >= 300) {
        if (res.statusCode == 401 || res.statusCode == 403) {
          try {
            showToast('Session expired. Please login again.');
          } catch (_) {}
        }
        throw Exception('Failed to load debts (${res.statusCode})');
      }
 
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['data'] is Map) {
        final data = Map<String, dynamic>.from(decoded['data']);
        if (data['debts'] is List) {
          return List<dynamic>.from(data['debts']);
        }
      }
      return const [];
    }


  apiFailedRedirect() async {
    // storage.clear();
    showToast("Session timeout.");
    // navigatorKey.currentState!.pushNamed('/login');
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final obj = jsonDecode(decoded);
      if (obj is Map<String, dynamic>) return obj;
      if (obj is Map) return Map<String, dynamic>.from(obj);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> ensureUidFromAccessToken() async {
    await storage.ready;
    final existing = storage.getItem('uid')?.toString();
    if (existing != null && existing.isNotEmpty) return existing;

    final accessToken = storage.getItem('access_token')?.toString();
    if (accessToken == null || accessToken.isEmpty) return null;

    final payload = _decodeJwtPayload(accessToken);
    if (payload == null) return null;

    final uid = (payload['user_id'] ?? payload['sub'] ?? '').toString();
    if (uid.isEmpty) return null;

    await storage.setItem('uid', uid);
    return uid;
  }

  // Fetch attendance for a specific user and optional payroll month (format: MM-YYYY or 12-2025)
  // NOTE: v2 attendance requires Mongo user _id (24 hex chars). Using legacy numeric uid will return empty records.
  Future<List<AttendanceModel>> getAttendanceForUserMonth({String? userId, String? payroll}) async {
    try {
      await storage.ready;

      bool looksLikeMongoId(String s) => RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(s);

      String uid = (userId ?? '').toString();
      if (!looksLikeMongoId(uid)) uid = '';

      // Prefer stored v2 id
      if (uid.isEmpty) {
        final stored = storage.getItem('human_user_id')?.toString() ?? '';
        if (looksLikeMongoId(stored)) uid = stored;
      }

      // Fallback to legacy uid only if it is actually a Mongo id
      if (uid.isEmpty) {
        final candidate = storage.getItem('uid')?.toString() ?? '';
        if (looksLikeMongoId(candidate)) uid = candidate;
      }

      // Try bearer profile to obtain _id
      if (uid.isEmpty) {
        final me = await fetchMeProfileWithBearer();
        final dataAny = me?['data'] ?? me?['result'] ?? me?['user'];
        if (dataAny is Map) {
          final id = (dataAny['_id'] ?? dataAny['id'] ?? '').toString();
          if (looksLikeMongoId(id)) {
            uid = id;
            await storage.setItem('human_user_id', uid);
          }
        }
      }

      if (uid.isEmpty) return [];

      final baseUrl = 'https://api.human.go.digitable.io/human/v2/api/attendance/user/605b4f57277bf8660c7b256e';
      final p = (payroll ?? '').trim();
      Uri uri = Uri.parse(baseUrl);
      if (p.isNotEmpty) {
        uri = uri.replace(queryParameters: {'payroll': p});
      }

      final token = storage.getItem('token')?.toString() ?? '';
      final access = storage.getItem('access_token')?.toString() ?? '';

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token.isNotEmpty) headers['Oauth-Token'] = token;
      if (access.isNotEmpty) headers['Authorization'] = 'Bearer $access';

      final response = await http.get(uri, headers: headers);
      print('[ATT] GET $uri status=${response.statusCode}');
      print('[ATT] body=${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        try {
          final err = json.decode(response.body);
          if (err is Map && (err['message']?.toString().isNotEmpty ?? false)) {
            showToast(err['message'].toString());
          } else {
            showToast('Failed to load attendance');
          }
        } catch (_) {
          showToast('Failed to load attendance');
        }
        return [];
      }

      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['success'] == false) {
        try {
          final msg = decoded['message']?.toString();
          if (msg != null && msg.isNotEmpty) showToast(msg);
        } catch (_) {}
        return [];
      }

      if (decoded is Map && decoded['data'] is Map) {
        final data = Map<String, dynamic>.from(decoded['data']);
        if (data['records'] is List) {
          final out = <AttendanceModel>[];
          for (final e in (data['records'] as List)) {
            if (e is! Map) continue;
            final raw = Map<String, dynamic>.from(e);
            final normalized = _normalizeAttendanceV2Record(raw);
            try {
              out.add(AttendanceModel.fromJson(normalized));
            } catch (err) {
              print('[ATT] skip record parse error => $err');
            }
          }
          return out;
        }
      }

      if (decoded is List) {
        return decoded.map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }

      return [];
    } catch (e, st) {
      print('[ATT] getAttendanceForUserMonth ERROR => $e');
      print(st);
      try {
        showToast('Failed to load attendance');
      } catch (_) {}
      return [];
    }
  }

  // Simple wrapper
  Future<List<AttendanceModel>> getAttendanceForUser(String userId) async {
    return await getAttendanceForUserMonth(userId: userId);
  }

  Map<String, dynamic> _normalizeAttendanceV2Record(Map<String, dynamic> r) {
    // AttendanceModel in this project expects some string fields and a 'boilerPlate' map.
    // v2 records can contain nulls -> normalize to safe defaults.
    final att = (r['attendance'] is List) ? List<dynamic>.from(r['attendance']) : <dynamic>[];

    int? inEpoch;
    int? outEpoch;
    for (final p in att) {
      if (p is! Map) continue;
      final type = (p['type'] ?? '').toString();
      final t = p['time'];
      final epoch = (t is int) ? t : (t is num ? t.toInt() : int.tryParse(t?.toString() ?? ''));
      if (epoch == null) continue;
      if (type == 'in' && inEpoch == null) inEpoch = epoch;
      if (type == 'out') outEpoch = epoch;
    }

    DateTime? base;
    if (inEpoch != null) base = DateTime.fromMillisecondsSinceEpoch(inEpoch * 1000);
    if (base == null && outEpoch != null) base = DateTime.fromMillisecondsSinceEpoch(outEpoch * 1000);

    String fmtDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    String fmtTime(int seconds) {
      final d = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    String fmtDow(DateTime d) {
      const dows = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return dows[d.weekday % 7];
    }

    final dayStr = base != null ? fmtDate(base) : '';
    final dowStr = base != null ? fmtDow(base) : '';

    final worked = (r['workedHours'] ?? r['worked_hours'] ?? '').toString();
    final workedSeconds = (r['workedSeconds'] ?? r['worked_seconds'] ?? r['worked_hours']);

    // Try extract a location label from punch meta
    String? sensorPool;
    try {
      for (final p in att) {
        if (p is! Map) continue;
        final metaAny = p['meta'];
        if (metaAny is Map && metaAny['sensor_pool'] != null) {
          sensorPool = metaAny['sensor_pool']?.toString();
          if (sensorPool != null && sensorPool.isNotEmpty) break;
        }
      }
    } catch (_) {}

    return <String, dynamic>{
      // Keep original r fields too
      ...r,

      // Ensure string-ish fields exist
      'id': (r['id'] ?? r['_id'] ?? '').toString(),
      'day': dayStr,
      'dow': dowStr,
      'workedHours': worked,

      // Provide boilerPlate used by UI
      'boilerPlate': <String, dynamic>{
        'day': dayStr,
        'dow': dowStr,
        'in_time_only': inEpoch != null ? fmtTime(inEpoch) : null,
        'out_time_only': outEpoch != null ? fmtTime(outEpoch) : null,
        'wrkd_hours_fmtd': worked.isNotEmpty ? worked : null,
        'workedSeconds': workedSeconds,
        'worked_hours': workedSeconds,
        'location': sensorPool,
        'late': null,
        'over': null,
      },
    };
  }
}
