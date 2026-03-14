import 'package:flutter/material.dart';
import '../../../../parts/domain/models/part_model.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class CompatibilityChips extends StatelessWidget {
  final List<CompatibilityInfo> compatibility;

  const CompatibilityChips({super.key, required this.compatibility});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: compatibility.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput,
            border: Border.all(color: isDarkMode ? AppColorsDark.border : AppColorsLight.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 13,
                color: isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                '${c.make} ${c.model}  ${c.yearFrom}–${c.yearTo}',
                style: AppTextStyles.bodySm(isDarkMode),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
