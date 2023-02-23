import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApiClass{
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
}