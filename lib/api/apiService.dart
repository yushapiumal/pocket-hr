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
        await storage.setItem('uid',
            values['result']['user']['id']);

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
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Color.fromARGB(255, 211, 211, 211),
        textColor: Colors.black);
  }

  Future checkInCheckout(date, type) async {
    String url = api.api() + "check-in";

    var data = {
      'uid': storage.getItem('uid'),
      'checked_at': date, //'2022-02-21T14:21:10+0530',
      'user-id': storage.getItem('uid'),
    };

    if (type == 'checkout') {
      url = api.api() + "check-out";
      data = {
        'uid': storage.getItem('uid'),
        'checkout_at': date,
        'user-id': storage.getItem('uid'),
      };
    }

    final response = await http.post(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));

    var values = json.decode(response.body);
    print(values['message']);
    showToast(values['message']);
    print(values);
  }

  Future<List<AttendanceModel>> getMyAttendance(type) async {
    try {
      String url = api.api() + "attendance/individual";
      var payrollTag = "";
      if (type == 'cur') {
        payrollTag = storage.getItem('payroll_active_id');
      } else {
        payrollTag = storage.getItem('payroll_past_id');
      }

      var data = {
        'payrolltag': payrollTag,
        'user-id': storage.getItem('uid'),
        'month': type
      };

      final response = await http.post(Uri.parse(url),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
            "Oauth-Token": storage.getItem('token')
          },
          body: data,
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData =
            new Map<String, dynamic>.from(json.decode(response.body));

        if (jsonData['status']) {
          final detail = (jsonData['result']['days'] as List)
              .map((data) => AttendanceModel.fromJson(data))
              .toList();
          return detail;
        } else {
          return [];
        }
      } else {
        throw Exception(e);
      }
    } catch (error, stackTrace) {
      print("Error :  $error");
      print("StackTrace :  $stackTrace");
      throw Exception(e);
    }
  }

  Future leave(details) async {
    String url = api.api() + "leave/store";
    var data = {
      'leave_title': details['leave_title'],
      'from_date': details['from_date'],
      'to_date': details['to_date'],
      'user-id': storage.getItem('uid'),
      // 'covering_employee': storage.getItem('uid'),
      'leave_type': details['leave_type'],
      'type': details['type'],
      'session': details['session'],
      'description': details['description']
    };

    final response = await http.post(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          "Oauth-token": storage.getItem('token')
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));
    print(response.statusCode);
    var values = json.decode(response.body);
    print(values);
    if (values['status']) {
      showToast(values['message']);
      return values['status'];
    } else {
      apiFailedRedirect();
      return values['status'];
    }
  }

  Future<List<MeSubsModel>> getMeSubs() async {
    String url = api.api() + "me";

    Map<String, String> qParams = {
      'user-id': storage.getItem('uid'),
    };
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "Oauth-token": storage.getItem('token')
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
    String url = "";
    if (anotherPerson) {
      url = api.api() + "leave/list/" + anotherPerson;
    } else {
      url = api.api() + "leave/list";
    }
    Map<String, String> qParams = {
      'user-id': storage.getItem('uid'),
    };
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "Oauth-token": storage.getItem('token')
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
        final detail = (jsonData['result']['leaves'] as List)
            .map((data) => MyLeavesModel.fromJson(data))
            .toList();

        return detail;
      } else {
        return [];
      }
    } else {
      showToast("Failed to load leaves");
      throw Exception("Failed to load leaves");
    }
  }

  apiFailedRedirect() async {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    // storage.clear();
    showToast("Session timeout.");
    // navigatorKey.currentState!.pushNamed('/login');
  }
}
