import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iapp/user_screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:iapp/services/getLoc_Time.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../admin_screens/home_screen.dart';
import '../constants/constants.dart';
import '../dto/user.dart';

late bool _passwordVisible;

class LoginScreen extends StatefulWidget {
  static String routeName = 'LoginScreen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static var _emailController = TextEditingController();
  static var _passwordController = TextEditingController();
  Location location = Location();
  List<String> values = ['Office', 'Home', 'Nippon'];
  int _initialLabelIndex = 0; // Set the initial label index to 1 for "Office"


  String adminId = 'II5',adminName="Admin";
  bool isLoading = false;
  bool isSwitched = true;
  var textValue='Office';
  String? name, empEmail, mode;
  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
    location.getPermission();
  }

  void toggleSwitch(bool value) {
    if (isSwitched == true) {
      setState(() {
        isSwitched = false;
        textValue = 'Home';
      });
      print('Home');
    } else {
      setState(() {
        isSwitched = true;
        textValue = 'Office';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(

          child: ListView(children: [
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height/15,
                  ),
                  Image.asset(
                    'assets/images/Ideassion.png',
                    height: 158,
                    width: 650,
                  ),
                  sizedBox,
                  sizedBox,
                  sizedBox,
                  sizedBox,
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height/50,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: kDefaultPadding * 2,
                                    width: kDefaultPadding * 2,
                                  ),
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: labels),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                  ),
                                  ToggleSwitch(
                                    minWidth: 72.0,
                                    minHeight: 40.0,
                                    initialLabelIndex: _initialLabelIndex,
                                    cornerRadius: 20.0,
                                    activeFgColor: Colors.white,
                                    inactiveBgColor: bgColor,
                                    inactiveFgColor: Colors.white,
                                    totalSwitches: 3,
                                    animate: true, // with just animate set to true, default curve = Curves.easeIn
                                    curve: Curves.bounceInOut,
                                    icons: [
                                      Icons.work_history_rounded,
                                      Icons.home_work_outlined,
                                      null
                                    ],

                                    labels: ['','','Nippon'],
                                    customTextStyles: [
                                      null,
                                      null,
                                      TextStyle(color: Colors.white,fontSize: 14)
                                    ],

                                    iconSize: 30.0,
                                    borderColor: [ attendance,],
                                    dividerColor: Colors.blueGrey,
                                    activeBgColors: [ [Color(0xfffeda75), Color(0xfffa7e1e), Color(0xffd62976), Color(0xff962fbf), Color(0xff4f5bd5)],[Color(0xff3b5998), Color(0xff8b9dc3)], [Color(0xff00aeff), Color(0xff0077f2)],],
                                    onToggle: (index) {
                                      print('switched to: $index');

                                      textValue = values[index!.toInt()];
                                      print('Switched to: $textValue');

                                    }
                                  ),

                                ],
                              ),
                            ),

                            buildEmailField(),
                            SizedBox(
                              height: kDefaultPadding,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: kDefaultPadding * 2,
                                  width: kDefaultPadding * 2,
                                ),
                                Text(
                                  'Password',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: labels),
                                ),
                              ],
                            ),
                            buildPasswordField(),
                            sizedBox,
                            MaterialButton(
                              color: btnColor,
                              minWidth: 159,
                              height: 38,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  signIn(_emailController.text,
                                      _passwordController.text, textValue);
                                }
                              },
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: btnColor,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(23),
                                  topRight: Radius.circular(23),
                                  bottomLeft: Radius.circular(23),
                                  bottomRight: Radius.circular(23),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            sizedBox,
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {

                        },
                        child: Text(
                          'Terms & Conditions Apply',
                          style: TextStyle(fontSize: 11, color: labels),
                        ),
                      ),
                    ],
                  ),
                  sizedBox,
                ])),
          ]),
        ));
  }

  Padding buildPasswordField() {
    return Padding(
      padding: EdgeInsets.all(25.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 16.0,
        width: MediaQuery.of(context).size.width / 1.2,
        padding: EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: textField,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextFormField(
          controller: _passwordController,
          obscureText: _passwordVisible,
          textAlign: TextAlign.start,
          keyboardType: TextInputType.visiblePassword,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter the password',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintStyle: TextStyle(color: Colors.grey[400]),
              fillColor: textField,
              filled: true,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility,
              ),
              iconSize: kDefaultPadding,
            ),
          ),
          validator: (value) {
            if (value!.length < 5) {
              return 'Must be more than 5 characters';
            }
          },
        ),
      ),
    );
  }

  Padding buildEmailField() {
    var _errorMessage;
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 16.0,
        width: MediaQuery.of(context).size.width / 1.2,
        padding: EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: textField,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextFormField(
          controller: _emailController,
          textAlign: TextAlign.start,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter the mail',
            errorText: _errorMessage,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintStyle: TextStyle(color: Colors.grey[400]),
            fillColor: textField,
            filled: true
          ),
          validator: (value) {
            //for validation
            RegExp regExp = new RegExp(emailPattern);
            if (value == null || value.isEmpty) {
              return 'please enter the mail';
              //if it doesnot matches the pattern,like
              // it not contains @
            }
            else if (!value.contains('@ideassion.com')) {
              return 'Please Enter Valid Email of @ideassion.com';
            }
            else if (!regExp.hasMatch(value)) {
              return 'Please enter a valid email ';
            }
          },

        )


        ),

    );
  }

  signIn(String email, String password, String modes) async {

  print(modes);
    var jsonResponse;
    String apiEndpoint ='http://ems-ma.ideassionlive.in/api/User/getVerifyUser?empEmailId=$email&password=$password&workMode=$modes';
    final Uri url = Uri.parse(apiEndpoint);
    var response = await http.get(url);
    if (response.statusCode == 200) {

      jsonResponse = json.decode(response.body);
      User user = User.fromJson(jsonResponse);

      setState(() {
        name = jsonResponse["empName"];
        mode = jsonResponse["workMode"];
        empEmail = jsonResponse["empEmailId"];
    });


      if(name==adminName && empEmail==user.empEmailId){
        Navigator.pushNamed(context, AdminHomeScreen.routeName);
      }else {
        Navigator.pushNamed(context, HomeScreen.routeName,
            arguments: {'email': empEmail, 'empName': name, 'mode': mode});
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('logged in Successfully'.toString())));
      if (jsonResponse != null) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
