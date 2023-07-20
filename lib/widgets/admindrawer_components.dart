import 'package:flutter/material.dart';
import 'package:iapp/user_screens/login_screen.dart';
import '../constants/constants.dart';
import 'list_components.dart';

class DrawerComponent extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback onPress1,onPress2,onPress3;
  const DrawerComponent({required this.name, required this.image, required this.onPress1,required this.onPress2,required this.onPress3,});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.purple.shade50,
      width: MediaQuery.of(context).size.width * 0.7,
      child: ListView(
        padding: const EdgeInsets.only(top: 65.0),

        children: <Widget>[
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: const Icon(Icons.arrow_back_ios),alignment: Alignment.topRight),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width/11,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 15,
                width: MediaQuery.of(context).size.width / 8,
                child: CircleAvatar(
                  backgroundImage: AssetImage(
                    image,
                  ),
                  radius: 30,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 7,
                width: MediaQuery.of(context).size.width / 20,
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          ListComponents(
            title: 'Home',
            iconData: Icons.home_filled,
            onPress: onPress1,
          ),
          ListComponents(
            title: 'Attendance',
            iconData: Icons.calendar_today_outlined,
            onPress: onPress2,
          ),

          ListComponents(
            title: 'Logout',
            iconData: Icons.power_settings_new,
            onPress: () {

              Navigator.pushNamed(context, LoginScreen.routeName);
              ScaffoldMessenger.of(context)
                       .showSnackBar(SnackBar(content: Text("Logged out Successfully".toString())));

            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height/9.5,),
          Container(
            margin:
                const EdgeInsets.only(top: kDefaultPadding, right: kDefaultPadding),
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 10,
            child: Image.asset(
              'assets/images/Ideassion.png',
            ),
          ),
        ],
      ),
    );
  }
}
