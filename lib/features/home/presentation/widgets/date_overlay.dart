import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

const Color _highlight = Color(0xFFF15B5B);
const Color _ink = Color(0xFF1C1C1C);
const int _firstYear = 1990;
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

Future<DateTimeRange?> showCoachDateOverlay(
  BuildContext pageContext, {
  DateTime? rangeStart,
  DateTime? rangeEnd,
}) {
  return showGeneralDialog<DateTimeRange>(
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: _DateCalendar(
                      rangeStart: rangeStart,
                      rangeEnd: rangeEnd,
                      onCancel: () => Navigator.of(overlayContext).pop(),
                      onSubmit: (DateTimeRange range) => Navigator.of(overlayContext).pop(range),
                    ),
                  ),
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
  const _DateCalendar({
    required this.onCancel,
    required this.onSubmit,
    this.rangeStart,
    this.rangeEnd,
  });

  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final VoidCallback onCancel;
  final ValueChanged<DateTimeRange> onSubmit;

  @override
  State<_DateCalendar> createState() => _DateCalendarState();
}

class _DateCalendarState extends State<_DateCalendar> {
  late DateTime _month;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.rangeStart == null ? null : _day(widget.rangeStart!);
    _end = widget.rangeEnd == null ? null : _day(widget.rangeEnd!);
    final DateTime now = DateTime.now();
    final DateTime focus = _start ?? now;
    _month = DateTime(focus.year.clamp(_firstYear, now.year), focus.month);
  }

  void _pick(DateTime day) {
    setState(() {
      final DateTime? start = _start;
      if (start == null || _end != null) {
        _start = day;
        _end = null;
      } else if (day.isBefore(start)) {
        _start = day;
        _end = start;
      } else {
        _end = day;
      }
    });
  }

  bool _marked(DateTime day) {
    final DateTime? start = _start;
    if (start == null) {
      return false;
    }
    final DateTime end = _end ?? start;
    return !day.isBefore(start) && !day.isAfter(end);
  }

  void _shift(int months) {
    setState(() => _month = DateTime(_month.year, _month.month + months));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime first = DateTime(_month.year, _month.month);
    final int daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final int leading = first.weekday % 7;
    final int rows = ((leading + daysInMonth) / 7).ceil();
    final List<DateTime?> grid = List<DateTime?>.generate(rows * 7, (int index) {
      final int dayNumber = index - leading + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return null;
      }
      return DateTime(_month.year, _month.month, dayNumber);
    });
    final int thisYear = DateTime.now().year;
    final List<int> years = List<int>.generate(thisYear - _firstYear + 1, (int index) => _firstYear + index);
    final bool atFirst = _month.year == _firstYear && _month.month == 1;
    final bool atLast = _month.year == thisYear && _month.month == 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Previous month',
              onPressed: atFirst ? null : () => _shift(-1),
              icon: const Icon(Icons.chevron_left, color: _ink),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      _months[_month.month - 1].toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: _ink),
                    ),
                  ),
                  const SizedBox(width: 6),
                  PopupMenuButton<int>(
                    tooltip: 'Change year',
                    initialValue: _month.year,
                    color: Colors.white,
                    constraints: const BoxConstraints(maxHeight: 280),
                    onSelected: (int year) => setState(() => _month = DateTime(year, _month.month)),
                    itemBuilder: (BuildContext context) => years
                        .map(
                          (int year) => PopupMenuItem<int>(
                            value: year,
                            child: Text(
                              '$year',
                              style: TextStyle(
                                fontWeight: year == _month.year ? FontWeight.w800 : FontWeight.w500,
                                color: year == _month.year ? _highlight : _ink,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${_month.year}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: _ink),
                        ),
                        const Icon(Icons.arrow_drop_down, color: _ink),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Next month',
              onPressed: atLast ? null : () => _shift(1),
              icon: const Icon(Icons.chevron_right, color: _ink),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'This month',
              onPressed: () {
                final DateTime today = DateTime.now();
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
              for (int column = 0; column < 7; column++) Expanded(child: _cell(grid, row * 7 + column)),
            ],
          ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF9A9086)),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _start == null
                  ? null
                  : () => widget.onSubmit(DateTimeRange(start: _start!, end: _end ?? _start!)),
              style: FilledButton.styleFrom(
                backgroundColor: _highlight,
                disabledBackgroundColor: _highlight.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
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
    return InkWell(
      onTap: () => _pick(day),
      child: SizedBox(
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
      ),
    );
  }
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
