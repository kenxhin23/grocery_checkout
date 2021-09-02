import 'dart:async';

import 'package:flutter/material.dart';

class ColorData {
  static Color themeColor = Colors.deepOrange;
  static Color themeColor2 = Colors.deepOrange[400];
  static Color headerColor = Colors.green[700];
  static Color secondColor = Colors.teal;
  static Color fontLightColor = Colors.white;
  static Color fontDarkColor = Colors.black;
}

class UserData {
  static String id;
  static String name;
  // static String lastname;
  static String position;
  static String username;
  static String newPassword;
  static String buCode;
}

class TranData {
  static String tran;
  static String receipt;
  static String date;
  static String name;
  static String packNo;
  static String mop;
}

class BarcodeData {
  static int receiptLength = 15;
  static int barcodeLength = 16;
}

class GlobalVariables {
  static bool clearText = false;
  static String menuKey;
  static Timer timer;
  static String appVersion = '20';
  static bool phonePressed = true;
  static bool scannerPressed = false;
  static bool noConnection = false;
  static bool pop = false;
}
