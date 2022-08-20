import 'package:flutter/material.dart';
import 'package:gogo_pharma/Theme.dart';

Future<void> showImageDialog(BuildContext context, image) {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
              height: MediaQuery.of(context).size.height/1.5,
              width: MediaQuery.of(context).size.width/1,
              child: InteractiveViewer(
                child: Image.network(image, fit: BoxFit.cover,),
                ),
            ),
          );
        },
      );
    },
  );
}


void showToast(String msg, BuildContext context) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: TextStyle(fontSize: 15, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
      padding: EdgeInsets.symmetric(vertical: 10),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(15),
      elevation: 0,
      backgroundColor: Colors.black26,
    ),
  );
}
