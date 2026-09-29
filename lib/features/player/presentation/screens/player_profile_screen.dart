import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/player/presentation/widgets/player_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerAccountScreen extends StatefulWidget {
  const PlayerAccountScreen({super.key});

  @override
  State<PlayerAccountScreen> createState() => _PlayerAccountScreenState();
}

class _PlayerAccountScreenState extends State<PlayerAccountScreen> {
  int _tab = 0;

  static const List<String> _tabs = <String>['Info', 'Attendance', 'Batches'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 12, AppSizes.screenPadding, 28),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                const _Avatar(),
                const SizedBox(height: 12),
                const Text('Advaita S', style: AppTextStyles.displayName),
                const SizedBox(height: 4),
                const Text(AppStrings.academyName, style: TextStyle(color: AppColors.playerGold, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => context.push('/player/profile/details'),
                  child: const Text('Edit', style: AppTextStyles.playerLink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CreamCard(
            color: AppColors.playerCream,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    for (int index = 0; index < _tabs.length; index++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = index),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 8),
                              Text(
                                _tabs[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _tab == index ? AppColors.playerAccent : const Color(0xFF8C8378),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 2,
                                color: _tab == index ? AppColors.playerAccent : AppColors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_tab == 0) const _InfoTab(),
                if (_tab == 1) const _AttendanceTab(),
                if (_tab == 2) const _BatchesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.playerAccent, width: 2),
      ),
      child: const Text('AS', style: TextStyle(fontSize: 28, color: AppColors.textOnDark, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _InfoRow('First name', 'Advaita'),
        const _InfoRow('Last name', 'S'),
        const _InfoRow('DOB', '12 Mar 2014'),
        const _InfoRow('Gender', 'Female'),
        const _InfoRow('Mobile', '+91 98765 43210'),
        const _InfoRow('Emergency', '+91 99618 61588'),
        const _InfoRow('Batch', 'Weekend Evening'),
        const _Heading('Guardian'),
        const _InfoRow('Name', 'Meera S'),
        const _InfoRow('Mobile', '+91 98470 22109'),
        const _Heading('Academy'),
        const _InfoRow('Academy', 'Esperanza Football Academy'),
        const _InfoRow('Player since', 'Jun 2024'),
        const _InfoRow('Jersey', '7'),
        const _InfoRow('Coach', 'R. Nair'),
        const _Heading('Playing'),
        const _InfoRow('Position', 'Attacking midfield'),
        const _InfoRow('Preferred foot', 'Right'),
        const _InfoRow('Working on', 'Left-foot pass'),
        const _InfoRow('School', 'Esperanza Public'),
        const _InfoRow('Class', '6'),
        const _Heading('Medical'),
        const _InfoRow('Blood group', 'O+'),
        const _InfoRow('Allergies', 'None recorded'),
        const _InfoRow('This season', 'No injuries'),
        const _InfoRow('Clearance', 'Full training'),
        const _Heading('Fees'),
        const _InfoRow('September', '₹2,500 due'),
        const _InfoRow('Due date', '10 Sep 2026'),
        const _InfoRow('Paid', 'Jun, Jul, Aug'),
        const _Heading('Attendance this month'),
        const SizedBox(height: 8),
        const Row(
          children: <Widget>[
            Expanded(child: AttendanceRing(value: 8, label: 'Days', color: AppColors.playerAccent, progress: 0.78)),
            Expanded(child: AttendanceRing(value: 6, label: 'Attended', color: AppColors.playerAmber, progress: 0.62)),
            Expanded(child: AttendanceRing(value: 2, label: 'Missed', color: AppColors.playerCoral, progress: 0.28)),
          ],
        ),
        const SizedBox(height: 8),
        const _CheckLine('06 Sep · Weekend Evening', missed: false),
        const _CheckLine('31 Aug · Weekend Evening', missed: false),
        const _CheckLine('30 Aug · Weekend Evening', missed: true),
        const _CheckLine('24 Aug · Weekend Evening', missed: false),
        const _Heading('Batches'),
        const _InfoRow('Weekend Evening', 'Sun Sat'),
        const _InfoRow('Next session', '13 Sep'),
        const _Heading('Settings'),
        const _ChevronLine('Notifications'),
        const _ChevronLine('Change password'),
        const SizedBox(height: 16),
        _LogoutButton(),
      ],
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: AttendanceRing(value: 8, label: 'Days', color: AppColors.playerAccent, progress: 0.78)),
            Expanded(child: AttendanceRing(value: 6, label: 'Attended', color: AppColors.playerAmber, progress: 0.62)),
            Expanded(child: AttendanceRing(value: 2, label: 'Missed', color: AppColors.playerCoral, progress: 0.28)),
          ],
        ),
        SizedBox(height: 12),
        _CheckLine('06 Sep · Weekend Evening', missed: false),
        _CheckLine('31 Aug · Weekend Evening', missed: false),
        _CheckLine('30 Aug · Weekend Evening', missed: true),
        _CheckLine('24 Aug · Weekend Evening', missed: false),
        _CheckLine('23 Aug · Weekend Evening', missed: false),
        _CheckLine('17 Aug · Weekend Evening', missed: false),
        _CheckLine('16 Aug · Weekend Evening', missed: false),
        _CheckLine('10 Aug · Weekend Evening', missed: true),
        _CheckLine('09 Aug · Weekend Evening', missed: false),
        _CheckLine('02 Aug · Weekend Evening', missed: false),
        SizedBox(height: 8),
        Text(
          'Two misses this month were unmarked. An explained absence still counts as missed, but it keeps the coach from calling home.',
          style: TextStyle(color: Color(0xFF5C564E), height: 1.35),
        ),
      ],
    );
  }
}

class _BatchesTab extends StatelessWidget {
  const _BatchesTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 12),
        Text(
          'ENROLLED',
          style: TextStyle(color: AppColors.playerAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
        SizedBox(height: 6),
        Text('Weekend Evening', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.playerAccent)),
        SizedBox(height: 4),
        Text('Sun Sat · 3:30 PM – 5:00 PM', style: TextStyle(color: AppColors.playerInk)),
        Text('Pitch B · Coach R. Nair · 15 players', style: TextStyle(color: Color(0xFF5C564E))),
        SizedBox(height: 14),
        Text('Next session', style: TextStyle(color: Color(0xFF8C8378))),
        Text('Sun 13 Sep · 3:30 PM', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
        SizedBox(height: 16),
        Text('What this group is for', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
        SizedBox(height: 4),
        Text('Match-week habits: arriving early, receiving on the half-turn, and defending as soon as the ball is lost. Summer Camp is extra touches, not a replacement for this group.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
        SizedBox(height: 12),
        Text('Guest sessions', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
        SizedBox(height: 4),
        Text('You may join Weekend Morning on 12 Sep if the pitch has space. Ask at the desk on Sunday. Weekday Evening stays closed — that group is already a full coaching set of 4.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
      ],
    );
  }
}

class _GoldDot extends StatelessWidget {
  const _GoldDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(color: AppColors.playerGold, shape: BoxShape.circle),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.playerInk)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: _GoldDot(),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Color(0xFF8C8378), fontSize: 14)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.playerLine),
      ],
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine(this.label, {required this.missed});

  final String label;
  final bool missed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w600))),
          StatusPill(missed ? 'Missed' : 'On time', tone: missed ? PillTone.coral : PillTone.teal),
        ],
      ),
    );
  }
}

class _ChevronLine extends StatelessWidget {
  const _ChevronLine(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: _GoldDot(),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w600))),
              const Icon(AppIcons.chevron, color: Color(0xFF8C8378)),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.playerLine),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => context.go('/login'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.playerCoral,
          side: const BorderSide(color: AppColors.playerCoral),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
