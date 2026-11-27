import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/widgets/appointments_desktop.dart';
import 'package:tendryn/features/appointments/widgets/appointments_mobile.dart';
import 'package:tendryn/features/appointments/widgets/appointments_tablet.dart';
import 'package:tendryn/features/appointments/widgets/doctor_appointments.dart';

/// Appointments inside the navigation shell (the shell supplies the sidebar /
/// bottom bar with Appointments selected). Doctors get their own day list;
/// every other role keeps the reception schedule.
class AppointmentsView extends GetView<AppointmentsController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    const receptionist = ResponsiveLayout(
      mobile: AppointmentsMobile(),
      tablet: AppointmentsTablet(),
      desktop: AppointmentsDesktop(),
    );
    const doctor = ResponsiveLayout(
      mobile: DoctorAppointmentsMobile(),
      tablet: DoctorAppointmentsTablet(),
      desktop: DoctorAppointmentsDesktop(),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Get.isRegistered<RoleController>()
          ? Obx(() => RoleController.to.currentRole.value == ClinicRole.doctor ? doctor : receptionist)
          : receptionist,
    );
  }
}
