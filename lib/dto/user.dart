class User {
  String? message;
  int? id,Present,Absent;
  String? date;
  String? email;
  String? loginTime;
  String? status;
  String? totalWorkingHours;
  String? loginLocation;
  String? logoutTime;
  String? logoutLocation;
  String? workmode,workModeCheckOut;
  String? empId,empUniqueId;
  String? empEmailId;
  String? empName,name;


  User(
      {this.id,
        this.empUniqueId,
      this.date,
      this.email,
      this.loginTime,
      this.loginLocation,
      this.logoutTime,
      this.logoutLocation,
      this.status,
      this.totalWorkingHours,
      this.workmode,
      this.empName,
      this.empId,
      this.name,
      this.empEmailId,
      this.Absent,this.Present,this.workModeCheckOut});

  // User({int? status,
  // String? message,
  // });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      empUniqueId: json["empUniqueId"],

      date: json["date"],
      email: json["email"],
      loginTime: json["loginTime"],
      loginLocation: json["loginLocation"],
      logoutTime: json["logoutTime"],
      logoutLocation: json["logoutLocation"],
      status: json["status"],
      totalWorkingHours: json["totalWorkingHours"],
      workmode: json["workmode"],
      workModeCheckOut: json["workModeCheckOut"],

      empId: json["empId"],
      empEmailId: json["empEmailId"],
      empName: json["empName"],
      name: json["name"],
      Present: json["Present"],
      Absent: json["Absent"],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['Present'] = Present;
    data['Absent'] = Absent;
    data['workModeCheckOut'] = workModeCheckOut;

    data['date'] = date;
    data['email'] = email;
    data['loginTime'] = loginTime;
    data["loginLocation"] = loginLocation;
    data["logoutTime"] = logoutTime;
    data["logoutLocation"] = logoutLocation;
    data['empId'] = empId;
    data['empEmailId'] = empEmailId;
    data['empName'] = empName;
    data['empUniqueId'] = empUniqueId;

    return data;
  }
}
