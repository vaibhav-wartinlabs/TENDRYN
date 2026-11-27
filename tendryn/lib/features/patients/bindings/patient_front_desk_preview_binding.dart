import 'package:get/get.dart';
import 'package:tendryn/features/patients/controllers/patient_front_desk_preview_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';

class PatientFrontDeskPreviewBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final patient = args?['patient'] as PatientQuickViewModel?;
    final returnRoute = args?['returnRoute'] as String?;

    Get.lazyPut<PatientFrontDeskPreviewController>(
      () => PatientFrontDeskPreviewController(
        initialPatient: patient,
        returnRoute: returnRoute,
      ),
    );
  }
}
