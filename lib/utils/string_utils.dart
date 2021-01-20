String formatTitle(String input) {
  return input.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}

String formatOrdinal(int i) {
  List<String> numbers = i.toString().split('');
  String last = numbers.last;

  if (numbers.length > 1) {
    if (numbers[numbers.length - 2] == '1') 
      return 'th';
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
