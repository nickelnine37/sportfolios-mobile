Uri currentBackPricesURL(List markets) {
  return Uri.https('engine.sportfolios.co.uk', 'current_back_prices', {'markets': markets.join(',')});
}

Uri dailyBackPricesURL(List markets) {
  return Uri.https('engine.sportfolios.co.uk', 'daily_back_prices', {'markets': markets.join(',')});
}

Uri currentXURL(String market) {
  return Uri.https('engine.sportfolios.co.uk', 'current_holdings', {'market': market});
}

Uri historicalXURL(String market) {
  return Uri.https('engine.sportfolios.co.uk', 'historical_holdings', {'market': market});
}

Uri attemptPurchaseURL() {
  return Uri.https('engine.sportfolios.co.uk', 'purchase');
}

Uri respondToPriceURL() {
  return Uri.https('engine.sportfolios.co.uk', 'confirm_order');
}
