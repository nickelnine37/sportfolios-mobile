Uri currentBackPricesURL(List markets) {
  return Uri.https('engine.sportfolios.co.uk', '_current_back_prices', {'markets': markets.join(',')});
}

Uri dailyBackPricesURL(List markets) {
  return Uri.https('engine.sportfolios.co.uk', '_daily_back_prices', {'markets': markets.join(',')});
}

Uri currentHoldingsURL(String market) {
  return Uri.https('engine.sportfolios.co.uk', 'current_holdings', {'market': market});
}

Uri currentMultipleHoldingsURL(List markets) {
  return Uri.https('engine.sportfolios.co.uk', 'current_holdings', {'markets': markets.join(',')});
}

Uri historicalHoldingsURL(String market) {
  return Uri.https('engine.sportfolios.co.uk', 'historical_holdings', {'market': market});
}

Uri historicalMultipleHoldingsURL(List markets) {
  return Uri.https('engine.sportfolios.co.uk', 'historical_holdings', {'markets': markets.join(',')});
}

Uri attemptPurchaseURL() {
  return Uri.https('engine.sportfolios.co.uk', 'purchase');
}

Uri respondToPriceURL() {
  return Uri.https('engine.sportfolios.co.uk', 'confirm_order');
}
