import 'package:flutter/material.dart';
import 'package:edu_prep_academy/core/theme/app_text_style.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final Widget? prefix;
  final bool obscureText;
  final int? maxLength;
  final String? label;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.obscureText = false,
    this.maxLength,
    this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ---------------- LABEL ----------------
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],

        /// ---------------- INPUT ----------------
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium(context),
          decoration: InputDecoration(
            counterText: "",
            hintText: hintText,
            prefixIcon: prefix,

            // ✅ theme-driven colors
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant,
            hintStyle: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: theme.colorScheme.onSurfaceVariant),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
