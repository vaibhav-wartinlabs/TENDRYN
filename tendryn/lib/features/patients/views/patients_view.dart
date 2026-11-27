import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/widgets/patients_desktop.dart';
import 'package:tendryn/features/patients/widgets/patients_mobile.dart';
import 'package:tendryn/features/patients/widgets/patients_tablet.dart';

/// Patients directory inside the navigation shell (the shell supplies the
/// sidebar / bottom bar with Patients selected).
class PatientsView extends GetView<PatientsController> {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveLayout(
        mobile: PatientsMobile(),
        tablet: PatientsTablet(),
        desktop: PatientsDesktop(),
      ),
    );
  }
}
