import 'package:http/http.dart' as http;
import 'urls.dart';
import 'dart:convert' as convert;

import '../../providers/authenication_provider.dart';

String __version__ = '0.0';

Future<Map<String, double>> getBackPrices(List<String> markets) async {
  Uri url = currentBackPricesURL(markets);

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, double> jsonResponse = Map<String, double>.from(convert.jsonDecode(response.body));
    return jsonResponse;
  } else {
    print('Request getBackPrices failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, List>> getDailyBackPrices(List<String> markets) async {
  Uri url = dailyBackPricesURL(markets);

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, List> jsonResponse = Map<String, List>.from(convert.jsonDecode(response.body));
    return jsonResponse;
  } else {
    print('Request getDailyBackPrices failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, dynamic>> getcurrentX(String market) async {
  Uri url = currentXURL(market);

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));
    return {'x': List<double>.from(jsonResponse['x']), 'b': jsonResponse['b']+ 0.0};
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Map<String, List<List<double>>> castHistArray(Map<String, dynamic> hist) {
  return Map<String, List<List<double>>>.fromIterables(
      hist.keys,
      hist.keys.map(
        (String th) =>
            List<List<double>>.generate(hist[th].length, (int i) => List<double>.from(hist[th][i])),
      ));
}

Map<String, List<double>> castHistDouble(Map<String, dynamic> hist) {
  return Map<String, List<double>>.fromIterables(
      hist.keys,
      hist.keys.map(
        (String th) {

          return List<double>.from(hist[th]);

        } ,
      ));
}

Map<String, List<int>> castHistInt(Map<String, dynamic> hist) {
  return Map<String, List<int>>.fromIterables(
      hist.keys,
      hist.keys.map(
        (String th) => List<int>.from(hist[th]),
      ));
}

Future<Map<String, dynamic>> getHistoricalX(String market) async {
  Uri url = historicalXURL(market);

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));
    return {
      'data': {
        'x': castHistArray(jsonResponse['data']['x']),
        'b': castHistDouble(jsonResponse['data']['b']),
      },
      'time': castHistInt(jsonResponse['time'])
    };
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, Map>> getMultipleCurrentX(List<String> markets) async {
  Uri url = currentMultipleXURL(markets);

  if (markets.length == 0) {
    print('getMultipleCurrentX: No markets passed!');
    return null;
  }

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, Map> jsonResponse = Map<String, Map>.from(convert.jsonDecode(response.body));
    return Map<String, Map<String, dynamic>>.fromIterables(
      jsonResponse.keys,
      jsonResponse.keys.map((String market) => <String, dynamic>{
            'x': List<double>.from(jsonResponse[market]['x']),
            'b': jsonResponse[market]['b'] + 0.0,
          }),
    );
  }
  print('Request getcurrentX failed with status: ${response.statusCode}.');
  return null;
}

Future<Map<String, Map>> getMultipleHistoricalX(List<String> markets) async {
  Uri url = historicalMultipleXURL(markets);

  if (markets.length == 0) {
    print('getMultipleHistoricalX: No markets passed!');
    return null;
  }

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, Map<String, dynamic>> jsonResponse = Map<String, Map<String, dynamic>>.from(convert.jsonDecode(response.body));
    return {
      'data': Map<String, Map<String, dynamic>>.fromIterables(
        jsonResponse['data'].keys,
        jsonResponse['data'].keys.map(
              (String market) => {
                'x': castHistArray(jsonResponse['data'][market]['x']),
                'b': castHistDouble(jsonResponse['data'][market]['b']),
              },
            ),
      ),
      'time': castHistInt(jsonResponse['time'])
    };
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, dynamic>> makePurchaseRequest(
  String market,
  String portfolio,
  List<double> q,
  double price,
) async {
  print({'market': market, 'portfolioId': portfolio, 'quantity': q.toString(), 'price': price.toString()});

  Uri url = attemptPurchaseURL();
  var response = await http.post(url, headers: {
    'Authorization': await AuthService().getJWTToken(),
    'Version': __version__,
  }, body: {
    'market': market,
    'portfolioId': portfolio,
    'quantity': q.toString(),
    'price': price.toString()
  });

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));
    return jsonResponse;
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<bool> respondToNewPrice(
  bool accept,
  String cancelId,
  String market,
  String portfolio,
  List<double> q,
  double price,
) async {
  Uri url = respondToPriceURL();
  var response = await http.post(url, headers: {
    'Authorization': await AuthService().getJWTToken(),
    'Version': __version__,
  }, body: {
    'confirm': accept.toString(),
    'cancelId': cancelId,
    'market': market,
    'portfolioId': portfolio,
    'quantity': q.toString(),
    'price': price.toString()
  });

  if (response.statusCode == 200) {
    return true;
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return false;
  }
}
