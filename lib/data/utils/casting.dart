import '../../utils/numerical/arrays.dart';

Map<String, Array> castHistArray(Map<String, dynamic> hist) {
  return Map<String, Array>.fromIterables(
      hist.keys,
      hist.keys.map(
        (String th) {
          return Array.fromDynamicList(hist[th]);
        } ,
      ));
}

Map<String, Matrix> castHistMatrix(Map<String, dynamic> hist) {
  return Map<String, Matrix>.fromIterables(
      hist.keys,
      hist.keys.map(
        (String th) =>
            Matrix.from(List<Array>.generate(hist[th].length, (int i) => Array.fromDynamicList(hist[th][i]))),
      ));
}


Map<String, List<int>> castHistListInt(Map<String, dynamic> hist) {
  return Map<String, List<int>>.fromIterables(
      hist.keys,
      hist.keys.map(
        (String th) => List<int>.from(hist[th]),
      ));
}

