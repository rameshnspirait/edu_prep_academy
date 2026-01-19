import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // ================== HEADINGS ==================

  /// AppBar titles, screen headers
  static TextStyle headingLarge(BuildContext context) => Theme.of(context)
      .textTheme
      .titleLarge!
      .copyWith(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.2);

  /// Section titles (Results, Analytics headers)
  static TextStyle headingMedium(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.15);

  /// Card titles (Test name, video title)
  static TextStyle headingSmall(BuildContext context) => Theme.of(context)
      .textTheme
      .titleSmall!
      .copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1);

  // ================== BODY ==================

  /// Main content text
  static TextStyle bodyLarge(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyLarge!.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500);

  /// Default body text (MOST USED)
  static TextStyle bodyMedium(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  /// Secondary / metadata text
  static TextStyle bodySmall(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodySmall!.copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  // ================== BUTTON ==================

  static TextStyle button(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.4);

  // ================== CAPTION ==================

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).hintColor,
      );
}
