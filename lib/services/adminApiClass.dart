import 'dart:convert';
import 'package:http/http.dart' as http;

import '../dto/user.dart';

class AdminApiClass{
  //exporting in month api for all details
  Future<List> exportByMonth(int month, int year) async {
    try {
      var api =
          'http://ems-ma.ideassionlive.in/api/UserActivity/exportUserAttendenceByMonth?month=$month&year=$year';
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

  Future<List> exportByRange(String? startDate, String? endDate) async {
    try {
      var api =
          'http://192.168.1.26:8081/UserActivity/adminUserListFromDateRange?startDate=$startDate&endDate=$endDate';
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
 //for counts only
  Future<List<Map<String, dynamic>>> exportByRangeCount(String? startDate,String? endDate) async {
    try {
      var response = await http.get(Uri.parse(
          'http://ems-ma.ideassionlive.in/api/UserActivity/findAllStatusCountByRange?startDate=$startDate&endDate=$endDate'));
      print(response.statusCode);
      print(response);
      if (response.statusCode == 200) {
        var getUsersData = json.decode(response.body) as List;
        print(getUsersData);

        var listUsers = getUsersData.cast<Map<String, dynamic>>(); // cast to List<Map<String, dynamic>>
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
