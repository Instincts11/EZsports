import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

const Color _highlight = Color(0xFFF15B5B);
const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const List<String> _weekdays = <String>['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

Future<void> showCoachDateOverlay(
  BuildContext pageContext, {
  DateTime? rangeStart,
  DateTime? rangeEnd,
}) {
  return showGeneralDialog<void>(
    context: pageContext,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0xB3000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (BuildContext overlayContext, Animation<double> animation, Animation<double> secondary) {
      return SafeArea(
        child: Center(
          child: Material(
            color: AppColors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 10)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 18),
                  child: _DateCalendar(rangeStart: rangeStart, rangeEnd: rangeEnd),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _DateCalendar extends StatefulWidget {
  const _DateCalendar({this.rangeStart, this.rangeEnd});

  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  @override
  State<_DateCalendar> createState() => _DateCalendarState();
}

class _DateCalendarState extends State<_DateCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final DateTime focus = widget.rangeStart ?? DateTime.now();
    _month = DateTime(focus.year, focus.month);
  }

  DateTime? get _rangeStart => widget.rangeStart == null ? null : _day(widget.rangeStart!);

  DateTime? get _rangeEnd => widget.rangeEnd == null ? null : _day(widget.rangeEnd!);

  bool _marked(DateTime day) {
    final DateTime? start = _rangeStart;
    final DateTime? end = _rangeEnd;
    if (start == null || end == null) {
      return false;
    }
    return !day.isBefore(start) && !day.isAfter(end);
  }

  void _shift(int months) {
    setState(() {
      _month = DateTime(_month.year, _month.month + months);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime first = DateTime(_month.year, _month.month);
    final int daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final int leading = first.weekday % 7;
    final int cells = leading + daysInMonth;
    final int rows = (cells / 7).ceil();
    final List<DateTime?> grid = List<DateTime?>.generate(rows * 7, (int index) {
      final int dayNumber = index - leading + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return null;
      }
      return DateTime(_month.year, _month.month, dayNumber);
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => _shift(-1),
              icon: const Icon(Icons.chevron_left, color: Color(0xFF1C1C1C)),
            ),
            Expanded(
              child: Text(
                '${_months[_month.month - 1].toUpperCase()} ${_month.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'This month',
              onPressed: () {
                final DateTime today = _day(DateTime.now());
                setState(() => _month = DateTime(today.year, today.month));
              },
              icon: const Icon(AppIcons.calendar, color: _highlight),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: _weekdays
              .map(
                (String label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: Color(0xFFB0A8A0),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        for (int row = 0; row < rows; row++)
          Row(
            children: <Widget>[
              for (int column = 0; column < 7; column++)
                Expanded(child: _cell(grid, row * 7 + column)),
            ],
          ),
      ],
    );
  }

  Widget _cell(List<DateTime?> grid, int index) {
    final DateTime? day = grid[index];
    if (day == null) {
      return const SizedBox(height: 40);
    }
    final bool marked = _marked(day);
    final bool previous = index % 7 != 0 && grid[index - 1] != null && _marked(grid[index - 1]!);
    final bool next = index % 7 != 6 && grid[index + 1] != null && _marked(grid[index + 1]!);
    final bool alone = marked && !previous && !next;
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (alone)
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: _highlight, shape: BoxShape.circle),
            )
          else if (marked)
            Positioned(
              left: 0,
              right: 0,
              top: 3,
              bottom: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _highlight,
                  borderRadius: BorderRadius.horizontal(
                    left: previous ? Radius.zero : const Radius.circular(18),
                    right: next ? Radius.zero : const Radius.circular(18),
                  ),
                ),
              ),
            ),
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: marked ? FontWeight.w700 : FontWeight.w500,
              color: marked ? Colors.white : const Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
