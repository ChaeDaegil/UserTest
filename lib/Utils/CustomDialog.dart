import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog{
  Future<bool> showCustomDialog(BuildContext context, String title, String content,bool onlyOk) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              title,
            textAlign: TextAlign.center,
          ),
          content: Text(
              content,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(true); // 확인 버튼을 누르면 true 반환
              },
            ),
            onlyOk ? Text("") : TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(false); // 확인 버튼을 누르면 true 반환
              },
            ),
          ],
        );
      },
    );
  }
}