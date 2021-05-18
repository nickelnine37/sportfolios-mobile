

Uri currentBackPrices (List markets) {
  return Uri.https('engine.sportfolios.co.uk', 'current_back_prices', {'markets': markets.join(',')});
}

Uri dailyBackPrices (List markets) {
  return Uri.https('engine.sportfolios.co.uk', 'daily_back_prices', {'markets': markets.join(',')});
}

Uri currentHoldings (String market) {
  return Uri.https('engine.sportfolios.co.uk', 'current_holdings', {'market': market});
}

Uri historicalHoldings (String market) {
  return Uri.https('engine.sportfolios.co.uk', 'historical_holdings', {'market': market});
}




