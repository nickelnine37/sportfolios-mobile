import 'package:http/http.dart' as http;
import 'package:sportfolios_alpha/data/lmsr/lmsr.dart';
import 'package:sportfolios_alpha/data/utils/casting.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';
import 'urls.dart';
import 'dart:convert' as convert;

import '../../providers/authenication_provider.dart';

String __version__ = '0.0';

Future<Map<String, double>?> getBackPrices(List<String?> markets) async {
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

Future<Map<String, List>?> getDailyBackPrices(List<String?> markets) async {
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

Future<Map<String, dynamic>?> getCurrentHoldingsFromServer(String market) async {
  Uri url = currentHoldingsURL(market);

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));

    if (market.contains('T')) {
      return {'x': Array.fromDynamicList(jsonResponse['x']), 'b': jsonResponse['b'] + 0.0};
    } else {
      return {'N': jsonResponse['N'] + 0.0, 'b': jsonResponse['b'] + 0.0};
    }
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, dynamic>?> getHistoricalHoldingsFromServer(String market) async {
  Uri url = historicalHoldingsURL(market);

  var response = await http.get(
    url,
    headers: {
      'Authorization': await AuthService().getJWTToken(),
      'Version': __version__,
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));
    if (market.contains('T')) {
      return {
        'data': {
          'x': castHistMatrix(jsonResponse['data']['x']),
          'b': castHistArray(jsonResponse['data']['b']),
        },
        'time': castHistListInt(jsonResponse['time'])
      };
    } else {
      return {
        'data': {
          'N': castHistArray(jsonResponse['data']['N']),
          'b': castHistArray(jsonResponse['data']['b']),
        },
        'time': castHistListInt(jsonResponse['time'])
      };
    }
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, Map<String, dynamic>>?> getMultipleCurrentHoldings(List<String> markets) async {
  Uri url = currentMultipleHoldingsURL(markets);

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
      jsonResponse.keys.map((String market) {
        if (market.contains('T')) {
          return <String, dynamic>{
            'x': Array.fromDynamicList(jsonResponse[market]!['x']),
            'b': jsonResponse[market]!['b'] + 0.0,
          };
        } else {
          return <String, dynamic>{
            'N': jsonResponse[market]!['N'] + 0.0,
            'b': jsonResponse[market]!['b'] + 0.0,
          };
        }
      }),
    );
  }
  print('Request getcurrentX failed with status: ${response.statusCode}.');
  return null;
}

Future<Map<String, Map<String, dynamic>>?> getMultipleHistoricalHoldings(List<String?> markets) async {
  Uri url = historicalMultipleHoldingsURL(markets);

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
    // print(jsonResponse['data']);
    return {
      'data': Map<String, Map<String, dynamic>>.fromIterables(
        jsonResponse['data']!.keys,
        jsonResponse['data']!.keys.map((String market) {
          if (market.contains('T')) {
            return {
              'x': castHistMatrix(jsonResponse['data']![market]['x']),
              'b': castHistArray(jsonResponse['data']![market]['b'])
            };
          } else {
            return {
              'N': castHistArray(jsonResponse['data']![market]['N']),
              'b': castHistArray(jsonResponse['data']![market]['b'])
            };
          }
        }),
      ),
      'time': castHistListInt(jsonResponse['time']!)
    };
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, dynamic>?> makePurchaseRequest(
  String market,
  String portfolio,
  Asset asset,
  double price,
) async {
  print({'market': market, 'portfolioId': portfolio, 'quantity': asset.toString(), 'price': price.toString()});

  Uri url = attemptPurchaseURL();
  var response = await http.post(url, headers: {
    'Authorization': await AuthService().getJWTToken(),
    'Version': __version__,
  }, body: {
    'market': market.contains('P') ? (market + (asset.long! ? 'L' : 'S')) : market ,
    'portfolioId': portfolio,
    'quantity': (market.contains('P') ? asset.k : asset.q!.scale(asset.k == null ? 1 : asset.k!).toList()).toString(),
    'price': price.toString()
  });

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));
    return jsonResponse;
  } else {
    print('Request makePurchaseRequest failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<bool> respondToNewPrice(
  bool accept,
  String? cancelId,
) async {
  Uri url = respondToPriceURL();
  var response = await http.post(url, headers: {
    'Authorization': await AuthService().getJWTToken(),
    'Version': __version__,
  }, body: {
    'confirm': accept.toString(),
    'cancelId': cancelId
  });

  if (response.statusCode == 200) {
    return true;
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return false;
  }
}
