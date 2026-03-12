import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final bool outlined;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.outlined = false,
    this.trailingIcon,
    this.leadingIcon,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = textColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: outlined ? Colors.transparent : bg,
        borderRadius: AppRadius.buttonRadius,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: AppRadius.buttonRadius,
          child: Container(
            decoration: outlined
                ? BoxDecoration(
                    border: Border.all(color: bg),
                    borderRadius: AppRadius.buttonRadius,
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                else ...[
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, color: fg, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(color: fg),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, color: fg, size: 18),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
