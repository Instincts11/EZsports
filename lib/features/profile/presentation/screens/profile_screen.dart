import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/network/api_error.dart';
import 'package:ezsports/core/utils/api_time.dart';
import 'package:ezsports/features/auth/data/auth_repository.dart';
import 'package:ezsports/features/profile/data/models/leave_model.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/core/auth/auth_session.dart';
import 'package:ezsports/features/home/data/models/home_dashboard_model.dart';
import 'package:ezsports/features/home/providers/home_providers.dart';
import 'package:ezsports/features/classes/data/models/session_model.dart';
import 'package:ezsports/features/classes/providers/classes_providers.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:ezsports/features/matches/providers/matches_providers.dart';
import 'package:ezsports/features/profile/data/models/coach_profile_model.dart';
import 'package:ezsports/features/profile/providers/profile_providers.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CoachProfileModel> profileAsync = ref.watch(coachProfileProvider);
    final CoachProfileModel? profile = profileAsync.asData?.value;
    final int players = ref.watch(playersProvider).maybeWhen(
      data: (List<StudentModel> roster) => roster.length,
      orElse: () => 0,
    );
    final int sessions = ref.watch(sessionsProvider).maybeWhen(
      data: (List<SessionModel> items) => items.where((SessionModel session) => _inThisWeek(session.date)).length,
      orElse: () => 0,
    );
    final List<MatchModel> fixtures = ref.watch(matchesProvider).maybeWhen(
      data: (List<MatchModel> items) => items,
      orElse: () => const <MatchModel>[],
    );
    final int weekFixtures = fixtures.where((MatchModel match) => _inThisWeek(parseApiDate(match.date))).length;
    final String name = profile?.name.isNotEmpty == true ? profile!.name : 'Coach';
    final String initials = profile?.initials ?? 'C';
    final HomeDashboardModel? home = ref.watch(homeDashboardProvider).asData?.value;
    final String academy = home?.academyName ?? '';
    final String academyLabel = academy.isEmpty ? 'Academy' : academy;
    final AsyncValue<List<LeaveModel>> leaves = ref.watch(coachLeavesProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 12, AppSizes.screenPadding, 28),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                _InitialsBadge(initials: initials),
                const SizedBox(height: 12),
                Text(name, style: AppTextStyles.displayName),
                const SizedBox(height: 4),
                Text(academyLabel, style: AppTextStyles.academySubtitle),
                if (profile?.headline.isNotEmpty == true)
                  Text(profile!.headline, style: AppTextStyles.bodyOnDark),
                if ((home?.phone ?? '').trim().isNotEmpty)
                  Text(home!.phone.trim(), style: AppTextStyles.bodyOnDark),
                if ((home?.address ?? '').trim().isNotEmpty)
                  Text(home!.address.trim(), style: AppTextStyles.bodyOnDark),
                TextButton(
                  onPressed: () => context.push('/profile/details'),
                  child: const Text('Edit', style: AppTextStyles.link),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DetailRow(label: 'Academy', value: academyLabel),
                if (profile?.experience.isNotEmpty == true)
                  _DetailRow(label: 'Experience', value: profile!.experience),
                if (profile?.certifications.isNotEmpty == true)
                  _DetailRow(label: 'Licence', value: profile!.certifications),
                const SizedBox(height: 8),
                const Text('My attendance this month', style: AppTextStyles.title),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(child: _WeekStat(label: 'Sessions', value: '${home?.attendanceDays ?? 0}')),
                    const SizedBox(width: 8),
                    Expanded(child: _WeekStat(label: 'Present', value: '${home?.attended ?? 0}')),
                    const SizedBox(width: 8),
                    Expanded(child: _WeekStat(label: 'Absent', value: '${home?.missed ?? 0}')),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('My leaves', style: AppTextStyles.title),
                const SizedBox(height: 8),
                ...leaves.maybeWhen(
                  data: (List<LeaveModel> rows) => rows.isEmpty
                      ? <Widget>[const _FixtureLine('No leave requests')]
                      : rows
                          .map(
                            (LeaveModel leave) => _DetailRow(
                              label: '${formatApiDate(leave.fromDate)} – ${formatApiDate(leave.toDate)} · ${leave.reason}',
                              value: leave.status,
                            ),
                          )
                          .toList(),
                  orElse: () => <Widget>[const _FixtureLine('Loading leave requests')],
                ),
                const SizedBox(height: 8),
                const Text('Upcoming fixtures', style: AppTextStyles.title),
                const SizedBox(height: 8),
                if (fixtures.isEmpty)
                  const _FixtureLine('No fixtures yet')
                else
                  ...fixtures.take(5).map(
                    (MatchModel match) => _FixtureLine(
                      <String>[
                        match.kickoff,
                        match.opponentLabel,
                        if (match.venue.isNotEmpty) match.venue,
                        if (match.result.isNotEmpty) match.result,
                      ].join(' · '),
                    ),
                  ),
                const SizedBox(height: 8),
                const Text('This week', style: AppTextStyles.title),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(child: _WeekStat(label: 'Sessions', value: '$sessions')),
                    const SizedBox(width: 8),
                    Expanded(child: _WeekStat(label: 'Fixtures', value: '$weekFixtures')),
                    const SizedBox(width: 8),
                    Expanded(child: _WeekStat(label: 'Players', value: '$players')),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Contact', style: AppTextStyles.title),
                const SizedBox(height: 8),
                _DetailRow(label: 'Mobile', value: profile?.mobile.isNotEmpty == true ? profile!.mobile : '-'),
                _DetailRow(label: 'Email', value: profile?.email.isNotEmpty == true ? profile!.email : '-'),
                if (profile?.emergencyContact.isNotEmpty == true)
                  _DetailRow(label: 'Emergency', value: profile!.emergencyContact),
                if (profile?.dob.isNotEmpty == true)
                  _DetailRow(label: 'Date of birth', value: profile!.dob),
                if (profile?.gender.isNotEmpty == true)
                  _DetailRow(label: 'Gender', value: profile!.gender),
                if (profile?.address.isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: 8),
                  const Text('Address', style: AppTextStyles.title),
                  const SizedBox(height: 6),
                  Text(profile!.address, style: AppTextStyles.body),
                ],
                if (profileAsync.hasError) ...<Widget>[
                  const SizedBox(height: 8),
                  const Text('Sign in as a coach to load this profile.', style: AppTextStyles.muted),
                ],
                const SizedBox(height: 16),
                const Text('Account', style: AppTextStyles.title),
                _ChevronRow(label: 'Notifications', onTap: () => _showNotifications(context)),
                _ChevronRow(label: 'Change password', onTap: () => _showChangePassword(context)),
                const SizedBox(height: 16),
                SizedBox(
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
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text(AppStrings.logout, style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool _inThisWeek(DateTime? date) {
  if (date == null) {
    return false;
  }
  final DateTime now = DateTime.now();
  final DateTime start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final DateTime end = start.add(const Duration(days: 7));
  final DateTime day = DateTime(date.year, date.month, date.day);
  return !day.isBefore(start) && day.isBefore(end);
}

class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Text(initials, style: AppTextStyles.displayName.copyWith(fontSize: 28)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: AppTextStyles.muted.copyWith(color: const Color(0xFF8A8178)))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  const _ChevronRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Text(label, style: AppTextStyles.body),
            const Spacer(),
            const Icon(AppIcons.chevron, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _FixtureLine extends StatelessWidget {
  const _FixtureLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: AppTextStyles.body),
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  const _WeekStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(label, style: AppTextStyles.caption.copyWith(color: const Color(0xFF8A8178))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }
}

Future<void> _showCoachOverlay({
  required BuildContext pageContext,
  required Widget Function(BuildContext overlayContext, void Function(void Function()) setState) builder,
}) {
  return showGeneralDialog<void>(
    context: pageContext,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0xB3000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (BuildContext overlayContext, Animation<double> animation, Animation<double> secondary) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Center(
              child: Material(
                color: AppColors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 10)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: builder(overlayContext, setState),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> showCoachNotifications(BuildContext pageContext) {
  return _showNotifications(pageContext);
}

Future<void> _showNotifications(BuildContext pageContext) {
  bool sessions = true;
  bool fixtures = true;
  bool fees = false;
  return _showCoachOverlay(
    pageContext: pageContext,
    builder: (BuildContext overlayContext, void Function(void Function()) setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Notifications', style: TextStyle(fontSize: 22, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            title: const Text('Session reminders', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            value: sessions,
            onChanged: (bool value) => setState(() => sessions = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            title: const Text('Fixture updates', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            value: fixtures,
            onChanged: (bool value) => setState(() => fixtures = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            title: const Text('Fee reminders', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            value: fees,
            onChanged: (bool value) => setState(() => fees = value),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(overlayContext).pop(),
              child: const Text('Done', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _showChangePassword(BuildContext pageContext) {
  final TextEditingController current = TextEditingController();
  final TextEditingController next = TextEditingController();
  final TextEditingController confirm = TextEditingController();
  String? error;
  bool saving = false;
  return _showCoachOverlay(
    pageContext: pageContext,
    builder: (BuildContext overlayContext, void Function(void Function()) setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Change password', style: TextStyle(fontSize: 22, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: current,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            cursorColor: AppColors.primary,
            decoration: _passwordDecoration('Current password'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: next,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            cursorColor: AppColors.primary,
            decoration: _passwordDecoration('New password'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirm,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            cursorColor: AppColors.primary,
            decoration: _passwordDecoration('Confirm new password'),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: AppColors.primary)),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(overlayContext).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (current.text.trim().isEmpty || next.text.trim().length < 6) {
                          setState(() => error = 'Enter your current password and a new one of at least 6 characters.');
                          return;
                        }
                        if (next.text != confirm.text) {
                          setState(() => error = 'The new passwords do not match.');
                          return;
                        }
                        setState(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          await AuthRepository().changePassword(currentPassword: current.text, newPassword: next.text);
                        } catch (cause) {
                          setState(() {
                            saving = false;
                            error = apiErrorMessage(cause, 'The password could not be changed.');
                          });
                          return;
                        }
                        if (overlayContext.mounted) {
                          Navigator.of(overlayContext).pop();
                        }
                        if (pageContext.mounted) {
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            const SnackBar(content: Text('Password updated')),
                          );
                        }
                      },
                child: Text(saving ? 'Saving' : 'Save', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      );
    },
  ).whenComplete(() {
    current.dispose();
    next.dispose();
    confirm.dispose();
  });
}

InputDecoration _passwordDecoration(String label) {
  const OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.primary, width: 1.6),
  );
  return InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
    floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
    filled: true,
    fillColor: Color(0xFFFFFFFF),
    contentPadding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
    enabledBorder: border,
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.playerGold, width: 2.2),
    ),
  );
}
