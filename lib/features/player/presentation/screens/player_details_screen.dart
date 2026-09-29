import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/detail_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerDetailsScreen extends StatefulWidget {
  const PlayerDetailsScreen({super.key});

  @override
  State<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends State<PlayerDetailsScreen> {
  final TextEditingController _firstName = TextEditingController(text: 'Advaita');
  final TextEditingController _lastName = TextEditingController(text: 'S');
  final TextEditingController _dob = TextEditingController(text: '12 Mar 2014');
  final TextEditingController _gender = TextEditingController(text: 'Female');
  final TextEditingController _mobile = TextEditingController(text: '+91 98765 43210');
  final TextEditingController _emergency = TextEditingController(text: '+91 99618 61588');
  final TextEditingController _guardian = TextEditingController(text: 'Meera S');
  final TextEditingController _guardianMobile = TextEditingController(text: '+91 98470 22109');
  final TextEditingController _position = TextEditingController(text: 'Attacking midfield');
  final TextEditingController _foot = TextEditingController(text: 'Right');
  final TextEditingController _school = TextEditingController(text: 'Esperanza Public');
  final TextEditingController _schoolClass = TextEditingController(text: '6');
  final TextEditingController _jersey = TextEditingController(text: '7');
  final TextEditingController _blood = TextEditingController(text: 'O+');
  final TextEditingController _allergies = TextEditingController(text: 'None recorded');

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

  void _save() {
    if (_firstName.text.trim().isEmpty || _guardian.text.trim().isEmpty || _guardianMobile.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add the player name and a guardian contact before saving.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved details for ${_firstName.text.trim()} ${_lastName.text.trim()}'.trim())),
    );
    context.go('/player/profile');
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text('Enter the details shown on your profile.', style: AppTextStyles.muted),
            ),
            const _SectionLabel('Player'),
            DetailField(label: 'First name', controller: _firstName, accent: AppColors.playerAccent),
            DetailField(label: 'Last name', controller: _lastName, accent: AppColors.playerAccent),
            DetailField(label: 'Date of birth', controller: _dob, accent: AppColors.playerAccent),
            DetailField(label: 'Gender', controller: _gender, accent: AppColors.playerAccent),
            DetailField(label: 'Mobile', controller: _mobile, accent: AppColors.playerAccent, keyboardType: TextInputType.phone),
            DetailField(label: 'Emergency', controller: _emergency, accent: AppColors.playerAccent, keyboardType: TextInputType.phone),
            const _SectionLabel('Guardian'),
            DetailField(label: 'Guardian name', controller: _guardian, accent: AppColors.playerAccent),
            DetailField(label: 'Guardian mobile', controller: _guardianMobile, accent: AppColors.playerAccent, keyboardType: TextInputType.phone),
            const _SectionLabel('Playing'),
            DetailField(label: 'Position', controller: _position, accent: AppColors.playerAccent),
            DetailField(label: 'Preferred foot', controller: _foot, accent: AppColors.playerAccent),
            DetailField(label: 'School', controller: _school, accent: AppColors.playerAccent),
            DetailField(label: 'Class', controller: _schoolClass, accent: AppColors.playerAccent),
            DetailField(label: 'Jersey', controller: _jersey, accent: AppColors.playerAccent, keyboardType: TextInputType.number),
            const _SectionLabel('Medical'),
            DetailField(label: 'Blood group', controller: _blood, accent: AppColors.playerAccent),
            DetailField(label: 'Allergies', controller: _allergies, accent: AppColors.playerAccent, maxLines: 2),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.playerAccent,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save details', style: TextStyle(fontWeight: FontWeight.w700)),
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
