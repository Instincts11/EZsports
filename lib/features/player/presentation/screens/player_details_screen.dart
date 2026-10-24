import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/network/api_error.dart';
import 'package:ezsports/core/widgets/detail_field.dart';
import 'package:ezsports/features/player/data/models/player_profile_model.dart';
import 'package:ezsports/features/player/providers/player_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayerDetailsScreen extends ConsumerStatefulWidget {
  const PlayerDetailsScreen({super.key});

  @override
  ConsumerState<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends ConsumerState<PlayerDetailsScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _emergency = TextEditingController();
  final TextEditingController _guardian = TextEditingController();
  final TextEditingController _guardianMobile = TextEditingController();
  final TextEditingController _position = TextEditingController();
  final TextEditingController _foot = TextEditingController();
  final TextEditingController _school = TextEditingController();
  final TextEditingController _schoolClass = TextEditingController();
  final TextEditingController _jersey = TextEditingController();
  final TextEditingController _blood = TextEditingController();
  final TextEditingController _allergies = TextEditingController();
  bool _hydrated = false;
  bool _userEdited = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fillFrom(ref.read(playerDraftProvider));
    _watchEdits();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshPlayerDraft(ref);
      if (mounted && !_userEdited) {
        setState(() => _fillFrom(ref.read(playerDraftProvider)));
      }
    });
  }

  void _watchEdits() {
    for (final TextEditingController controller in <TextEditingController>[
      _firstName,
      _lastName,
      _dob,
      _gender,
      _mobile,
      _emergency,
      _guardian,
      _guardianMobile,
      _position,
      _foot,
      _school,
      _schoolClass,
      _jersey,
      _blood,
      _allergies,
    ]) {
      controller.addListener(() {
        if (_hydrated) {
          _userEdited = true;
        }
      });
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _firstName,
      _lastName,
      _dob,
      _gender,
      _mobile,
      _emergency,
      _guardian,
      _guardianMobile,
      _position,
      _foot,
      _school,
      _schoolClass,
      _jersey,
      _blood,
      _allergies,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fillFrom(PlayerProfileModel profile) {
    _firstName.text = profile.firstName ?? '';
    _lastName.text = profile.lastName ?? '';
    _dob.text = profile.dob ?? '';
    _gender.text = profile.gender ?? '';
    _mobile.text = profile.mobile ?? '';
    _emergency.text = profile.emergencyContact ?? '';
    _guardian.text = profile.guardianName ?? '';
    _guardianMobile.text = profile.parentMobile;
    _position.text = profile.position ?? '';
    _foot.text = profile.preferredFoot ?? '';
    _school.text = profile.school ?? '';
    _schoolClass.text = profile.schoolClass ?? '';
    _jersey.text = profile.jersey ?? '';
    _blood.text = profile.bloodGroup ?? '';
    _allergies.text = profile.allergies ?? '';
    _hydrated = true;
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty || _guardian.text.trim().isEmpty || _guardianMobile.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add the player name and a guardian contact before saving.')),
      );
      return;
    }

    setState(() => _saving = true);
    final String first = _firstName.text.trim();
    final String last = _lastName.text.trim();
    try {
      final PlayerProfileModel saved = await ref.read(playerRepositoryProvider).updateProfile(<String, dynamic>{
        'first_name': first,
        'last_name': last,
        'name': '$first $last'.trim(),
        'dob': _dob.text.trim().isEmpty ? null : _dob.text.trim(),
        'gender': _gender.text.trim().isEmpty ? null : _gender.text.trim(),
        'mobile': _mobile.text.trim().isEmpty ? null : _mobile.text.trim(),
        'emergency_contact': _emergency.text.trim().isEmpty ? null : _emergency.text.trim(),
        'guardian_name': _guardian.text.trim(),
        'parent_mobile': _guardianMobile.text.trim(),
        'position': _position.text.trim().isEmpty ? null : _position.text.trim(),
        'preferred_foot': _foot.text.trim().isEmpty ? null : _foot.text.trim(),
        'school': _school.text.trim().isEmpty ? null : _school.text.trim(),
        'school_class': _schoolClass.text.trim().isEmpty ? null : _schoolClass.text.trim(),
        'jersey': _jersey.text.trim().isEmpty ? null : _jersey.text.trim(),
        'blood_group': _blood.text.trim().isEmpty ? null : _blood.text.trim(),
        'allergies': _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
      });
      ref.read(playerDraftProvider.notifier).state = saved;
      ref.invalidate(playerProfileProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved details for $first $last'.trim())),
      );
      context.go('/player/profile');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(error, 'Your details could not be saved. Check your connection and try again.'))),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerProfileModel profile = ref.watch(playerDraftProvider);

    return Scaffold(
      backgroundColor: AppColors.playerBackground,
      body: SafeArea(
        child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => context.go('/player/profile'),
                      icon: const Icon(AppIcons.back, color: AppColors.playerAccent),
                    ),
                    const Expanded(
                      child: Text('Player details', style: AppTextStyles.pageTitle),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 18),
                  child: Text('These details are stored on your account.', style: AppTextStyles.muted),
                ),
                if (profile.otpVerifiedAt != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 12, bottom: 12),
                    child: Text('Signup OTP verified', style: AppTextStyles.muted),
                  ),
                const _SectionLabel('Player'),
                DetailField(label: 'First name', controller: _firstName, accent: AppColors.playerAccent),
                DetailField(label: 'Last name', controller: _lastName, accent: AppColors.playerAccent),
                DetailField(label: 'Date of birth', controller: _dob, accent: AppColors.playerAccent),
                DetailField(label: 'Gender', controller: _gender, accent: AppColors.playerAccent),
                DetailField(
                  label: 'Mobile',
                  controller: _mobile,
                  accent: AppColors.playerAccent,
                  keyboardType: TextInputType.phone,
                ),
                DetailField(
                  label: 'Emergency',
                  controller: _emergency,
                  accent: AppColors.playerAccent,
                  keyboardType: TextInputType.phone,
                ),
                const _SectionLabel('Guardian'),
                DetailField(label: 'Guardian name', controller: _guardian, accent: AppColors.playerAccent),
                DetailField(
                  label: 'Guardian mobile',
                  controller: _guardianMobile,
                  accent: AppColors.playerAccent,
                  keyboardType: TextInputType.phone,
                ),
                const _SectionLabel('Playing'),
                DetailField(label: 'Position', controller: _position, accent: AppColors.playerAccent),
                DetailField(label: 'Preferred foot', controller: _foot, accent: AppColors.playerAccent),
                DetailField(label: 'School', controller: _school, accent: AppColors.playerAccent),
                DetailField(label: 'Class', controller: _schoolClass, accent: AppColors.playerAccent),
                DetailField(
                  label: 'Jersey',
                  controller: _jersey,
                  accent: AppColors.playerAccent,
                  keyboardType: TextInputType.number,
                ),
                const _SectionLabel('Medical'),
                DetailField(label: 'Blood group', controller: _blood, accent: AppColors.playerAccent),
                DetailField(label: 'Allergies', controller: _allergies, accent: AppColors.playerAccent, maxLines: 2),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.playerAccent,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _saving ? 'Saving…' : 'Save details',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Text(text, style: AppTextStyles.heading.copyWith(fontSize: 18)),
    );
  }
}
