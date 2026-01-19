import 'package:flutter/material.dart';
import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/core/theme/app_text_style.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const DashboardCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    /// Gradient mapping (business logic – OK to keep colors here)
    final Map<String, List<Color>> gradients = {
      "Notes": [AppColors.primaryBlue, AppColors.accentOrange],
      "Mock Tests": [AppColors.accentOrange, AppColors.primaryBlue],
      "Video Classes": [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
      "Results": [AppColors.successGreen, AppColors.infoBlue],
    };

    final gradientColors =
        gradients[title] ?? [AppColors.primaryBlue, AppColors.accentOrange];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // TODO: Navigate to respective module
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Icon badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),

              const SizedBox(height: 14),

              /// Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
