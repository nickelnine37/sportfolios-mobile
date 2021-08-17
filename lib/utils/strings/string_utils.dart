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
  if (name.length > maxLen) {
    List names = name.split(" ");
    if (names.length > 2) {
      if (type == 'player') {
        name = names.first + ' ' + names.last;
      } else {
        name = names.first + ' ' + names[1];
      }
    } else {
      if (type == 'player') {
        name = names.last;
      } else {
        name = names.first;
      }
    }
  }

  return name;
}