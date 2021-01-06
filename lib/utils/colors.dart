import 'package:flutter/material.dart';

List<Color> _defaultColors = [
  Color(0xff1f77b4),
  Color(0xffff7f0e),
  Color(0xff2ca02c),
  Color(0xffd62728),
  Color(0xff9467bd),
  Color(0xff8c564b),
  Color(0xffe377c2),
  Color(0xff7f7f7f),
  Color(0xffbcbd22),
  Color(0xff17becf)
];

Color getColorCycle(int i, int N) {
  return _defaultColors[i % N];
}
