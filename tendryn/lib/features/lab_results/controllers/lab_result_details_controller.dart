import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/lab_results/controllers/lab_results_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/models/lab_result_model.dart';
import 'package:tendryn/features/lab_results/widgets/lab_referral_details_drawer.dart';
import 'package:tendryn/features/lab_results/widgets/lab_result_drawer.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/routes/app_routes.dart';

class LabResultDetailsController extends GetxController {
  late final Rx<LabResultModel> result;
  final RxInt selectedAttachmentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is LabResultModel) {
      result = args.obs;
    } else if (Get.isRegistered<LabResultsController>() &&
        Get.find<LabResultsController>().results.isNotEmpty) {
      result = Get.find<LabResultsController>().results.first.obs;
    } else {
      result = LabResultModel(
        id: 'LR-001',
        patientName: 'John Smith',
        folderNumber: 'SWC-10427',
        testName: 'Full blood count',
        category: 'Hematology',
        resultReceivedDate: '12 Oct 2026 · 10:15',
        sampleCollectedDate: '11 Oct 2026 · 14:30',
        orderingDoctor: 'Dr. Maya Naidoo',
        laboratory: 'Soweto NHLS Laboratory',
        status: LabReviewStatus.awaitingReview,
        idNumber: '740312 5021 087',
        age: '52',
        gender: 'Male',
        dob: '12 Mar 1974',
        allergies: 'Penicillin (anaphylaxis)',
        relatedReferral: 'Lab referral · 08 Oct 2026',
        attachmentsCount: 2,
        parameters: const [],
      ).obs;
    }
  }

  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.labResults);
    }
  }

  void onViewPatientProfile() {
    PatientRecord? targetPatient;
    if (Get.isRegistered<PatientsController>()) {
      final patientsCtrl = Get.find<PatientsController>();
      targetPatient = patientsCtrl.patients.firstWhereOrNull(
        (p) =>
            p.name.toLowerCase() == result.value.patientName.toLowerCase() ||
            p.fileNumber.toLowerCase().contains(
                  result.value.folderNumber.replaceAll('#', '').toLowerCase(),
                ),
      );
    }
    Get.toNamed(
      AppRoutes.patientDetails,
      arguments: targetPatient ?? PatientsController.seed.first,
    );
  }

  void onViewReferral([BuildContext? context]) {
    final ctx = context ?? Get.context;
    if (ctx != null) {
      showLabReferralDetails(
        ctx,
        referral: LabReferralModel(
          id: 'ref-related',
          patientName: result.value.patientName,
          folderNumber: result.value.folderNumber,
          testsRequested: result.value.testName,
          referralDate: '08 Oct 2026',
          status: LabReferralStatus.resultReceived,
        ),
      );
    }
  }

  void onRecordReview(BuildContext context) {
    showLabResultDrawer(
      context,
      result: result.value,
      initialTabIndex: 1,
      onReviewed: (updatedResult) {
        result.value = updatedResult;
      },
    );
  }

  void selectAttachment(int index) {
    selectedAttachmentIndex.value = index;
  }

  void onRetryDocumentLoad() {
    AppNotice.info('Retrying', 'Reloading document...');
  }
}
