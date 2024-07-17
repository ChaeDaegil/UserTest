import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Contreoller/AdminController.dart';

class Adminpage extends StatefulWidget {
  @override
  AdminpageState createState() => AdminpageState();
}

class AdminpageState extends State<Adminpage> {
  late double countryWidth;
  late double nameWidth;
  late double emailWidth;
  late double emailAgreeWidth;
  late double actionWidth;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Admincontroller>(context, listen: false).loadUsers();
    });
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  double getWidth(double percent) {
    Size size = MediaQuery.of(context).size;
    return size.width * (percent / 100);
  }

  double getHeight(double percent) {
    Size size = MediaQuery.of(context).size;
    return size.height * (percent / 100);
  }

  Future<bool> _onWillPop() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Admincontroller>(context, listen: false).resetRow();
      Provider.of<Admincontroller>(context, listen: false).addRow();
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    countryWidth = getWidth(15);
    nameWidth = getWidth(25);
    emailWidth = getWidth(35);
    emailAgreeWidth = getWidth(13);
    actionWidth = getWidth(10);

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 40,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Letter of Intent for Participation",
                        style: TextStyle(fontSize: getWidth(4), fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: getWidth(1)),
                      child: Text(
                        "[2026 Daegu World Maters Athletics Championships]",
                        style: TextStyle(fontSize: getWidth(3.0)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          bottom: getWidth(1),
                          right: getWidth(1)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () => {

                              },
                              child: Text(""),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UserDataTable(
                        countryWidth: countryWidth,
                        nameWidth: nameWidth,
                        emailWidth: emailWidth,
                        emailAgreeWidth: emailAgreeWidth,
                        actionWidth: actionWidth
                    ),
                  ],
                )
            )
        )
    );
  }
}
