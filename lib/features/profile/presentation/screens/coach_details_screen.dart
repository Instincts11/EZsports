import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/core/widgets/detail_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachDetailsScreen extends StatefulWidget {
  const CoachDetailsScreen({super.key});

  @override
  State<CoachDetailsScreen> createState() => _CoachDetailsScreenState();
}

class _CoachDetailsScreenState extends State<CoachDetailsScreen> {
  final TextEditingController _firstName = TextEditingController(text: 'R.');
  final TextEditingController _lastName = TextEditingController(text: 'Nair');
  final TextEditingController _role = TextEditingController(text: 'Head coach');
  final TextEditingController _academy = TextEditingController(text: AppStrings.academyName);
  final TextEditingController _since = TextEditingController(text: 'Jan 2022');
  final TextEditingController _mobile = TextEditingController(text: '+91 98460 11820');
  final TextEditingController _email = TextEditingController(text: 'rnair@esperanza.academy');
  final TextEditingController _note = TextEditingController(
    text: 'On the pitch from 6:40 AM. Mark Weekend Evening attendance before leaving.',
  );

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _role.dispose();
    _academy.dispose();
    _since.dispose();
    _mobile.dispose();
    _email.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final String name = '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
    if (_firstName.text.trim().isEmpty || _mobile.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name and mobile number before saving.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved coach details for $name')),
    );
    context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text('Enter the details shown on your profile.', style: AppTextStyles.muted),
            ),
            DetailField(label: 'First name', controller: _firstName),
            DetailField(label: 'Last name', controller: _lastName),
            DetailField(label: 'Role', controller: _role),
            DetailField(label: 'Academy', controller: _academy),
            DetailField(label: 'Coaching since', controller: _since),
            DetailField(label: 'Mobile', controller: _mobile, keyboardType: TextInputType.phone),
            DetailField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
            DetailField(label: 'Note for the desk', controller: _note, maxLines: 3),
            const SizedBox(height: 8),
            AppButton(label: 'Save details', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
