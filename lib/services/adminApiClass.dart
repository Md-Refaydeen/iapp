import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iapp/constants/constants.dart';

import '../dto/user.dart';

class ApiService {
  //exporting in month api for all details ui
  Future<List<User>> fetchCount(int? month, int? year) async {
    try {
      var response = await http.get(Uri.parse(
          '$appUrl/UserActivity/countAllStatusByMonth?month=$month&year=$year'));
      print(response.statusCode);
      print(response);
      if (response.statusCode == 200) {
        var getUsersData = json.decode(response.body) as List;
        print(getUsersData);

        var listUsers = getUsersData.map((i) => User.fromJson(i)).toList();
        return listUsers;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  //month wise api for all users export
  Future<List> exportByMonth(int month, int year) async {
    try {
      var api =
          '$appUrl/UserActivity/exportUserAttendenceByMonth?month=$month&year=$year';
      List<dynamic> dataList = [];

      print(api);
      var response = await http.get(Uri.parse(api));
      print(response);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(response.body);
        for (String key in map.keys) {
          dataList.add({key: map[key]});
        }
        return dataList;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  //range wise api for all users export
  Future<List> exportByRange(String? startDate, String? endDate) async {
    try {
      var api =
          '$appUrl/UserActivity/adminUserListFromDateRange?startDate=$startDate&endDate=$endDate';
      List<dynamic> dataList = [];

      print(api);
      var response = await http.get(Uri.parse(api));
      print(response);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(response.body);
        for (String key in map.keys) {
          dataList.add({key: map[key]});
        }
        return dataList;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  //for counts only showing in UI
  Future<List<Map<String, dynamic>>> exportByRangeCount(
      String? startDate, String? endDate) async {
    try {
      var response = await http.get(Uri.parse(
          '$appUrl/UserActivity/findAllStatusCountByRange?startDate=$startDate&endDate=$endDate'));
      print(response.statusCode);
      print(response);
      if (response.statusCode == 200) {
        var getUsersData = json.decode(response.body) as List;
        print(getUsersData);

        var listUsers = getUsersData
            .cast<Map<String, dynamic>>(); // cast to List<Map<String, dynamic>>
        return listUsers;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  //for showing and exporting for individual users select by rangeDate
  Future<List<User>> individualRangeDate(
      var email, String? startDate, String? endDate) async {
    try {
      var api =
          '$appUrl/UserActivity/userListRangeAndEmail?email=$email&startDate=$startDate&endDate=$endDate';
      print(api);
      var response = await http.get(Uri.parse(api));
      print(response);
      if (response.statusCode == 200) {
        var getUsersData = json.decode(response.body) as List;
        print(getUsersData);
        var listUsers = getUsersData.map((i) => User.fromJson(i)).toList();
        return listUsers;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }


  Future<List<User>> fetchUsers(var date, var status) async {
    try {
      var api =
          '$appUrl/UserActivity/adminFindAllByDateAndStatus?date=$date&status=$status';
      print(api);
      var response = await http.get(Uri.parse(api));
      if (response.statusCode == 200) {
        var getUsersData = json.decode(response.body) as List;
        print(getUsersData);
        var listUsers = getUsersData.map((i) => User.fromJson(i)).toList();
        return listUsers;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }


}
