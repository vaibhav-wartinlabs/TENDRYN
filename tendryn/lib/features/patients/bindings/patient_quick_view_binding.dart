import 'package:get/get.dart';
import 'package:tendryn/features/dashboard/bindings/dashboard_binding.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/patients/controllers/patient_quick_view_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/routes/app_routes.dart';

class PatientQuickViewBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DashboardController>()) {
      DashboardBinding().dependencies();
    }
    final args = Get.arguments as Map<String, dynamic>?;
    final assignMode = args?['assignMode'] == true;
    final returnRoute = args?['returnRoute'] as String? ?? AppRoutes.dashboard;
    final patient = args?['patient'] as PatientQuickViewModel?;
    
    Get.lazyPut<PatientQuickViewController>(() => PatientQuickViewController(
      initialPatient: patient,
      startInAssignMode: assignMode,
      returnRoute: returnRoute,
    ));
  }
}
