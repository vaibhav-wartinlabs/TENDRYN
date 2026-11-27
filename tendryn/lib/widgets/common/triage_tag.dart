import 'package:flutter/material.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/widgets/common/status_pill.dart';

/// South African Triage Scale urgency. Keep system-controlled: never replace
/// with clinic branding.
enum TriageLevel {
  red('Red · emergency', AppColors.triageRed),
  orange('Orange · very urgent', AppColors.triageOrange),
  yellow('Yellow · urgent', AppColors.triageYellow),
  green('Green · routine', AppColors.triageGreen);

  const TriageLevel(this.label, this.color);

  final String label;
  final Color color;
}

/// Read-only SATS urgency tag (colour + text, never colour alone).
class TriageTag extends StatelessWidget {
  const TriageTag({super.key, required this.level, this.label});

  final TriageLevel level;
  final String? label;

  @override
  Widget build(BuildContext context) => StatusPill(color: level.color, label: label ?? level.label);
}
