import 'package:ezsports/core/auth/auth_session.dart';
import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/player/data/models/player_profile_model.dart';
import 'package:ezsports/features/player/presentation/widgets/player_widgets.dart';
import 'package:ezsports/features/player/providers/player_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayerAccountScreen extends ConsumerStatefulWidget {
  const PlayerAccountScreen({super.key});

  @override
  ConsumerState<PlayerAccountScreen> createState() => _PlayerAccountScreenState();
}

class _PlayerAccountScreenState extends ConsumerState<PlayerAccountScreen> {
  int _tab = 0;

  static const List<String> _tabs = <String>['Info', 'Attendance', 'Fixtures'];

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PlayerProfileModel> profileAsync = ref.watch(playerProfileProvider);
    final String displayName = profileAsync.maybeWhen(
      data: (PlayerProfileModel profile) => profile.name,
      orElse: () => 'Player',
    );
    final String initials = displayName.isEmpty
        ? 'P'
        : displayName
            .split(' ')
            .where((String part) => part.isNotEmpty)
            .take(2)
            .map((String part) => part[0].toUpperCase())
            .join();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 12, AppSizes.screenPadding, 28),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                _Avatar(initials: initials),
                const SizedBox(height: 12),
                Text(displayName, style: AppTextStyles.displayName),
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
                if (_tab == 0) _InfoTab(profileAsync: profileAsync),
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
  const _Avatar({required this.initials});

  final String initials;

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
      child: Text(initials, style: const TextStyle(fontSize: 28, color: AppColors.textOnDark, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.profileAsync});

  final AsyncValue<PlayerProfileModel> profileAsync;

  @override
  Widget build(BuildContext context) {
    return profileAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Sign in as a player after OTP signup to load stored details.\n$error',
          style: AppTextStyles.muted,
        ),
      ),
      data: (PlayerProfileModel profile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _InfoRow('First name', profile.firstName ?? '-'),
            _InfoRow('Last name', profile.lastName ?? '-'),
            _InfoRow('DOB', profile.dob ?? '-'),
            _InfoRow('Gender', profile.gender ?? '-'),
            _InfoRow('Mobile', profile.mobile ?? '-'),
            _InfoRow('Emergency', profile.emergencyContact ?? '-'),
            const _Heading('Guardian'),
            _InfoRow('Name', profile.guardianName ?? '-'),
            _InfoRow('Mobile', profile.parentMobile),
            const _Heading('Academy'),
            const _InfoRow('Academy', AppStrings.academyName),
            _InfoRow('Jersey', profile.jersey ?? '-'),
            const _Heading('Playing'),
            _InfoRow('Position', profile.position ?? '-'),
            _InfoRow('Preferred foot', profile.preferredFoot ?? '-'),
            _InfoRow('School', profile.school ?? '-'),
            _InfoRow('Class', profile.schoolClass ?? '-'),
            const _Heading('Medical'),
            _InfoRow('Blood group', profile.bloodGroup ?? '-'),
            _InfoRow('Allergies', profile.allergies ?? '-'),
            if (profile.otpVerifiedAt != null) ...<Widget>[
              const _Heading('Account'),
              const _InfoRow('Signup OTP', 'Verified once'),
            ],
            const _Heading('Settings'),
            const _ChevronLine('Notifications'),
            const _ChevronLine('Change password'),
            const SizedBox(height: 16),
            const _LogoutButton(),
          ],
        );
      },
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
          'CALLED UP',
          style: TextStyle(color: AppColors.playerAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
        SizedBox(height: 6),
        Text('Kochi United', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.playerAccent)),
        SizedBox(height: 4),
        Text('Sun 13 Sep · 5:30 PM kickoff', style: TextStyle(color: AppColors.playerInk)),
        Text('Pitch B · meet at 4:45 PM · home kit', style: TextStyle(color: Color(0xFF5C564E))),
        SizedBox(height: 14),
        Text('Last result', style: TextStyle(color: Color(0xFF8C8378))),
        Text('30 Aug · 2–1 vs Harbour FC', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
        SizedBox(height: 16),
        Text('Your role', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk)),
        SizedBox(height: 4),
        Text('Named on the bench for Kochi United. Warm up with the starters and be ready to come on after half-time. Academy Cup on 20 Sep is not confirmed yet.', style: TextStyle(color: Color(0xFF5C564E), height: 1.35)),
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
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () async {
          await AuthSession.clear();
          if (context.mounted) {
            context.go('/login');
          }
        },
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
