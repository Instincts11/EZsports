const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

DateTime? parseApiDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String formatApiDate(String? value) {
  final DateTime? date = parseApiDate(value);
  if (date == null) {
    return value ?? '';
  }
  final String weekday = _weekdays[date.weekday - 1];
  return '${weekday.substring(0, 3)} ${date.day} ${_months[date.month - 1]}';
}

String formatApiTime(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  final List<String> parts = value.split(':');
  if (parts.length < 2) {
    return value;
  }
  final int? hourRaw = int.tryParse(parts[0]);
  final int? minute = int.tryParse(parts[1]);
  if (hourRaw == null || minute == null) {
    return value;
  }
  final String suffix = hourRaw >= 12 ? 'PM' : 'AM';
  int hour = hourRaw % 12;
  if (hour == 0) {
    hour = 12;
  }
  return '$hour:${minute.toString().padLeft(2, '0')} $suffix';
}

String ordinalDay(int day) {
  if (day >= 11 && day <= 13) {
    return '${day}th';
  }
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

String sessionStatusFor(DateTime date, String start, String end) {
  final DateTime now = DateTime.now();
  final DateTime day = DateTime(date.year, date.month, date.day);
  final DateTime today = DateTime(now.year, now.month, now.day);
  if (day.isBefore(today)) {
    return 'previous';
  }
  if (day.isAfter(today)) {
    return 'upcoming';
  }
  final int nowMinutes = now.hour * 60 + now.minute;
  final int startMinutes = _minutes(start);
  final int endMinutes = _minutes(end);
  if (nowMinutes < startMinutes) {
    return 'upcoming';
  }
  if (nowMinutes > endMinutes) {
    return 'previous';
  }
  return 'ongoing';
}

int _minutes(String value) {
  final List<String> parts = value.split(':');
  final int hour = int.tryParse(parts.first) ?? 0;
  final int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return hour * 60 + minute;
}
