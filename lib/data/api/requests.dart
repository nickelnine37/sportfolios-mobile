import 'package:http/http.dart' as http;
import 'package:sportfolios_alpha/data/api/urls.dart';
import 'dart:convert' as convert;

import 'package:sportfolios_alpha/providers/authenication_provider.dart';

Future<Map<String, double>> getBackPrices(List<String> markets) async {
  Uri url = currentBackPrices(markets);

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, double> jsonResponse = Map<String, double>.from(convert.jsonDecode(response.body)) ;
    return jsonResponse;
  } else {
    print('Request getBackPrices failed with status: ${response.statusCode}.');
    return null;
  }

}

Future<Map<String, Map>> getDailyBackPrices(List<String> markets) async {
  Uri url = dailyBackPrices(markets);

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, Map> jsonResponse = Map<String, Map>.from(convert.jsonDecode(response.body)) ;
    return jsonResponse;
  } else {
    print('Request getDailyBackPrices failed with status: ${response.statusCode}.');
    return null;
  }

}

Future<Map<String, dynamic>> getcurrentHoldings(String market) async {
  Uri url = currentHoldings(market);

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body)) ;
    return jsonResponse;
  } else {
    print('Request getcurrentHoldings failed with status: ${response.statusCode}.');
    return null;
  }

}

Future<Map<String, dynamic>> getHistoricalHoldings(String market) async {
  Uri url = historicalHoldings(market);

  var response = await http.get(url, headers: {'Authorization': await AuthService().getJWTToken()});
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(convert.jsonDecode(response.body)) ;
    return jsonResponse;
  } else {
    print('Request getcurrentHoldings failed with status: ${response.statusCode}.');
    return null;
  }

}
