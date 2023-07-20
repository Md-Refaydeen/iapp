import 'package:flutter/material.dart';

class DialogComponent extends StatelessWidget {
  final String status;
  final String content;
  final String image;
  final String buttonTitle;
  final VoidCallback onPress;

  const DialogComponent(
      {super.key, required this.status,
      required this.content,
      required this.image,
      required this.buttonTitle, required this.onPress});

  @override
  Widget build(BuildContext context) {
    print('called');
    return Dialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2.0,
        width: MediaQuery.of(context).size.width / 1.6,
        child: Column(
          children: [
            Image.asset(image, height: 185, width: 170),
            const SizedBox(
              height:25,
            ),
            Text(
              status,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Color(0xFF003756)),
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 18,color: Color(0xFF003756)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed:onPress,
                  color: const Color(0xEF5278FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minWidth: 159,
                  height: 38,
                  child: Text(
                    buttonTitle,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
