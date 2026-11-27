import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/appointments/models/appointment_conflict_model.dart';
import 'package:tendryn/routes/app_routes.dart';

class AppointmentConflictsController extends GetxController {
  final RxList<AppointmentConflictItem> conflicts = <AppointmentConflictItem>[
    const AppointmentConflictItem(
      id: 'conf-1',
      time: '14:30',
      practitioner: 'Dr Thandi Maseko',
      date: 'Tuesday 29 September 2026',
      badgeText: 'Double booking',
      patient1Name: 'Peter Jacobs',
      patient1Type: 'Consultation',
      patient2Name: 'Nomsa Dube',
      patient2Type: 'Follow-up',
    ),
    const AppointmentConflictItem(
      id: 'conf-2',
      time: '14:30',
      practitioner: 'Dr Thandi Maseko',
      date: 'Tuesday 29 September 2026',
      badgeText: 'Double booking',
      patient1Name: 'Peter Jacobs',
      patient1Type: 'Consultation',
      patient2Name: 'Nomsa Dube',
      patient2Type: 'Follow-up',
    ),
    const AppointmentConflictItem(
      id: 'conf-3',
      time: '14:30',
      practitioner: 'Dr Thandi Maseko',
      date: 'Tuesday 29 September 2026',
      badgeText: 'Double booking',
      patient1Name: 'Peter Jacobs',
      patient1Type: 'Consultation',
      patient2Name: 'Nomsa Dube',
      patient2Type: 'Follow-up',
    ),
  ].obs;

  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.dashboard);
    }
  }

  void onViewAppointments(AppointmentConflictItem conflict) {
    Get.toNamed(AppRoutes.appointments);
  }

  void onResolve([AppointmentConflictItem? conflict, BuildContext? context]) {
    AppNotice.unavailable('Resolve Conflict', 'Page is not available');
  }
}
