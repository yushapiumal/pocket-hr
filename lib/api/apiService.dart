import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cn_pocket_hr/helper/apiConfig.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/model/hr/AttendanceModel.dart';
import 'package:cn_pocket_hr/model/hr/LeaveModel.dart';
import 'package:cn_pocket_hr/model/hr/MeModel.dart';
import 'package:cn_pocket_hr/services/device_details_service.dart';

class APIService {
  final LocalStorage storage = LocalStorage('pocketHR');
  final APIConfig api = APIConfig();


// Future login(String email, String password, {Map<String, String>? deviceInfo}) async {
//   try {
//     var url = api.api() + "login";

//     final body = <String, String>{'email': email, 'password': password};
//     await _injectTenantToBody(body);
//     if (deviceInfo != null) {
//       // merge device info, overriding only if keys exist
//       deviceInfo.forEach((k, v) {
//         body[k] = v;
//       });
//     }

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         "Accept": "application/json",
//         "Content-Type": "application/x-www-form-urlencoded"
//       },
//       body: body,
//       encoding: Encoding.getByName("utf-8"),
//     );

//     print("RAW RESPONSE => ${response.body}");

//     // 🔐 Check JSON first
//     if (!response.headers['content-type']
//         .toString()
//         .contains("application/json")) {
//       print("Server returned HTML, not JSON");
//       return null;
//     }

//     var values = jsonDecode(response.body);

//     if (values == null) return null;

//     if (values['status'] == true) {

//       await storage.ready; // IMPORTANT

//       if (values['result'] != null &&
//           values['result']['user'] != null) {

//         // TOKEN
//         await storage.setItem('token', values['result']['token']);

//         // PAYROLL
//         await storage.setItem(
//             'payroll_active_tag',
//             values['result']['payroll_tags']['active']['tag']);

//         await storage.setItem(
//             'payroll_active_id',
//             values['result']['payroll_tags']['active']['id']);

//         await storage.setItem(
//             'payroll_past_tag',
//             values['result']['payroll_tags']['past']['tag']);

//         await storage.setItem(
//             'payroll_past_id',
//             values['result']['payroll_tags']['past']['id']);

//         // USER
//         final userAny = values['result']['user'];
//         final userMap = (userAny is Map) ? Map<String, dynamic>.from(userAny) : <String, dynamic>{};
//         final legacyId = (userMap['id'] ?? '').toString();
//         final humanId = (userMap['_id'] ?? userMap['human_id'] ?? userMap['user_id'] ?? '').toString();

//         // Keep legacy id for old APIs/UI
//         if (legacyId.isNotEmpty) {
//           await storage.setItem('uid', legacyId);
//         }
//         // Store v2 attendance user id separately (Mongo _id)
//         if (humanId.isNotEmpty) {
//           await storage.setItem('human_user_id', humanId);
//         }

//         await storage.setItem('full_name',
//             values['result']['user']['full_name']);

//         await storage.setItem('fname',
//             values['result']['user']['first_name']);

//         await storage.setItem('lname',
//             values['result']['user']['last_name']);

//         await storage.setItem('initials',
//             values['result']['user']['initials']);

//         await storage.setItem('avatar',
//             values['result']['user']['avatar']);

//         await storage.setItem('dob',
//             values['result']['user']['cf_dob']);

//         await storage.setItem('nic',
//             values['result']['user']['cf_nic']);

//         await storage.setItem('contact',
//             values['result']['user']['cf_phone']);

//         await storage.setItem('address',
//             values['result']['user']['address']);

//         await storage.setItem('apiation',
//             values['result']['user']['apiation']);

//         await storage.setItem('biostarId',
//             values['result']['user']['cf_biostar_id']);

//         // LEAVE QUOTA
//         await storage.setItem('annualQuota',
//             values['result']['leave_quota']['annual']);

//         await storage.setItem('casualQuota',
//             values['result']['leave_quota']['casual']);

//         await storage.setItem('medicalQuota',
//             values['result']['leave_quota']['medical']);

//         // LEAVE BALANCE
//         await storage.setItem('leaveAnnual',
//             values['result']['leave_balance']['annual']);

//         await storage.setItem('leaveCasual',
//             values['result']['leave_balance']['casual']);

//         await storage.setItem('leaveMedical',
//             values['result']['leave_balance']['medical']);

//         await storage.setItem('leaveNopay',
//             values['result']['leave_balance']['nopay']);

//         // LOGIN FLAG
//         await storage.setItem('login', true); // ✅ correct
//       }

//     } else {
//       showToast(values['message']);
//       apiFailedRedirect();
//     }

//     return values;

//   } catch (e) {
//     print("LOGIN ERROR => $e");
//   }
// }

  Future<void> showToast(dynamic text) async {
    String msg;
    try {
      if (text is List) {
        msg = text.map((e) => e?.toString() ?? '').join('\n');
      } else if (text is Map) {
        // Try common keys in order of priority
        if (text.containsKey('message')) {
          msg = text['message']?.toString() ?? '';
        } else if (text.containsKey('msg')) {
          msg = text['msg']?.toString() ?? '';
        } else if (text.containsKey('error')) {
          msg = text['error']?.toString() ?? '';
        } else if (text.containsKey('errors')) {
          final errs = text['errors'];
          if (errs is List) msg = errs.map((e) => e?.toString() ?? '').join('\n');
          else msg = errs?.toString() ?? '';
        } else {
          msg = text.toString();
        }
      } else {
        msg = text?.toString() ?? '';
      }
    } catch (_) {
      msg = text.toString();
    }

    // Ensure non-empty fallback
    if (msg.trim().isEmpty) msg = 'Message';

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 4,
      backgroundColor: HRColors.darkOrangeColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future checkInCheckout(date, type, {String? latitude, String? longitude, String? address}) async {
    await storage.ready;

    String url = "https://api.human.go.digitable.io/human/v2/api/attendance/check-in";
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

    Map<String, String> data = {
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

    // Collect device details and include in request body (best-effort)
    try {
      final deviceService = DeviceDetailsService();
      final details = await deviceService.collectAll();
      final dev = details['device'] as Map<String, dynamic>? ?? {};
      final deviceId = (dev['androidId'] ?? dev['identifierForVendor'] ?? dev['device'] ?? '').toString();
      final model = (dev['model'] ?? '').toString();
      final brand = (dev['brand'] ?? '').toString();
      final platform = (dev['platform'] ?? '').toString();
      final version = (dev['version'] ?? '').toString();
      final identifier = (dev['identifierForVendor'] ?? dev['androidId'] ?? '').toString();
      final ip = (details['ip'] ?? '').toString();
      final batteryLevel = (details['battery'] is Map) ? (details['battery']['level']?.toString() ?? '') : '';

      if (deviceId.isNotEmpty) data['device_id'] = deviceId;
      if (model.isNotEmpty) data['device_model'] = model;
      if (brand.isNotEmpty) data['device_brand'] = brand;
      if (platform.isNotEmpty) data['device_platform'] = platform;
      if (version.isNotEmpty) data['device_version'] = version;
      if (identifier.isNotEmpty) data['device_identifier'] = identifier;
      if (ip.isNotEmpty) data['device_ip'] = ip;
      if (batteryLevel.isNotEmpty) data['battery_level'] = batteryLevel;
    } catch (e) {
      print('[CHECK] device details collect failed: $e');
    }
    // Ensure tenant is injected after any modifications to `data` (checkout branch and device details)
    try { await _injectTenantToBody(data); } catch (_) {}
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

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: data, encoding: Encoding.getByName("utf-8"));
      final values = json.decode(response.body);
      print('[CHECK] response => ' + response.body);
      if (values is Map && values.containsKey('message')) print(values['message']);
      // Return decoded response map for caller to handle toast
      if (values is Map) return Map<String, dynamic>.from(values);
      return {'status': response.statusCode, 'body': response.body};
    } catch (e) {
      print('[CHECK] ERROR => $e');
      return null;
    }
  }



  Future<dynamic> leave(details) async {
    try {
      await storage.ready;
      final url = api.api() + "leave/store";

      // Safe extraction of fields
      final uidStr = storage.getItem('uid')?.toString() ?? '';

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
      await _injectTenantToBody(data);
      final headers = {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      
       "Oauth-Token": "q5t4uJB8pW94u1s7CGi4cIPuOC7TBk"
      };

      // Debug
      print('[LEAVE] POST $url');
      print('[LEAVE] headers => ' + headers.toString());
      print('[LEAVE] body => ' + data.toString());

      final response = await http.post(Uri.parse(url), headers: headers, body: data, encoding: Encoding.getByName("utf-8"));

      print('[LEAVE] response => ' + response.body);
      final values = json.decode(response.body);
      if (values is Map && values['status'] == true) {
        showToast(values['message'] ?? 'Submitted');
        return values;
      } else {
        // If API indicates failure, show message and return the response map
        if (values is Map) showToast(values['message'] ?? 'Failed');
        return values;
      }
    } catch (e, st) {
      print('[LEAVE] ERROR => $e');
      print(st);
      showToast('Failed to submit leave.');
      return {'status': false, 'message': 'Failed to submit leave.'};
    }
  }

  Future<List<MeSubsModel>> getMeSubs() async {
    final url = api.api() + "me";

    final uidStr = storage.getItem('uid')?.toString() ?? '';
    final tokenStr = storage.getItem('token')?.toString() ?? '';
    final qParams = {'user-id': uidStr};
    final header = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "Oauth-token": tokenStr
    };

    final finalUri = await _uriWithTenant(url, qParams);
    final response = await http.get(finalUri, headers: header);

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

      final finalUri = await _uriWithTenant(url, qParams);
      final response = await http.get(finalUri, headers: header);

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

      final accessToken = storage.getItem('access_token')?.toString() ?? '';
      if (accessToken.isEmpty) {
        print('[ME] Missing access_token in storage');
        return null;
      }
      print('[ME] Found access_token in storage: $accessToken');
      String tenant = storage.getItem('tenant')?.toString() ?? '';
      if (tenant.isEmpty) {
        tenant = storage.getItem('company')?.toString() ?? '';
      }

      if (tenant.isEmpty) {
        try {
          final payload = _decodeJwtPayload(accessToken);
          if (payload != null) {
            if (payload.containsKey('tenant')) tenant = payload['tenant']?.toString() ?? '';
            if (tenant.isEmpty && payload.containsKey('client_id')) {
              final cid = payload['client_id']?.toString() ?? '';
              if (cid.isNotEmpty) {
                final parts = cid.split(RegExp(r'[_-]'));
                tenant = parts.isNotEmpty ? parts.last : cid;
              }
            }
            if (tenant.isEmpty && payload.containsKey('company')) tenant = payload['company']?.toString() ?? '';
          }
        } catch (_) {}
      }

      // Persist derived tenant for future calls
      if (tenant.isNotEmpty) {
        try {
          await storage.setItem('tenant', tenant);
        } catch (_) {}
      }

      final baseUrl = "https://api.human.go.digitable.io/human/v2/api/auth/me";
      final uri = await _uriWithTenant(baseUrl);

      final headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      };
      if (tenant.isNotEmpty) headers['Tenant'] = tenant;

      final response = await http.get(uri, headers: headers);

      print('[ME] GET ${uri.toString()} status=${response.statusCode}');
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

    final url = 'https://api.human.go.digitable.io/human/v2/api/variables/variables/$userId';
    final uri = await _uriWithTenant(url);
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      //'Authorization': 'Bearer $accessToken',
    });

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
  try {
    await storage.ready;

    print('\n[DEBT] ===== FETCH DEBTS START =====');

    String? accessToken = storage.getItem('access_token')?.toString();
    final oauthToken = storage.getItem('token')?.toString() ?? '';
    final uid = (userId).toString().isNotEmpty
        ? userId.toString()
        : '605b4f4c277bf8660c7b23df';

    print('[DEBT] User ID: $uid');

    final url =
        'https://api.human.go.digitable.io/human/v2/api/debts/$uid';
    final uri = await _uriWithTenant(url);

    print('[DEBT] URL: $uri');

    Map<String, String> buildHeaders({
      bool includeAccess = true,
      bool includeOauth = true,
    }) {
      final h = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      if (includeAccess &&
          (accessToken != null && accessToken.isNotEmpty)) {
        h['Authorization'] = 'Bearer $accessToken';
        print('[DEBT] Using Access Token: ${accessToken!.substring(0, 8)}...');
      }

      if (includeOauth && oauthToken.isNotEmpty) {
        h['Oauth-Token'] = oauthToken;
        print('[DEBT] Using Oauth Token: ${oauthToken.substring(0, 8)}...');
      }

      return h;
    }

    print('[DEBT] Attempt 1 → Access + Oauth');

    var res = await http.get(
      uri,
      headers: buildHeaders(includeAccess: true, includeOauth: true),
    );

    print('[DEBT] Response Status (Attempt 1): ${res.statusCode}');
    print('[DEBT] Response Body: ${res.body}');

    // Retry logic
    if (res.statusCode == 401 || res.statusCode == 403) {
      print('[DEBT] Unauthorized. Trying fallback methods...');

      // Attempt 2 → oauth only
      if (oauthToken.isNotEmpty) {
        try {
          print('[DEBT] Attempt 2 → Oauth Only');
          res = await http.get(
            uri,
            headers:
                buildHeaders(includeAccess: false, includeOauth: true),
          );
          print('[DEBT] Response Status (Attempt 2): ${res.statusCode}');
        } catch (e) {
          print('[DEBT] Attempt 2 Failed: $e');
        }
      }

      // Attempt 3 → Refresh bearer
      if (res.statusCode == 401 || res.statusCode == 403) {
        try {
          print('[DEBT] Attempt 3 → Refreshing Bearer Token...');
          await fetchMeProfileWithBearer();
          accessToken =
              storage.getItem('access_token')?.toString();

          res = await http.get(
            uri,
            headers:
                buildHeaders(includeAccess: true, includeOauth: true),
          );

          print('[DEBT] Response Status (Attempt 3): ${res.statusCode}');
        } catch (e) {
          print('[DEBT] Attempt 3 Failed: $e');
        }
      }
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      print('[DEBT] Final Failure Status: ${res.statusCode}');
      if (res.statusCode == 401 || res.statusCode == 403) {
        try {
          showToast('Session expired. Please login again.');
        } catch (_) {}
      }
      throw Exception('Failed to load debts (${res.statusCode})');
    }

    print('[DEBT] Parsing response...');
    final decoded = jsonDecode(res.body);

    if (decoded is Map && decoded['data'] is Map) {
      final data = Map<String, dynamic>.from(decoded['data']);
      if (data['debts'] is List) {
        print('[DEBT] Debts Count: ${(data['debts'] as List).length}');
        print('[DEBT] ===== FETCH DEBTS SUCCESS =====\n');
        return List<dynamic>.from(data['debts']);
      }
    }

    print('[DEBT] No debts found.');
    print('[DEBT] ===== FETCH DEBTS END =====\n');
    return const [];
  } catch (e, st) {
    print('[DEBT] EXCEPTION: $e');
    print('[DEBT] STACKTRACE: $st');
    print('[DEBT] ===== FETCH DEBTS CRASHED =====\n');
    rethrow;
  }
}

  apiFailedRedirect() async {
    showToast("Session timeout.");
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

  Future<void> _injectTenantToBody(Map<String, String> body) async {
    try {
      await storage.ready;
      String tenant = storage.getItem('tenant')?.toString() ?? '';
      if (tenant.isEmpty) tenant = storage.getItem('company')?.toString() ?? '';
      if (tenant.isEmpty) {
        final accessToken = storage.getItem('access_token')?.toString() ?? '';
        if (accessToken.isNotEmpty) {
          final payload = _decodeJwtPayload(accessToken);
          if (payload != null) {
            tenant = (payload['tenant'] ?? payload['company'] ?? '').toString();
            if (tenant.isEmpty && payload.containsKey('client_id')) {
              final cid = payload['client_id']?.toString() ?? '';
              if (cid.isNotEmpty) {
                final parts = cid.split(RegExp(r'[_-]'));
                tenant = parts.isNotEmpty ? parts.last : cid;
              }
            }
          }
        }
      }
      if (tenant.isNotEmpty) {
        body['tenant'] = tenant;
      }
    } catch (_) {}
  }

  // Resolve tenant from storage or access token payload
  Future<String?> _resolveTenant() async {
    try {
      await storage.ready;
      String tenant = storage.getItem('tenant')?.toString() ?? '';
      if (tenant.isEmpty) tenant = storage.getItem('company')?.toString() ?? '';
      if (tenant.isEmpty) {
        final accessToken = storage.getItem('access_token')?.toString() ?? '';
        if (accessToken.isNotEmpty) {
          final payload = _decodeJwtPayload(accessToken);
          if (payload != null) {
            tenant = (payload['tenant'] ?? payload['company'] ?? '').toString();
            if (tenant.isEmpty && payload.containsKey('client_id')) {
              final cid = payload['client_id']?.toString() ?? '';
              if (cid.isNotEmpty) {
                final parts = cid.split(RegExp(r'[_-]'));
                tenant = parts.isNotEmpty ? parts.last : cid;
              }
            }
          }
        }
      }
      return tenant.isNotEmpty ? tenant : null;
    } catch (_) {
      return null;
    }
  }

  // Build a Uri and append tenant as query parameter when available.
  Future<Uri> _uriWithTenant(String url, [Map<String, String>? qParams]) async {
    try {
      final tenant = await _resolveTenant();
      final Uri uri = Uri.parse(url);
      final Map<String, String> merged = {};
      if (uri.queryParameters.isNotEmpty) merged.addAll(uri.queryParameters);
      if (qParams != null && qParams.isNotEmpty) merged.addAll(qParams);
      if (tenant != null && tenant.isNotEmpty) merged['tenant'] = tenant;
      return uri.replace(queryParameters: merged.isNotEmpty ? merged : null);
    } catch (_) {
      return Uri.parse(url);
    }
  }

  bool _isJwtExpired(String token) {
    try {
      final payload = _decodeJwtPayload(token);
      if (payload == null) return true;
      final expAny = payload['exp'] ?? payload['expiry'] ?? payload['expires_at'];
      if (expAny == null) return true;
      int expSec;
      if (expAny is int) expSec = expAny;
      else if (expAny is double) expSec = expAny.toInt();
      else expSec = int.tryParse(expAny.toString()) ?? 0;
      if (expSec <= 0) return true;
      final nowSec = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      return expSec <= nowSec;
    } catch (_) {
      return true;
    }
  }

  Future<bool> hasValidAccessToken() async {
    try {
      await storage.ready;
      var token = storage.getItem('access_token')?.toString() ?? '';
      if (token.isEmpty) {
        try {
          final secure = const FlutterSecureStorage();
          final secureToken = await secure.read(key: 'access_token');
          if (secureToken != null && secureToken.isNotEmpty) {
            token = secureToken;
            try { await storage.setItem('access_token', token); } catch (_) {}
          }
        } catch (_) {}
      }

      if (token.isEmpty) return false;
      return !_isJwtExpired(token);
    } catch (_) {
      return false;
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

  
  Future<List<AttendanceModel>> getAttendanceForUserMonth({String? userId, String? payroll}) async {
    try {
      await storage.ready;

      bool looksLikeMongoId(String s) => RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(s);

      String uid = (userId ?? '').toString();
      if (!looksLikeMongoId(uid)) uid = '';
      if (uid.isEmpty) {
        final stored = storage.getItem('human_user_id')?.toString() ?? '';
        if (looksLikeMongoId(stored)) uid = stored;
      }
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
      final tenant = await _resolveTenant() ?? '';
      String baseUrl;
      if (tenant.isNotEmpty) {
        baseUrl = 'https://api.human.go.digitable.io/human/v2/api/attendance/user/$tenant/$uid/';
      } else {
        baseUrl = 'https://api.human.go.digitable.io/human/v2/api/attendance/user/$uid/';
      }
      final p = (payroll ?? '').trim();
      final qParams = <String, String>{};
      if (p.isNotEmpty) qParams['payroll'] = p;
      if (tenant.isNotEmpty) qParams['tenant'] = tenant;

      final uri = await _uriWithTenant(baseUrl, qParams);
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


  Future<List<AttendanceModel>> getAttendanceForUser(String userId) async {
    return await getAttendanceForUserMonth(userId: userId);
  }

  Map<String, dynamic> _normalizeAttendanceV2Record(Map<String, dynamic> r) {
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






  Future<List<Map<String, dynamic>>> getSalarySlips() async {
    try {
      await storage.ready;

      // Resolve uid from storage / access token / bearer profile
      String uid = storage.getItem('uid')?.toString() ?? '';
      if (uid.isEmpty) {
        uid = await ensureUidFromAccessToken() ?? '';
      }
      if (uid.isEmpty) {
        final me = await fetchMeProfileWithBearer();
        final dataAny = me?['data'] ?? me?['result'] ?? me?['user'];
        if (dataAny is Map) {
          uid = (dataAny['_id'] ?? dataAny['id'] ?? '').toString();
          if (uid.isNotEmpty) await storage.setItem('uid', uid);
        }
      }

      if (uid.isEmpty) {
        print('[SLIPS] missing uid, cannot fetch slips');
        return <Map<String, dynamic>>[];
      }

      final url = 'https://domex.rype3.com/human/api/v1/get-slips/$uid';
      // Do NOT add tenant - use plain URI with only uid
      final uri = Uri.parse(url);

      final oauthToken = storage.getItem('token')?.toString() ?? '';
      final accessToken = storage.getItem('access_token')?.toString() ?? '';

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (oauthToken.isNotEmpty) headers['Oauth-Token'] = oauthToken;
      if (accessToken.isNotEmpty) headers['Authorization'] = 'Bearer $accessToken';

      print('[SLIPS] GET $uri');
      final res = await http.get(uri, headers: headers);

      print('[SLIPS] status=${res.statusCode}');
      print('[SLIPS] body=${res.body}');

      if (res.statusCode == 401 || res.statusCode == 403) {
        try { showToast('Session expired. Please login again.'); } catch (_) {}
        return <Map<String, dynamic>>[];
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return <Map<String, dynamic>>[];
      }

      final decoded = jsonDecode(res.body);

      // Normalize various response shapes into a list of maps
      List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
      if (decoded is List) {
        out = decoded.map((e) {
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{'raw': e};
        }).toList();
      } else if (decoded is Map) {
        // common keys where list might live
        final candidates = ['data', 'result', 'slips', 'items'];
        for (final k in candidates) {
          if (decoded.containsKey(k) && decoded[k] is List) {
            out = (decoded[k] as List).map((e) {
              if (e is Map) return Map<String, dynamic>.from(e);
              return <String, dynamic>{'raw': e};
            }).toList();
            break;
          }
        }
        // fallback: if the map itself looks like a single slip, return it wrapped
        if (out.isEmpty && decoded.keys.any((k) => ['id', 'pdf', 'title', 'month'].contains(k))) {
          out = [Map<String, dynamic>.from(decoded)];
        }
      }

      return out;
    } catch (e, st) {
      print('[SLIPS] ERROR => $e');
      print(st);
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>> getSalarySlipDetail(String id) async {
    // Dummy implementation: return a detailed breakdown for given slip id
    await Future.delayed(const Duration(milliseconds: 350));
    return {
      'id': id,
      'basic': 50000,
      'allowances': 8000,
      'deductions': 3000,
      'tax': 5000,
      'net_pay': 50000,
      'notes': 'This is a dummy salary summary for $id'
    };
  }

Future<Map<String, dynamic>> emailSalarySlip(String id) async {
  try {
    await storage.ready;

    final url = 'https://domex.rype3.com/human/api/v1/slip_email/$id';
    final oauthToken = storage.getItem('token')?.toString() ?? '';
    final accessToken = storage.getItem('access_token')?.toString() ?? '';

    print('[SLIP] ==== EMAIL SALARY SLIP START ====');
    print('[SLIP] ID: $id');
    print('[SLIP] URL: $url');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (oauthToken.isNotEmpty) {
      headers['Oauth-Token'] = oauthToken;
      print('[SLIP] Oauth-Token: ${oauthToken.substring(0, 8)}...'); // partial log
    }

    if (accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
      print('[SLIP] Access-Token: ${accessToken.substring(0, 8)}...');
    }

    print('[SLIP] Sending POST request...');

    final res = await http.post(Uri.parse(url), headers: headers);

    print('[SLIP] Response Status: ${res.statusCode}');
    print('[SLIP] Response Body: ${res.body}');
    print('[SLIP] ==== RESPONSE RECEIVED ====');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) {
          print('[SLIP] Parsed JSON success');
          return {
            'status': decoded['status'] ?? true,
            'message': decoded['message']?.toString() ?? 'Email request sent',
            'data': decoded,
          };
        }
        return {
          'status': true,
          'message': 'Email request sent',
          'raw': res.body
        };
      } catch (err) {
        print('[SLIP] JSON Parse Error (but success status): $err');
        return {
          'status': true,
          'message': 'Email request sent',
          'raw': res.body
        };
      }
    }

    // Non-2xx response
    String msg = 'Failed to email salary slip (${res.statusCode})';
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['message'] != null) {
        msg = decoded['message'].toString();
      }
    } catch (_) {}

    print('[SLIP] ERROR: $msg');

    return {
      'status': false,
      'message': msg,
      'code': res.statusCode
    };
  } catch (e, st) {
    print('[SLIP] EXCEPTION: $e');
    print('[SLIP] STACKTRACE: $st');

    return {
      'status': false,
      'message': e.toString()
    };
  }
}


  Future<Map<String, dynamic>> sendAuthPinMobile({required String tenant, required String nic, Map<String, String>? deviceInfo}) async {
    try {
      await storage.ready;
      final url = api.api() + 'sso/auth-pin-mobile';
      final oauthToken = storage.getItem('token')?.toString() ?? '';
      final accessToken = storage.getItem('access_token')?.toString() ?? '';

      final body = <String, dynamic>{
        'tenant': tenant,
        'nic': nic,
      };
      if (deviceInfo != null) body.addAll(deviceInfo);

      final headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
      if (oauthToken.isNotEmpty) headers['Oauth-Token'] = oauthToken;
      if (accessToken.isNotEmpty) headers['Authorization'] = 'Bearer $accessToken';

      print('[AUTHPIN] POST $url');
      print('[AUTHPIN] body => $body');

      final res = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
      print('[AUTHPIN] status=${res.statusCode} body=${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        return {'status': true, 'message': 'OTP requested'};
      }

      String msg = 'Failed to request OTP (${res.statusCode})';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['message'] != null) msg = decoded['message'].toString();
      } catch (_) {}
      return {'status': false, 'message': msg, 'code': res.statusCode};
    } catch (e, st) {
      print('[AUTHPIN] ERROR: $e');
      print(st);
      return {'status': false, 'message': e.toString()};
    }
  }

  /// Verify the OTP (PIN) for mobile auth. On success, store access/refresh tokens if present.
  Future<Map<String, dynamic>> verifyAuthPinMobile({required String tenant, required String nic, required String pin, Map<String, String>? deviceInfo}) async {
    try {
      await storage.ready;
      final url = api.api() + 'sso/auth-pin-mobile/verify';
      final oauthToken = storage.getItem('token')?.toString() ?? '';

      final body = <String, dynamic>{'tenant': tenant, 'nic': nic, 'pin': pin};
      if (deviceInfo != null) body.addAll(deviceInfo);

      final headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
      if (oauthToken.isNotEmpty) headers['Oauth-Token'] = oauthToken;

      print('[VERIFYPIN] POST $url');
      print('[VERIFYPIN] body => $body');

      final res = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
      print('[VERIFYPIN] status=${res.statusCode} body=${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) {
          // If response contains tokens, persist
          try {
            final result = decoded['result'] ?? decoded;
            if (result is Map) {
              final access = (result['access_token'] ?? result['accessToken'] ?? result['access'])?.toString();
              final refresh = (result['refresh_token'] ?? result['refreshToken'] ?? result['refresh'])?.toString();
              if (access != null && access.isNotEmpty) await storage.setItem('access_token', access);
              if (refresh != null && refresh.isNotEmpty) await storage.setItem('refresh_token', refresh);
            }
          } catch (_) {}
          return Map<String, dynamic>.from(decoded);
        }
        return {'status': true, 'message': 'OTP verified'};
      }

      String msg = 'Failed to verify OTP (${res.statusCode})';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['message'] != null) msg = decoded['message'].toString();
      } catch (_) {}
      return {'status': false, 'message': msg, 'code': res.statusCode};
    } catch (e, st) {
      print('[VERIFYPIN] ERROR: $e');
      print(st);
      return {'status': false, 'message': e.toString()};
    }
  }

  /// Send scanned QR data to backend and retrieve tenant coordinate (latitude & longitude)
  Future<Map<String, dynamic>> getTenantCoordinateFromQr(String qrData, {String? tenant}) async {
    try {
      await storage.ready;
      // NOTE: returning hard-coded coordinates for frontend-only testing.
      // Latitude/Longitude set to Colombo, Sri Lanka (6.9271, 79.8612).
      final hardcoded = {
        'status': true,
        'message': 'Using hardcoded coordinates',
        'data': {'latitude': '6.9271', 'longitude': '79.8612'}
      };
      print('[QR] Returning hardcoded coordinates for QR: $qrData');
      return hardcoded;
    } catch (e, st) {
      print('[QR] ERROR: $e');
      print(st);
      return {'status': false, 'message': e.toString()};
    }
  }
}




