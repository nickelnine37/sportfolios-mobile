import 'package:http/http.dart' as http;
import 'package:sportfolios_alpha/data/api/urls.dart';
import 'dart:convert' as convert;

import 'package:sportfolios_alpha/providers/authenication_provider.dart';

Future<Map<String, double>> getBackPrices(List<String> markets) async {
  Uri url = currentBackPricesURL(markets);

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
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

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
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

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));
    return jsonResponse;
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, dynamic>> getHistoricalX(String market) async {
  Uri url = historicalXURL(market);

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body));
    return jsonResponse;
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

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, Map> jsonResponse = Map<String, Map>.from(convert.jsonDecode(response.body));
    return jsonResponse;
  } else {
    print('Request getcurrentX failed with status: ${response.statusCode}.');
    return null;
  }
}

Future<Map<String, Map>> getMultipleHistoricalX(List<String> markets) async {
  Uri url = historicalMultipleXURL(markets);

  if (markets.length == 0) {
    print('getMultipleHistoricalX: No markets passed!');
    return null;
  }

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, Map> jsonResponse = Map<String, Map>.from(convert.jsonDecode(response.body));
    return jsonResponse;
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

  print({
    'market': market,
    'portfolioId': portfolio,
    'quantity': q.toString(),
    'price': price.toString()
  });

  Uri url = attemptPurchaseURL();
  var response = await http.post(url, headers: {
    'Authorization': await AuthService().getJWTToken()
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
    'Authorization': await AuthService().getJWTToken()
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
