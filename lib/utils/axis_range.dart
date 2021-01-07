import 'dart:math';

List<double> getAxisTicks(double ymin, double ymax) {
  
   var scale = NiceScale(ymin, ymax, 5);
   double nmin = scale.niceMin;
   double nmax = scale.niceMax;
   int N = (nmax - nmin + 1e-8) ~/ scale.tickSpacing;
   return List.generate(N + 1, (i) => nmin + i * scale.tickSpacing);
  
}


class NiceScale {

  /// Class for getting optimal 'nice' axis ticks 
  
  double _niceMin, _niceMax;
  double _tickSpacing;

  double get tickSpacing { return _tickSpacing; }
  double get niceMin{ return _niceMin; }
  double get niceMax{ return _niceMax; }

  double _minPoint, _maxPoint;
  double _maxTicks;
  double _range;

  NiceScale(double minP, double maxP, double maxTicks){
    this._minPoint = minP;
    this._maxPoint = maxP;
    this._maxTicks = maxTicks;
    _calculate();
  }

  void _calculate(){
    _range = _niceNum(_maxPoint - _minPoint, false);
    _tickSpacing = _niceNum(_range / (_maxTicks - 1), true);
    _niceMin = _calcMin();
    _niceMax = _calcMax();
  }

  double _calcMin() {
    int floored = (_minPoint / _tickSpacing).floor();
    return floored * _tickSpacing;
  }

  double _calcMax() {
    int ceiled = (_maxPoint / _tickSpacing).ceil();
    return ceiled * _tickSpacing;
  }

  double _niceNum(double range, bool round){
    double exponent; /** exponent of range */
    double fraction; /** fractional part of range */
    double niceFraction; /** nice, rounded fraction */

    exponent = (log(range)/ln10).floor().toDouble();
    fraction = range / pow(10, exponent);

    if (round)
    {
      if (fraction < 1.5)
        niceFraction = 1;
      else if (fraction < 3)
        niceFraction = 2;
      else if (fraction < 7)
        niceFraction = 5;
      else
        niceFraction = 10;
    }
    else
    {
      if (fraction <= 1)
        niceFraction = 1;
      else if (fraction <= 2)
        niceFraction = 2;
      else if (fraction <= 5)
        niceFraction = 5;
      else
        niceFraction = 10;
    }

    return niceFraction * pow(10, exponent);
  }
}


List<double> randomGraph(int N) {

  List<double> out = [10.0];
  Random rng = Random();

  for (int i=0; i < N; i++) {

    out.add(out[i] * (1 + (0.001 + (rng.nextDouble() - 0.5) * 0.05)));

  }

  return out;

}
