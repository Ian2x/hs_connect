import 'package:timeago/src/messages/lookupmessages.dart';

/// English messages
class EnMessages implements LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => 'ago';

  @override
  String suffixFromNow() => 'from now';

  @override
  String lessThanOneMinute(int seconds) => 'Now';

  @override
  String aboutAMinute(int minutes) => '1m';

  @override
  String minutes(int minutes) => '$minutes' + 'm';

  @override
  String aboutAnHour(int minutes) => '1h';

  @override
  String hours(int hours) => '$hours' + 'h';

  @override
  String aDay(int hours) => '1d';

  @override
  String days(int days) => '$days'+'d';

  @override
  String aboutAMonth(int days) => '1mo';

  @override
  String months(int months) => '$months' + 'mo';

  @override
  String aboutAYear(int year) => '1y';

  @override
  String years(int years) => '$years' + 'y';

  @override
  String wordSeparator() => ' ';
}

/// English short messages
class EnShortMessages implements LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => '';

  @override
  String suffixFromNow() => '';

  @override
  String lessThanOneMinute(int seconds) => 'Now';

  @override
  String aboutAMinute(int minutes) => '1m';

  @override
  String minutes(int minutes) => '${minutes}m';

  @override
  String aboutAnHour(int minutes) => '~1h';

  @override
  String hours(int hours) => '${hours}h';

  @override
  String aDay(int hours) => '~1d';

  @override
  String days(int days) => '${days}d';

  @override
  String aboutAMonth(int days) => '~1mo';

  @override
  String months(int months) => '${months}mo';

  @override
  String aboutAYear(int year) => '~1y';

  @override
  String years(int years) => '${years}y';

  @override
  String wordSeparator() => ' ';
}
