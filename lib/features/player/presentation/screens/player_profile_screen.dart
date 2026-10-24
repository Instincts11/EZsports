import 'package:ezsports/core/auth/auth_session.dart';
import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/network/api_error.dart';
import 'package:ezsports/core/utils/api_time.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/auth/data/auth_repository.dart';
import 'package:ezsports/features/player/data/models/player_profile_model.dart';
import 'package:ezsports/features/player/presentation/widgets/player_widgets.dart';
import 'package:ezsports/features/matches/data/models/match_model.dart';
import 'package:ezsports/features/player/data/models/player_home_model.dart';
import 'package:ezsports/features/player/providers/player_home_providers.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshPlayerDraft(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PlayerProfileModel> profileAsync = ref.watch(playerProfileProvider);
    final PlayerHomeModel? home = ref.watch(playerHomeProvider).asData?.value;
    final String academy = home?.academyName ?? '';
    final String contact = <String>[
      if ((home?.phone ?? '').trim().isNotEmpty) home!.phone.trim(),
      if ((home?.address ?? '').trim().isNotEmpty) home!.address.trim(),
    ].join(' · ');
    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.playerAccent)),
      error: (Object error, StackTrace stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(playerLoadMessage(error), style: AppTextStyles.bodyOnDark, textAlign: TextAlign.center),
        ),
      ),
      data: (PlayerProfileModel profile) => _profile(context, profile, academy, contact),
    );
  }

  Widget _profile(BuildContext context, PlayerProfileModel profile, String academy, String contact) {
    final String displayName = profile.name.isEmpty ? 'Player' : profile.name;
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
                Text(academy.isEmpty ? 'Academy' : academy, style: const TextStyle(color: AppColors.playerGold, fontWeight: FontWeight.w600)),
                if (contact.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(contact, style: const TextStyle(color: AppColors.playerCream, fontWeight: FontWeight.w600)),
                  ),
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
                if (_tab == 0) _InfoTab(profile: profile),
                if (_tab == 1) const _AttendanceTab(),
                if (_tab == 2) const _FixturesTab(),
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

String _show(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }
  return value;
}

String _verifiedOn(String? value) {
  final DateTime? date = parseApiDate(value);
  return date == null ? 'Verified' : 'Verified ${formatApiDate(value)} ${date.year}';
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.profile});

  final PlayerProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _InfoRow('First name', _show(profile.firstName)),
            _InfoRow('Last name', _show(profile.lastName)),
            _InfoRow('Date of birth', _show(profile.dob)),
            _InfoRow('Gender', _show(profile.gender)),
            _InfoRow('Mobile', _show(profile.mobile)),
            _InfoRow('Emergency', _show(profile.emergencyContact)),
            const _Heading('Guardian'),
            _InfoRow('Guardian name', _show(profile.guardianName)),
            _InfoRow('Guardian mobile', _show(profile.parentMobile)),
            const _Heading('Playing'),
            _InfoRow('Position', _show(profile.position)),
            _InfoRow('Preferred foot', _show(profile.preferredFoot)),
            _InfoRow('School', _show(profile.school)),
            _InfoRow('Class', _show(profile.schoolClass)),
            _InfoRow('Jersey', _show(profile.jersey)),
            const _Heading('Medical'),
            _InfoRow('Blood group', _show(profile.bloodGroup)),
            _InfoRow('Allergies', _show(profile.allergies)),
            if ((profile.coachNote ?? '').trim().isNotEmpty) ...<Widget>[
              const _Heading('From the academy'),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(profile.coachNote!.trim(), style: const TextStyle(color: AppColors.playerCream, fontWeight: FontWeight.w600)),
              ),
            ],
            if (profile.otpVerifiedAt != null) ...<Widget>[
              const _Heading('Account'),
              _InfoRow('Signup OTP', _verifiedOn(profile.otpVerifiedAt)),
            ],
            const _Heading('Settings'),
            _ChevronLine('Notifications', onTap: () => _showNotifications(context)),
            _ChevronLine('Change password', onTap: () => _showChangePassword(context)),
            const SizedBox(height: 16),
            const _LogoutButton(),
          ],
    );
  }
}

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlayerAttendanceModel>> attendance = ref.watch(playerAttendanceProvider);
    return attendance.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.playerAccent)),
      ),
      error: (Object error, StackTrace stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(playerLoadMessage(error), style: const TextStyle(color: Color(0xFF5C564E))),
      ),
      data: (List<PlayerAttendanceModel> rows) {
        final int missed = rows.where((PlayerAttendanceModel row) => row.missed).length;
        final int attended = rows.length - missed;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(child: AttendanceRing(value: rows.length, label: 'Days', color: AppColors.playerAccent, progress: rows.isEmpty ? 0 : 1)),
                Expanded(child: AttendanceRing(value: attended, label: 'Attended', color: AppColors.playerAmber, progress: rows.isEmpty ? 0 : attended / rows.length)),
                Expanded(child: AttendanceRing(value: missed, label: 'Missed', color: AppColors.playerCoral, progress: rows.isEmpty ? 0 : missed / rows.length)),
              ],
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              const Text('No attendance has been marked yet.', style: TextStyle(color: Color(0xFF5C564E)))
            else
              ...rows.map((PlayerAttendanceModel row) => _CheckLine(row.label, missed: row.missed)),
          ],
        );
      },
    );
  }
}

class _FixturesTab extends ConsumerWidget {
  const _FixturesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MatchModel>> matches = ref.watch(playerMatchesProvider);
    return matches.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.playerAccent)),
      ),
      error: (Object error, StackTrace stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(playerLoadMessage(error), style: const TextStyle(color: Color(0xFF5C564E))),
      ),
      data: (List<MatchModel> rows) {
        final MatchModel? next = rows.cast<MatchModel?>().firstWhere(
              (MatchModel? match) => match != null && match.status != 'previous',
              orElse: () => null,
            );
        final MatchModel? last = rows.cast<MatchModel?>().lastWhere(
              (MatchModel? match) => match != null && match.status == 'previous',
              orElse: () => null,
            );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 12),
            if (next == null && last == null)
              const Text('No fixtures for your batches yet.', style: TextStyle(color: Color(0xFF5C564E)))
            else ...<Widget>[
              if (next != null) ...<Widget>[
                const Text(
                  'NEXT',
                  style: TextStyle(color: AppColors.playerAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                ),
                const SizedBox(height: 6),
                Text(next.opponentLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.playerAccent)),
                const SizedBox(height: 4),
                Text(next.kickoff, style: const TextStyle(color: AppColors.playerInk)),
                if (next.venue.isNotEmpty) Text(next.venue, style: const TextStyle(color: Color(0xFF5C564E))),
                if (next.batchName.isNotEmpty) Text(next.batchName, style: const TextStyle(color: Color(0xFF5C564E))),
              ],
              if (last != null) ...<Widget>[
                const SizedBox(height: 14),
                const Text('Last result', style: TextStyle(color: Color(0xFF8C8378))),
                Text(
                  <String>[last.kickoff, last.opponentLabel, if (last.result.isNotEmpty) last.result, if (last.venue.isNotEmpty) last.venue].join(' · '),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.playerInk),
                ),
              ],
            ],
          ],
        );
      },
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
          StatusPill(missed ? 'Missed' : 'Present', tone: missed ? PillTone.coral : PillTone.teal),
        ],
      ),
    );
  }
}

class _ChevronLine extends StatelessWidget {
  const _ChevronLine(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
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
        ),
        const Divider(height: 1, color: AppColors.playerLine),
      ],
    );
  }
}

Future<void> _showPlayerOverlay({
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
                        color: AppColors.playerCream,
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

Future<void> showPlayerNotifications(BuildContext pageContext) {
  return _showNotifications(pageContext);
}

Future<void> _showNotifications(BuildContext pageContext) {
  bool sessions = true;
  bool fixtures = true;
  bool fees = false;
  return _showPlayerOverlay(
    pageContext: pageContext,
    builder: (BuildContext overlayContext, void Function(void Function()) setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Notifications', style: TextStyle(fontSize: 22, color: AppColors.playerInk, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.playerAccent,
            title: const Text('Session reminders', style: TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700)),
            value: sessions,
            onChanged: (bool value) => setState(() => sessions = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.playerAccent,
            title: const Text('Fixture updates', style: TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700)),
            value: fixtures,
            onChanged: (bool value) => setState(() => fixtures = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.playerAccent,
            title: const Text('Fee reminders', style: TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700)),
            value: fees,
            onChanged: (bool value) => setState(() => fees = value),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(overlayContext).pop(),
              child: const Text('Done', style: TextStyle(color: AppColors.playerAccent, fontWeight: FontWeight.w700)),
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
  return _showPlayerOverlay(
    pageContext: pageContext,
    builder: (BuildContext overlayContext, void Function(void Function()) setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Change password', style: TextStyle(fontSize: 22, color: AppColors.playerInk, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: current,
            obscureText: true,
            style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700),
            cursorColor: AppColors.playerAccent,
            decoration: _passwordDecoration('Current password'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: next,
            obscureText: true,
            style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700),
            cursorColor: AppColors.playerAccent,
            decoration: _passwordDecoration('New password'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirm,
            obscureText: true,
            style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700),
            cursorColor: AppColors.playerAccent,
            decoration: _passwordDecoration('Confirm new password'),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: AppColors.playerCoral)),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(overlayContext).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.playerCoral, fontWeight: FontWeight.w700)),
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
                child: Text(saving ? 'Saving' : 'Save', style: const TextStyle(color: AppColors.playerAccent, fontWeight: FontWeight.w700)),
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
    borderSide: BorderSide(color: AppColors.playerAccent, width: 1.6),
  );
  return InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w800),
    floatingLabelStyle: const TextStyle(color: AppColors.playerAccent, fontWeight: FontWeight.w800),
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
