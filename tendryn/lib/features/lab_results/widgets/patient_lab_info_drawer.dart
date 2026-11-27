import 'package:flutter/material.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/views/patient_lab_info_view.dart';

/// Redirects legacy drawer calls to the unified full-page [PatientLabInfoView].
void showPatientLabInfoDrawer(
  BuildContext context, {
  required LabReferralModel referral,
}) {
  openPatientLabInfoPage(context, referral: referral);
}
