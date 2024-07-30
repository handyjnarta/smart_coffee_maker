import 'package:flutter/material.dart';

class AppColors {
  static const Color inActiveButton = Colors.grey;
  static const Color activeButton = Colors.blueAccent;
}

Map<String, Color> colors = {
  'onBorderColor': Colors.green,
  'offBorderColor': Colors.blue,
  'neutralBorderColor': Colors.transparent,
  'onTextColor': Colors.green,
  'offTextColor': Colors.red,
  'neutralTextColor': Colors.blue,
};

const double maxLogContainerWidth = 300;
const int maxCommandCount = 50;
const int minCommandCount = 1;
const int maxConnectionTimeOut = 15; // in second
const int maxTryReconnect = 5;
const int maxCommandHistoryCount = 100;