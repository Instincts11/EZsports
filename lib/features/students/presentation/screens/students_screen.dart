import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_sizes.dart';
import 'package:ezsports/core/constants/app_strings.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/cream_card.dart';
import 'package:ezsports/features/students/data/models/batch_model.dart';
import 'package:ezsports/features/students/presentation/widgets/batch_directory_card.dart';
import 'package:ezsports/features/students/providers/students_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BatchModel> batches = ref.watch(demoBatchesProvider);
    final int totalPlayers = batches.fold(0, (int sum, BatchModel batch) => sum + batch.studentCount);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 28),
        children: <Widget>[
          const Text(AppStrings.batches, style: AppTextStyles.pageTitle),
          const SizedBox(height: 6),
          Text(
            '$totalPlayers ${AppStrings.playersAcrossGroups} ${batches.length} ${AppStrings.groups}',
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 20),
          ...batches.map(
            (BatchModel batch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BatchDirectoryCard(
                batch: batch,
                onOpenRoster: () => context.go('/batches/${batch.batchId}'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Pitch load today', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              children: <Widget>[
                _PitchLoadRow(pitch: 'Pitch A', time: '10:00–12:00', batch: 'Summer Camp', filled: 17, capacity: 20),
                SizedBox(height: 16),
                _PitchLoadRow(pitch: 'Pitch B', time: '3:30–5:00', batch: 'Weekend Evening', filled: 15, capacity: 18),
                SizedBox(height: 16),
                _PitchLoadRow(pitch: 'Pitch B', time: '7:00–9:00', batch: 'Weekend Morning', filled: 107, capacity: 120),
                SizedBox(height: 16),
                _PitchLoadRow(pitch: 'Pitch A', time: '4:00–6:00', batch: 'Weekday Evening', filled: 4, capacity: 16),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Notes', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Weekend Morning is near capacity', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text(
                  '107 of 120 places filled. Hold new sign-ups for a second pitch before next Sunday.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Weekday Evening has room', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('4 of 16 places filled. Mon Wed Fri, 4:00 PM, Pitch A.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Weekend Morning waitlist', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Six names are waiting. Do not add anyone until a second pitch is confirmed for Sunday mornings.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cover if you are late', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Anju starts the rondo for whichever group is on the pitch. She does not mark attendance. That stays with you.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Next week stays on the same pitches', style: AppTextStyles.title),
                SizedBox(height: 6),
                Text('Sunday 13 evening remains Pitch B. Summer Camp stays on Pitch A. Tell the desk before Friday if a group needs to move.', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text('4 groups · Esperanza Football Academy', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

class _PitchLoadRow extends StatelessWidget {
  const _PitchLoadRow({
    required this.pitch,
    required this.time,
    required this.batch,
    required this.filled,
    required this.capacity,
  });

  final String pitch;
  final String time;
  final String batch;
  final int filled;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(pitch, style: AppTextStyles.title),
            const Spacer(),
            Text('$filled/$capacity', style: AppTextStyles.title),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: <Widget>[
            Text(time, style: AppTextStyles.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(batch, textAlign: TextAlign.right, style: AppTextStyles.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: filled / capacity,
            minHeight: 6,
            backgroundColor: const Color(0xFFE7D3C4),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
