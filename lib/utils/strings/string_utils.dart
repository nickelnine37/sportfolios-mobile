import 'package:intl/intl.dart' as intl;

Map<String, String> teamNamesShort = {
  'Manchester United': 'Man United',
  'Manchester City': 'Man City',
  'Tottenham Hotspur': 'Tottenham',
  'Leicester City': 'Leicester',
  'Wolverhampton Wanderers': 'Wolves',
  'Newcastle United': 'Newcastle',
  'West Ham United': 'West Ham',
  'Crystal Palace': 'Palace',
  'Brighton & Hove Albion': 'Brighton',
  'Aston Villa': 'Villa',
  'Norwich City': 'Norwich',
  'Leeds United': 'Leeds',
  'West Bromwich Albion': 'West Brom',
  'Luton Town': 'Luton',
  'Coventry City': 'Coventry',
  'Bristol City': 'Bristol',
  'Birmingham City': 'Birmingham',
  'Sheffield United': 'Sheffield Utd',
  'Hull City': 'Hull',
  'Derby County': 'Derby',
  'Huddersfield Town': 'Huddersfield',
  'Peterborough United': 'Peterborough',
  'Stoke City': 'Stoke',
  'Blackburn Rovers': 'Blackburn',
  'Swansea City': 'Swansea',
  'Queens Park Rangers': 'QPR',
  'AFC Bournemouth': 'Bournemouth',
  'Nottingham Forest': 'Nottingham',
  'Cardiff City': 'Cardiff',
  'Preston North End': 'Preston',
  'Athletic Club': 'Athletic',
  'Deportivo Alavés': 'Deportivo',
  'Celta de Vigo': 'Celta',
  'Rayo Vallecano': 'Vallecano',
  'FC Barcelona': 'Barcelona',
  '1. FC Union Berlin': 'Berlin',
  'TSG Hoffenheim': 'Hoffenheim',
  'RB Leipzig': 'Leipzig',
  'DSC Arminia Bielefeld': 'Arminia',
  'Hertha BSC': 'Hertha',
  'VfB Stuttgart': 'Stuttgart',
  '1. FC Köln': 'Köln',
  'Bayer 04 Leverkusen': 'Leverkusen',
  'SpVgg Greuther Fürth': 'Fürth',
  'SC Freiburg': 'Freiburg',
  'Eintracht Frankfurt': 'Frankfurt',
  'FC Bayern München': 'Bayern Münich',
  'VfL Wolfsburg': 'Wolfsburg',
  'Borussia Mönchengladbach': 'Mönchengladbach',
  'Borussia Dortmund': 'Dortmund',
  '1. FSV Mainz 05': 'Mainz',
  'FC Augsburg': 'Augsburg',
  'VfL Bochum 1848': 'Bochum',
  'Olympique Marseille': 'Marseille',
  'Paris Saint Germain': 'PSG',
  'Angers SCO': 'Angers',
  'Olympique Lyonnais': 'Lyon',
  'Hellas Verona': 'Verona',
  'Dundee United': 'Dundee Utd',
};

String formatTitle(String input) {
  return input.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}

String formatOrdinal(int i) {
  List<String> numbers = i.toString().split('');
  String last = numbers.last;

  if (numbers.length > 1) {
    if (numbers[numbers.length - 2] == '1') return 'th';
  }
  if (last == '1')
    return 'st';
  else if (last == '2')
    return 'nd';
  else if (last == '3')
    return 'rd';
  else
    return 'th';
}

List<String> getSearchTerms(String name) {
  List<String> out = [];

  for (String _name in name.split(' ')) {
    for (int i = 0; i < _name.length - 1; i++) {
      out.add(_name.substring(0, i + 1).toLowerCase());
    }
  }

  return out.toSet().toList();
}

List<String> getAllSearchTerms(List<String> allNames) {
  List<String> out = [];

  for (String name in allNames) {
    out.addAll(getSearchTerms(name));
  }

  return out.toSet().toList();
}

String splitLongName(String name, int maxLen, String type) {
  if (type == 'team') {
    if (teamNamesShort.containsKey(name)) {
      return teamNamesShort[name]!;
    } else {
      return name;
    }
  }

  if (name.length > maxLen) {
    List names = name.split(" ");
    if (names.length > 2) {
      name = names.first + ' ' + names.last;
    } else {
      name = names.last;
    }
  }

  return name;
}

String unixToDateString(int t) {
  return intl.DateFormat('d MMM yy HH:mm').format(DateTime.fromMillisecondsSinceEpoch((1000 * t).floor()));
}
