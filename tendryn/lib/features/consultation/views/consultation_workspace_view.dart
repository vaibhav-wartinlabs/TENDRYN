import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/features/consultation/views/clinical_consultation_view.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/routes/route_names.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// Full-page consultation workspace with the shared app chrome.
class ConsultationWorkspaceView extends StatelessWidget {
  const ConsultationWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    String returnRoute = AppRoutes.consultations;
    PatientRecord? patient;
    String? status;

    final args = Get.arguments;
    if (args is String) {
      returnRoute = args;
    } else if (args is Map) {
      if (args['returnRoute'] is String) {
        returnRoute = args['returnRoute'] as String;
      }
      if (args['patient'] is PatientRecord) {
        patient = args['patient'] as PatientRecord;
      }
      if (args['status'] is String) {
        status = args['status'] as String;
      }
    }

    final returnName = RouteNames.titleOf(returnRoute);

    return AppShell(
      route: AppRoutes.consultations,
      hideBottomNavigation: true,
      child: ClinicalConsultationView(
        patient: patient,
        statusLabel: status,
        onBack: () => AppNavigation.goTo(returnRoute),
        backLabel: returnName.isEmpty ? 'Back' : 'Back to $returnName',
      ),
    );
  }
}
