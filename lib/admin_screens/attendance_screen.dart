import 'package:iapp/services/adminApiClass.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:iapp/admin_screens/home_screen.dart';
import '../constants/constants.dart';
import '../dto/user.dart';
import '../user_screens/login_screen.dart';
import '../services/exportExcel.dart';
import '../services/getLoc_Time.dart';
import '../widgets/admindrawer_components.dart';
import 'individual_attendance.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({Key? key}) : super(key: key);
  static String routeName = 'AdminAttendanceScreen';

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  GlobalKey<ScaffoldState> key = GlobalKey();

  int? current_Mon, year, month;
  static final _searchController = TextEditingController();
  String? formattedStartDate, formattedEndDate;
  Future<List<User>>? _user;
  GetLoc_Time location = GetLoc_Time();
  String? _searchString, name, empId;
  List<User> _filteredUser = [];
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _currentPage = 0;
  final paginatedKey = GlobalKey<PaginatedDataTableState>();
  String? _selectedOption;

  final dataTableKey = GlobalKey<_AdminAttendanceScreenState>();
  _UserDataSource? _userDataSource;
  List months = [
    'January',
    'Febraury',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    _clearSearch();
    location.requestPermission();
    location.getDate();
    year = int.parse(location.year);
    month = int.parse(location.month);
    _user = ApiService().fetchCount(currentMonth, currentYear);

    ApiService().fetchCount(month, year).then((value) {
      setState(() {
        _filteredUser = value;
      });
    });
  }

  void _filterUsers(value) {
    setState(() {
      _searchString = value;
      print(_searchString);
      if (_searchString!.isEmpty) {
        _filteredUser = _user as List<User>;
      } else {
        _filteredUser = _filteredUser
            .where((data) =>
                data.name!.toLowerCase().contains(_searchString!.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
     ApiService().fetchCount(month, year).then((value) {
        setState(() {
          print(value);
          _filteredUser = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: DrawerComponent(
          image: 'assets/images/user.png',
          name: 'Admin',
          onPress1: () {
            Navigator.pushNamed(context, AdminHomeScreen.routeName);
          },
          onPress2: () {
            Navigator.pushNamed(context, AdminAttendanceScreen.routeName);
          },
          onPress3: () {
            Navigator.pushNamed(context, LoginScreen.routeName);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Logged out Successfully".toString())));
          },
        ),
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: SingleChildScrollView(
            child: Stack(children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xB6B091CF),
                        Color(0xFFAD8DCD),
                      ]),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              icon: const Icon(
                                Icons.menu,
                                size: 23,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AdminHomeScreen.routeName);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_circle_left_outlined,
                                      color: Color(0xFF3F3D56),
                                      size: 28,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(65.0),
                          child: Text(
                            'Attendance Details',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: adminHomeBG,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: MediaQuery.of(context).size.height / 14.5,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(20.0)),
                              color: Colors.white),
                          margin: const EdgeInsets.fromLTRB(20, 40, 20, 0.0),
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(splashColor: Colors.transparent),
                            child: TextField(
                              controller: _searchController,
                              autofocus: false,
                              onChanged: (value) {
                                _filterUsers(value);
                              },
                              style: const TextStyle(
                                  fontSize: 15.0, color: Color(0xFFbdc6cf)),
                              decoration: InputDecoration(
                                prefixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () {},
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _clearSearch();
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Search',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20.7),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 22,
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: [
                              FutureBuilder(
                                future: _user,
                                builder: (context, snapshot) {
                                  print(snapshot.data);
                                  print(snapshot.hasData);
                                  if (snapshot.hasData) {
                                    var dataSource = _UserDataSource(
                                        _filteredUser,
                                        _rowsPerPage,
                                        _currentPage,
                                        name,
                                        context);
                                    if (dataSource.rowCount == 0) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: const Text('No data available.'),
                                      );
                                    }
                                    return Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.15,
                                      decoration: const BoxDecoration(
                                          //borderRadius: BorderRadius.circular(15.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 15.0,
                                              offset: Offset(0, 2),
                                            )
                                          ]),
                                      child: PaginatedDataTable(
                                        header: const Text('Attendance Details'),
                                        key: paginatedKey,
                                        arrowHeadColor: Colors.black,
                                        columnSpacing: 15,
                                        rowsPerPage: _rowsPerPage,
                                        onRowsPerPageChanged: (newRowsPerPage) {
                                          setState(() {
                                            _rowsPerPage = newRowsPerPage!;
                                          });
                                        },
                                        initialFirstRowIndex: 0,
                                        onPageChanged: (newPage) {
                                          setState(() {
                                            _currentPage = newPage;
                                          });
                                        },
                                        actions: [
                                          IconButton(
                                            icon: const Icon(Icons.refresh),
                                            onPressed: () {
                                              print('onPress called');
                                              _clearSearch();
                                              setState(() {
                                                formattedStartDate = null;
                                                formattedEndDate = null;
                                              });
                                            },
                                          )
                                        ],
                                        columns: const [
                                          DataColumn(
                                            label: Text('S.No'),
                                          ),
                                          DataColumn(
                                            label: Text('Name'),
                                          ),
                                          DataColumn(
                                            label: Text('Present'),
                                          ),
                                          DataColumn(
                                            label: Text('Absent'),
                                          ),
                                        ],
                                        source: _UserDataSource(
                                            _filteredUser,
                                            _rowsPerPage,
                                            _currentPage,
                                            name,
                                            context),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  }
                                  return const CircularProgressIndicator();
                                },
                              ),
                              Container(
                                child: MaterialButton(
                                  onPressed: () async {
                                    List attendanceDetailsList;
                                    var attendanceCount;
                                    //fordate range
                                    print(formattedEndDate);
                                    if (formattedStartDate != null &&
                                        formattedEndDate != null) {
                                      print('range api');
                                      //calling api method of data
                                      attendanceCount=await ApiService()
                                          .exportByRangeCount(formattedStartDate, formattedEndDate);

                                      attendanceDetailsList =
                                          await ApiService().exportByRange(
                                              formattedStartDate,
                                              formattedEndDate);

                                      //calling export excel method
                                      ExportExcel().exportOverRange(
                                          context, attendanceDetailsList,attendanceCount);
                                    } else {
                                      //calling api methods
                                      print('month wise');
                                      attendanceCount=ApiService().fetchCount(currentMonth, currentYear);
                                      attendanceDetailsList =
                                          await ApiService().exportByMonth(
                                              currentMonth, currentYear);
                                      //exporting datas to excel
                                      ExportExcel().exportOverMonth(
                                          context, attendanceDetailsList,attendanceCount);

                                      //   attendanceDetails();
                                    }
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 15,
                                    width: MediaQuery.of(context).size.width /
                                        1.16,
                                    margin:
                                        const EdgeInsets.only(top: 0.1, bottom: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                        bottomRight: Radius.circular(25),
                                        bottomLeft: Radius.circular(25),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: const Center(
                                        child: Text(
                                      'Export',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(
                                            0xFF5278FF,
                                          ),
                                          decoration: TextDecoration.underline),
                                    )),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height / 4.50,
                  right: 20,
                  child: IconButton(
                    onPressed: () {
                      showOptions(context);
                    },
                    icon: const Icon(
                      Icons.filter_list_off_rounded,
                      color: Color(0xFF3F3D56),
                    ),
                  )),
              Positioned(
                top: MediaQuery.of(context).size.height / 3.25,
                left: 44,
                right: 49,
                child: Container(
                  height: 40,
                  width: 282,
                  decoration: BoxDecoration(
                      color: BGcolor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15.0,
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: const Color(0xff3F3D56),
                        iconSize: 25,
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () async {
                          setState(() {
                            currentMonth--;
                            if (currentMonth == 0) {
                              currentMonth = 12;
                              currentYear--;
                            }
                          });
                          List<User> userList =
                              await ApiService().fetchCount(currentMonth, currentYear);
                          setState(() {
                            _filteredUser = userList; // update the data source
                            _userDataSource = _UserDataSource(
                              _filteredUser,
                              _rowsPerPage,
                              _currentPage,
                              name,
                              context,
                            );
                          });

                          print(currentMonth);
                          print(currentYear);
                        },
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Text(
                        "${months[currentMonth - 1]} - $currentYear",
                        style:
                            const TextStyle(fontSize: 17, color: Color(0xFF003756)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 12,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                        ),
                        iconSize: 25,
                        color: const Color(0xff3F3D56),
                        onPressed: () async {
                          setState(() {
                            currentMonth++;
                            if (currentMonth == 13) {
                              currentMonth = 1;
                              currentYear++;
                            }
                          });
                          List<User> userList =
                              await ApiService().fetchCount(currentMonth, currentYear);
                          setState(() {
                            _filteredUser = userList; // update the data source
                            _userDataSource = _UserDataSource(
                              _filteredUser,
                              _rowsPerPage,
                              _currentPage,
                              name,
                              context,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }


  void showOptions(BuildContext context) async {
    final result = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 250, 40, 0),
      items: [
        PopupMenuItem(
          value: "Select Date",
          child: Row(
            children: const [
              Icon(
                Icons.calendar_month,
                color: Color(0xFF3F3F3F),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Select Date",
                style: TextStyle(color: Color(0xFf747474)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "Over All",
          child: Row(
            children: const [
              Icon(
                Icons.filter_list_off,
                color: Color(0xFF3F3F3F),
              ),
              SizedBox(
                width: 10,
              ),
              Text("Over All", style: TextStyle(color: Color(0xFf747474))),
            ],
          ),
        ),
      ],
    );

    if (result != null) {
      setState(() {
        _selectedOption = result;
      });
    }
    if (result == 'Select Date') {
      DateTimeRange? dateTimeRange = await getDateRange(context);
    }
  }

  getDateRange(BuildContext context) {
    return showDateRangePicker(
      context: context,
      firstDate: DateTime.utc(2018, 10, 16),
      lastDate: DateTime.utc(2050, 3, 14),
      helpText: 'please select a date',
      builder: (context, child) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 1.45,
                width: MediaQuery.of(context).size.width / 1.2,
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15.0,
                    offset: Offset(0, 2),
                  ),
                ], borderRadius: BorderRadius.circular(30.0)),
                child: child,
              ),
            ),
          ],
        );
      },
    ).then((dateRange) {
      if (dateRange != null) {
        // make API call with selected date range
        print("Selected date range: ${dateRange.start} - ${dateRange.end}");
        // make API call here using the selected date range
        DateTime startDate = dateRange.start;
        DateTime endDate = dateRange.end;
        formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
        formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
        //calling count api for range
        ApiService()
            .exportByRangeCount(formattedStartDate, formattedEndDate)
            .then((response) {
          if (response.isNotEmpty) {
            List<Map<String, dynamic>> data =
                List<Map<String, dynamic>>.from(response);
            List<User> userList =
                data.map((map) => User.fromJson(map)).toList();
            _filteredUser = userList; // update the data source
            setState(() {
            });
          }
        });
      }
    });
  }
}

class _UserDataSource extends DataTableSource {
  BuildContext context;
  final List<User> _users;
  final int _rowsPerPage;
  final int _currentPage;
  var name;
  String _searchQuery = '';

  _UserDataSource(this._users, this._rowsPerPage, this._currentPage, this.name,
      this.context);

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    final int pageIndex = index ~/ _rowsPerPage;
    final int pageOffset = pageIndex * _rowsPerPage;
    final int localIndex = index - pageOffset;
    if (localIndex >= _users.length) {
      return null;
    }
    final User user = _users[localIndex];
    if (_searchQuery.isNotEmpty &&
        !user.name!.toLowerCase().contains(_searchQuery)) {
      return null;
    }
    if (user.name == null || user.Present == null || user.Absent == null) {
      return null;
    }
    return DataRow(
      cells: [
        DataCell(Text('${pageOffset + localIndex + 1}',
            style: const TextStyle(color: Color(0xFF003756)))),
        DataCell(
          InkWell(
            child: Text(user.name ?? '----',
                style: const TextStyle(color: Color(0xFF003756))),
            onTap: () {
              name = user.name;
              Navigator.pushNamed(context, UserAttendanceScreen.routeName,
                  arguments: {'name': name});
            },
          ),
        ),
        DataCell(
          Center(
            child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF5278FF),
                    Color(0xFF6C84D9),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  user.Present == null ? '----' : '${user.Present}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFCE3636),
                    Color(0xFFFF0000),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  user.Absent == null ? '----' : '${user.Absent}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _users
      .where((user) =>
          user.name != null &&
          user.Present != null &&
          user.Absent != null &&
          user.name!.toLowerCase().contains(_searchQuery))
      .length;

  @override
  int get selectedRowCount => 0;
}
