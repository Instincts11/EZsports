import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_icons.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/brand_mark.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const BrandMark(),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppStrings.appName, style: AppTextStyles.brandTitle),
              Text(AppStrings.academyName, style: AppTextStyles.academySubtitle),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(AppIcons.calendar, color: AppColors.cardBeige),
        ),
      ],
    );
  }
}
