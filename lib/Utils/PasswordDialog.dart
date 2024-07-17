import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordDialog{
  String pass = "";
  String requiredPassword = "123!@#";
  Future<bool> showCustomDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text(
            "Please enter a password",
            textAlign: TextAlign.center,
          ),
          content: TextFormField(
            maxLength: 20,
            decoration:const InputDecoration(
              counterText: '',
            ),
            onFieldSubmitted: (_) {
            },
            onChanged: (newValue) {
              pass = newValue;
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                if(requiredPassword == pass){
                  return Navigator.of(context).pop(true);
                }
                else{
                  return Navigator.of(context).pop(false);
                }
              },
            ),
            TextButton(
              child: Text('Camcel'),
              onPressed: () {
                Navigator.of(context).pop(false); // 취소 버튼을 누르면 false 반환
              },
            ),

          ],
        );
      },
    );
  }
}