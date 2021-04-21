
import 'package:flutter/material.dart';

class PieData {
  List<SegmentData> data = [
    SegmentData(name: 'Ars Long Back', percentage: 20, colour: Colors.red[900]),
    SegmentData(name: 'Che Long Back', percentage: 20, colour: Colors.blue[900]),
    SegmentData(name: 'Wat Long Back', percentage: 20, colour: Colors.yellow[500]),
    SegmentData(name: 'Other', percentage: 40, colour: Colors.grey[500]),
  ];
}

class SegmentData {
  final String name;

  final double percentage;

  final Color colour;

  SegmentData({this.name, this.percentage, this.colour});
}