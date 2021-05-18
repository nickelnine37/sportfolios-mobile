import 'dart:math';

double round(double n, int i) {
    num g = pow(10, i);
    return (g * n).roundToDouble() / g; 
  }

