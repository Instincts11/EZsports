import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/player/data/models/player_home_model.dart';
import 'package:ezsports/features/player/providers/player_home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<String> skipSessionReasons = <String>[
  'School or exam',
  'Unwell',
  'Family commitment',
  'Travel',
  'Already arranged with coach',
];

Widget? sessionBadge(PlayerSessionModel session, {Widget? fallback}) {
  if (session.skipped) {
    return const StatusPill('Skipped', tone: PillTone.coral);
  }
  if (session.attendanceStatus == 'present') {
    return const StatusPill('Attended', tone: PillTone.solid);
  }
  if (session.attendanceStatus == 'absent') {
    return const StatusPill('Missed', tone: PillTone.coral);
  }
  if (session.checkedIn) {
    return const StatusPill('Checked in', tone: PillTone.solid);
  }
  return fallback;
}

Future<void> skipOrUndoSession(BuildContext context, WidgetRef ref, PlayerSessionModel session, String sessionLabel) async {
  try {
    if (session.skipped) {
      await respondToSession(ref, session.session.sessionId, clearSkip: true);
      return;
    }
    final String? reason = await showSkipSessionSheet(context, sessionLabel: sessionLabel, coachName: session.coachName);
    if (reason == null) {
      return;
    }
    await respondToSession(ref, session.session.sessionId, skipReason: reason);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Check your connection and try again.')),
      );
    }
  }
}

Future<String?> showSkipSessionSheet(BuildContext context, {required String sessionLabel, String? coachName}) {
  final String coach = coachName == null || coachName.trim().isEmpty ? 'Your coach' : 'Coach ${coachName.trim()}';
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.playerCream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (BuildContext sheetContext) {
      final MediaQueryData media = MediaQuery.of(sheetContext);
      final double maxHeight = media.size.height * 0.85 - media.padding.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: media.padding.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            children: <Widget>[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.playerLine,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Skip $sessionLabel',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.playerInk),
              ),
              const SizedBox(height: 6),
              Text(
                '$coach gets the reason before the session. Your place in the group stays.',
                style: const TextStyle(color: Color(0xFF5C564E), height: 1.35),
              ),
              const SizedBox(height: 4),
              for (final String reason in skipSessionReasons)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: Text(reason, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.playerInk)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.playerAccent),
                  onTap: () => Navigator.of(sheetContext).pop(reason),
                ),
            ],
          ),
        ),
      );
    },
  );
}

enum PillTone { teal, coral, solid }

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.tone = PillTone.teal});

  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final bool solid = tone == PillTone.solid;
    final Color color = tone == PillTone.coral ? AppColors.playerCoral : AppColors.playerAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: solid ? AppColors.playerAccent : AppColors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: solid ? null : Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: solid ? AppColors.onPrimary : color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key, required this.checked, required this.onPressed, this.label = "I'm here"});

  final bool checked;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.playerAccent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(checked ? Icons.check_circle : Icons.check, size: 16, color: AppColors.onPrimary),
              const SizedBox(width: 6),
              Text(
                checked ? 'Here' : label,
                style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceRing extends StatelessWidget {
  const AttendanceRing({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.progress,
  });

  final int value;
  final String label;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 78,
            height: 78,
            child: CustomPaint(
              painter: _RingPainter(color: color, progress: progress),
              child: Center(
                child: Text(
                  '$value',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color, fontFamily: 'serif'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 5;
    final Paint track = Paint()
      ..color = const Color(0xFFE4DDD4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final Paint arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2832 * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.date,
    required this.time,
    required this.batch,
    this.detail,
    this.pitch,
    this.badge,
    this.footer,
    this.borderColor,
    this.color = AppColors.playerCream,
  });

  final String date;
  final String time;
  final String batch;
  final String? detail;
  final String? pitch;
  final Widget? badge;
  final Widget? footer;
  final Color? borderColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      color: color,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(date, style: AppTextStyles.muted),
                    const SizedBox(height: 4),
                    Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.playerInk)),
                    Text(batch, style: AppTextStyles.muted),
                    if (pitch != null && pitch!.isNotEmpty) Text('Pitch: $pitch', style: AppTextStyles.muted),
                    if (detail != null) Text(detail!, style: AppTextStyles.muted),
                  ],
                ),
              ),
              if (badge != null) badge!,
            ],
          ),
          if (footer != null) ...<Widget>[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}

class PlayerSectionTitle extends StatelessWidget {
  const PlayerSectionTitle(this.text, {super.key, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(text, style: AppTextStyles.heading)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: AppTextStyles.playerLink),
          ),
      ],
    );
  }
}

class DayChip extends StatelessWidget {
  const DayChip({
    super.key,
    required this.label,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 46,
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.playerAccent : AppColors.playerMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.playerAccent : AppColors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.onPrimary : AppColors.textOnDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
