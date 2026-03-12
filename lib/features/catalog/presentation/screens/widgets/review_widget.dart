import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class ReviewWidget extends StatelessWidget {
  final String partId;

  const ReviewWidget({super.key, required this.partId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReviewCard(
          name: 'Rahul S.',
          stars: '★★★★★',
          review: 'Great quality, fits perfectly!',
          time: '3 days ago',
        ),
        _ReviewCard(
          name: 'Priya M.',
          stars: '★★★★☆',
          review: 'Good product, fast delivery.',
          time: '1 week ago',
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name, stars, review, time;

  const _ReviewCard({
    required this.name,
    required this.stars,
    required this.review,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyles.labelMd(isDarkMode)),
              Text(time, style: AppTextStyles.bodyXs(isDarkMode)),
            ],
          ),
          Text(
            stars,
            style: TextStyle(
              color: isDarkMode
                  ? AppColorsDark.warning
                  : AppColorsLight.warning,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review,
            style: AppTextStyles.bodyMd(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppColorsDark.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
