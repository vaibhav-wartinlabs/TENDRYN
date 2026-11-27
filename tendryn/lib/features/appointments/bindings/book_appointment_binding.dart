import 'package:get/get.dart';
import 'package:tendryn/features/appointments/controllers/book_appointment_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/queue/models/walk_in_patient.dart';
import 'package:tendryn/routes/app_routes.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final returnRoute = args?['returnRoute'] as String? ?? AppRoutes.dashboard;
    final patient = args?['patient'];
    final date = args?['date'] as DateTime?;
    final slot = args?['slot'] as String?;
    final practitioner = args?['practitioner'] as String?;

    if (patient is WalkInPatient) {
      Get.lazyPut(() => BookAppointmentController(
            returnRoute: returnRoute,
            initialPatient: patient,
            initialDate: date,
            initialSlot: slot,
            initialPractitioner: practitioner,
          ));
    } else if (patient is PatientQuickViewModel) {
      Get.lazyPut(() => BookAppointmentController(
            returnRoute: returnRoute,
            initialQuickPatient: patient,
            initialDate: date,
            initialSlot: slot,
            initialPractitioner: practitioner,
          ));
    } else {
      Get.lazyPut(() => BookAppointmentController(
            returnRoute: returnRoute,
            initialDate: date,
            initialSlot: slot,
            initialPractitioner: practitioner,
          ));
    }
  }
}
