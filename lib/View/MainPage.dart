import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:userapp/Contreoller/UserController.dart';




class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
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
      Provider.of<UserController>(context, listen: false).addRow();
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

  @override
  Widget build(BuildContext context) {
    countryWidth = getWidth(15);
    nameWidth = getWidth(24);
    emailWidth = getWidth(34);
    emailAgreeWidth = getWidth(13);
    actionWidth = getWidth(12);

    return Scaffold(
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
                          onPressed: () => Provider.of<UserController>(context, listen: false).showDialog(context),
                          child: Text("admin"),
                        ),
                      ),

                    ],
                  ),
                ),
                UserDataTable(
                    countryWidth: countryWidth,
                    nameWidth: nameWidth,
                    emailWidth:emailWidth,
                    emailAgreeWidth:emailAgreeWidth,
                    actionWidth:actionWidth
                ),
              ],
            )
        )
    );
  }
}
