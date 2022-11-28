import 'package:flutter/material.dart';

List<Color> _defaultColors = [
  Color(0xee1f77b4),
  Color(0xeeff7f0e),
  Color(0xee2ca02c),
  Color(0xeed62728),
  Color(0xee9467bd),
  Color(0xee8c564b),
  Color(0xeee377c2),
  Color(0xee7f7f7f),
  Color(0xeebcbd22),
  Color(0xee17becf)
];

Color getColorCycle(int i, int N) {
  return _defaultColors[i % N];
}

Color fromHex(String colour) {
    
    final buffer = StringBuffer();
    if (colour.length == 6 || colour.length == 7) buffer.write('ff');
    buffer.write(colour.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));

}
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex(Color color) => '#'
      '${color.alpha.toRadixString(16).padLeft(2, '0')}'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';
