import 'package:flutter/material.dart';
class ListComponents extends StatelessWidget {
  const ListComponents({Key? key, required this.onPress, required this.title, required this.iconData}) : super(key: key);
  final VoidCallback onPress;
  final String title;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,style: TextStyle(fontSize: 17,color: Color(0XFF3F3D56)),),
      onTap: onPress,
      contentPadding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 20.0),
      leading: Icon(iconData,size: 27,color: Color(0XFF3F3D56),),
    );
  }
}
