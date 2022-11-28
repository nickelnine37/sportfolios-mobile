import 'package:intl/intl.dart';


String timeAgoSinceDate(double unixTime) {
  DateTime notificationDate = DateTime.fromMillisecondsSinceEpoch((unixTime * 1000).floor());

  final date2 = DateTime.now();
  final difference = date2.difference(notificationDate);

  if (difference.inDays > 8) {
    return DateFormat('d MMM yy').format(notificationDate);
  } else if ((difference.inDays / 7).floor() >= 1) {
    return '1 week ago';
  } else if (difference.inDays >= 2) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays >= 1) {
    return '1 day ago';
  } else if (difference.inHours >= 2) {
    return '${difference.inHours} hours ago';
  } else if (difference.inHours >= 1) {
    return '1 hour ago';
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inMinutes >= 1) {
    return '1 minute ago';
  } else if (difference.inSeconds >= 3) {
    return '${difference.inSeconds} seconds ago';
  } else {
    return 'Just now';
  }
}