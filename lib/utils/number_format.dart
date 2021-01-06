import 'package:intl/intl.dart';

List<String> _supportedCurrencies = ['GBP', 'EUR', 'USD'];

String _checkCurrency(currency) {

  if (currency == null) {
    print('Warning: null currency passed. Defaulting to GBP');
    currency = 'GBP';
  }

  if (!_supportedCurrencies.contains(currency)) {
    print('Warning: $currency not supported currency. Defaulting to GBP');
    currency = 'GBP';
  }

  return currency;
}

String formatCurrency(double amount, String currency) {

  NumberFormat currencyFormatter;
  double priceConversionRatio;

  currency = _checkCurrency(currency);

  switch (currency) {
    case 'USD':
      {
        currencyFormatter =
            NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 2);
        priceConversionRatio = 1.35;
      }
      break;
    case 'GBP':
      {
        currencyFormatter =
            NumberFormat.simpleCurrency(locale: 'en_GB', decimalDigits: 2);
        priceConversionRatio = 1.0;
      }
      break;
    case 'EUR':
      {
        currencyFormatter =
            NumberFormat.simpleCurrency(locale: 'eu', decimalDigits: 2);
        priceConversionRatio = 1.11;
      }
      break;
  }

  return currencyFormatter.format(priceConversionRatio * amount);
}

String formatPercentage(double percent, String currency) {
  
  NumberFormat percentFormatter;

  currency = _checkCurrency(currency);

  switch (currency) {
    case 'USD':
      {
        percentFormatter = NumberFormat.decimalPercentPattern(
            locale: 'en_US', decimalDigits: 1);
      }
      break;
    case 'GBP':
      {
        percentFormatter = NumberFormat.decimalPercentPattern(
            locale: 'en_GB', decimalDigits: 1);
      }
      break;
    case 'EUR':
      {
        percentFormatter =
            NumberFormat.decimalPercentPattern(locale: 'eu', decimalDigits: 1);
      }
      break;
  }

  return percentFormatter.format(percent);
}
