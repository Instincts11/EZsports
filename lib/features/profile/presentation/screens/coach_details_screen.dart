import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/detail_field.dart';
import 'package:ezsports/features/profile/data/models/coach_profile_model.dart';
import 'package:ezsports/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CoachDetailsScreen extends ConsumerStatefulWidget {
  const CoachDetailsScreen({super.key});

  @override
  ConsumerState<CoachDetailsScreen> createState() => _CoachDetailsScreenState();
}

class _CoachDetailsScreenState extends ConsumerState<CoachDetailsScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _experience = TextEditingController();
  final TextEditingController _certifications = TextEditingController();
  final TextEditingController _emergency = TextEditingController();
  final TextEditingController _address = TextEditingController();
  bool _filled = false;
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobile.dispose();
    _gender.dispose();
    _experience.dispose();
    _certifications.dispose();
    _emergency.dispose();
    _address.dispose();
    super.dispose();
  }

  void _apply(CoachProfileModel profile) {
    if (_filled) {
      return;
    }
    _filled = true;
    final List<String> parts = profile.name.trim().split(RegExp(r'\s+')).where((String part) => part.isNotEmpty).toList();
    _firstName.text = parts.isEmpty ? '' : parts.first;
    _lastName.text = parts.length < 2 ? '' : parts.sublist(1).join(' ');
    _mobile.text = profile.mobile;
    _gender.text = profile.gender;
    _experience.text = profile.experience;
    _certifications.text = profile.certifications;
    _emergency.text = profile.emergencyContact;
    _address.text = profile.address;
  }

  Future<void> _save() async {
    final String name = '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
    if (_firstName.text.trim().isEmpty || _mobile.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name and mobile number before saving.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(<String, dynamic>{
        'name': name,
        'mobile': _mobile.text.trim(),
        'gender': _blankToNull(_gender.text),
        'experience': _blankToNull(_experience.text),
        'certifications': _blankToNull(_certifications.text),
        'emergency_contact': _blankToNull(_emergency.text),
        'address': _blankToNull(_address.text),
      });
      ref.invalidate(coachProfileProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved coach details for $name')),
      );
      context.go('/profile');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coach details could not be saved.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _blankToNull(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CoachProfileModel> profile = ref.watch(coachProfileProvider);
    profile.whenData(_apply);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => context.go('/profile'),
                  icon: const Icon(AppIcons.back, color: AppColors.primary),
                ),
                const Expanded(child: Text('Coach details', style: AppTextStyles.pageTitle)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 18),
              child: Text('These details are stored on your coach profile.', style: AppTextStyles.muted),
            ),
            if (profile.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            DetailField(label: 'First name', controller: _firstName),
            DetailField(label: 'Last name', controller: _lastName),
            DetailField(label: 'Mobile', controller: _mobile, keyboardType: TextInputType.phone),
            DetailField(label: 'Gender', controller: _gender),
            DetailField(label: 'Experience', controller: _experience),
            DetailField(label: 'Certifications', controller: _certifications),
            DetailField(label: 'Emergency contact', controller: _emergency, keyboardType: TextInputType.phone),
            DetailField(label: 'Address', controller: _address, maxLines: 3),
            const SizedBox(height: 8),
            AppButton(label: _saving ? 'Saving…' : 'Save details', onPressed: _saving ? () {} : _save),
          ],
        ),
      ),
    );
  }
}
