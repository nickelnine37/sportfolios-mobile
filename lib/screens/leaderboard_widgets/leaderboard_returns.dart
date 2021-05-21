import 'dart:math';

class LeaderboardReturnsData {

  List<ReturnsData> data = [
    ReturnsData(
      name: '1h',
      time: List<double>.generate(60, (i) => (i + 1).toDouble()),
      values: List.generate(60, (_) => 25.0 + 50 * Random().nextDouble()),
    ),
    ReturnsData(
      name: '1d',
      time: List<double>.generate(48, (i) => (i + 1).toDouble()),
      values: List.generate(48, (_) => 25.0 + 50 * Random().nextDouble()),
    ),
    ReturnsData(
      name: '1w',
      time: List<double>.generate(56, (i) => (i + 1).toDouble()),
      values: List.generate(56, (_) => 25.0 + 50 * Random().nextDouble()),
    ),
    ReturnsData(
      name: '1m',
      time: List<double>.generate(60, (i) => (i + 1).toDouble()),
      values: List.generate(60, (_) => 25.0 + 50 * Random().nextDouble()),
    ),
    ReturnsData(
      name: 'Max',
      time: List<double>.generate(60, (i) => (i + 1).toDouble()),
      values: List.generate(60, (_) => 25.0 + 50 * Random().nextDouble()),
    ),

  ];
}

class ReturnsData {
  final String name;

  final List<double> time;

  final List<double> values;

  ReturnsData({this.name, this.time, this.values});

}
