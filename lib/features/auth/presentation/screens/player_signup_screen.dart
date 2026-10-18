import 'package:dio/dio.dart';
import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/coach_search_field.dart';
import 'package:ezsports/core/widgets/detail_field.dart';
import 'package:ezsports/features/auth/data/models/otp_request_model.dart';
import 'package:ezsports/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayerSignupScreen extends ConsumerStatefulWidget {
  const PlayerSignupScreen({super.key});

  @override
  ConsumerState<PlayerSignupScreen> createState() => _PlayerSignupScreenState();
}

class _PlayerSignupScreenState extends ConsumerState<PlayerSignupScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
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
  bool _loading = false;

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _email,
      _password,
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

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty ||
        _password.text.trim().isEmpty ||
        _firstName.text.trim().isEmpty ||
        _mobile.text.trim().isEmpty ||
        _guardian.text.trim().isEmpty ||
        _guardianMobile.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill email, password, player name, mobile, and guardian contact.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final OtpRequestModel result = await ref.read(authRepositoryProvider).requestSignupOtp(
        <String, dynamic>{
          'email': _email.text.trim(),
          'password': _password.text.trim(),
          'first_name': _firstName.text.trim(),
          'last_name': _lastName.text.trim(),
          'dob': _dob.text.trim().isEmpty ? null : _dob.text.trim(),
          'gender': _gender.text.trim().isEmpty ? null : _gender.text.trim(),
          'mobile': _mobile.text.trim(),
          'emergency_contact': _emergency.text.trim().isEmpty ? null : _emergency.text.trim(),
          'guardian_name': _guardian.text.trim(),
          'guardian_mobile': _guardianMobile.text.trim(),
          'position': _position.text.trim().isEmpty ? null : _position.text.trim(),
          'preferred_foot': _foot.text.trim().isEmpty ? null : _foot.text.trim(),
          'school': _school.text.trim().isEmpty ? null : _school.text.trim(),
          'school_class': _schoolClass.text.trim().isEmpty ? null : _schoolClass.text.trim(),
          'jersey': _jersey.text.trim().isEmpty ? null : _jersey.text.trim(),
          'blood_group': _blood.text.trim().isEmpty ? null : _blood.text.trim(),
          'allergies': _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
        },
      );
      if (!mounted) {
        return;
      }
      context.push(
        '/signup/otp',
        extra: <String, String>{
          'mobile': result.mobile,
        },
      );
    } on DioException catch (error) {
      final Object? detail = error.response?.data is Map<String, dynamic>
          ? (error.response!.data as Map<String, dynamic>)['detail']
          : null;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail?.toString() ?? 'Could not send OTP. Is the API running?')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
                  onPressed: () => context.go('/login'),
                  icon: const Icon(AppIcons.back, color: AppColors.playerAccent),
                ),
                const Expanded(
                  child: Text(AppStrings.playerSignUpTitle, style: AppTextStyles.pageTitle),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 18),
              child: Text(AppStrings.playerSignUpSubtitle, style: AppTextStyles.muted),
            ),
            CoachSearchField(hint: AppStrings.email, controller: _email, showSearchIcon: false),
            const SizedBox(height: 12),
            CoachSearchField(
              hint: AppStrings.password,
              controller: _password,
              showSearchIcon: false,
              obscureText: true,
            ),
            const SizedBox(height: 18),
            DetailField(label: AppStrings.firstName, controller: _firstName, accent: AppColors.playerAccent),
            DetailField(label: AppStrings.lastName, controller: _lastName, accent: AppColors.playerAccent),
            DetailField(label: AppStrings.dob, controller: _dob, accent: AppColors.playerAccent),
            DetailField(label: AppStrings.gender, controller: _gender, accent: AppColors.playerAccent),
            DetailField(
              label: AppStrings.mobile,
              controller: _mobile,
              accent: AppColors.playerAccent,
              keyboardType: TextInputType.phone,
            ),
            DetailField(
              label: AppStrings.emergency,
              controller: _emergency,
              accent: AppColors.playerAccent,
              keyboardType: TextInputType.phone,
            ),
            DetailField(label: AppStrings.guardianName, controller: _guardian, accent: AppColors.playerAccent),
            DetailField(
              label: AppStrings.guardianMobile,
              controller: _guardianMobile,
              accent: AppColors.playerAccent,
              keyboardType: TextInputType.phone,
            ),
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
            DetailField(label: 'Blood group', controller: _blood, accent: AppColors.playerAccent),
            DetailField(label: 'Allergies', controller: _allergies, accent: AppColors.playerAccent, maxLines: 2),
            const SizedBox(height: 12),
            AppButton(
              label: _loading ? 'Sending…' : AppStrings.sendOtp,
              backgroundColor: AppColors.playerAccent,
              onPressed: () {
                if (!_loading) {
                  _submit();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
