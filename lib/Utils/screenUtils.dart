import 'package:flutter/cupertino.dart';

class screenUtils{
  double getWidth(double persent,BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.width * (persent / 100);
  }

  double getHeight(double persent,BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return size.height * (persent / 100);
  }
}