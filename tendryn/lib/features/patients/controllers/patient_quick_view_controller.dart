import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Controller for Patient Quick View logic and actions across all screen sizes.
class PatientQuickViewController extends GetxController {
  PatientQuickViewController({
    PatientQuickViewModel? initialPatient,
    bool startInAssignMode = false,
    String? returnRoute,
  }) : patient = (initialPatient ?? PatientQuickViewModel.thaboNkosi).obs,
       isAssignMode = startInAssignMode.obs,
       isDropdownVisible = startInAssignMode.obs,
       returnRoute = returnRoute ?? AppRoutes.dashboard {
    final initialPractitioner = initialPatient?.practitioner;
    selectedPractitioner = (initialPractitioner != null && practitioners.contains(initialPractitioner)
            ? initialPractitioner
            : practitioners.first)
        .obs;
  }

  final String returnRoute;
  final Rx<PatientQuickViewModel> patient;
  final RxInt selectedNavIndex = 0.obs;

  final RxBool isAssignMode;
  final RxBool isDropdownVisible;
  final RxBool isDropdownOpen = false.obs;
  
  final List<String> practitioners = [
    'Not assigned',
    'Dr Thandi Maseko',
    'Dr Sipho Khumalo',
    'Nurse Z. Mthembu',
  ];
  late final RxString selectedPractitioner;

  /// Keeps the assign dropdown on screen on short tablet viewports, where the
  /// header chrome leaves little room above the fold.
  final ScrollController scrollController = ScrollController();
  final GlobalKey assignKey = GlobalKey();

  @override
  void onReady() {
    super.onReady();
    if (isDropdownVisible.value) _revealAssign();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _revealAssign() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = assignKey.currentContext;
      if (ctx == null || !scrollController.hasClients) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(returnRoute);
    }
  }


  void manageQueue() {
    try {
      Get.toNamed(AppRoutes.queue);
    } catch (_) {
      Get.snackbar(
        'Queue',
        'Navigating to Queue destination',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void toggleDropdown() {
    isDropdownOpen.value = !isDropdownOpen.value;
    update();
    if (isDropdownOpen.value) _revealAssign();
  }

  void selectPractitioner(String practitioner) {
    selectedPractitioner.value = practitioner;
    isDropdownOpen.value = false;
    update();
  }

  void startAssignment() {
    isDropdownVisible.value = true;
    _revealAssign();
  }

  void saveAssignment() {
    // Update local patient model with selected practitioner
    patient.value = patient.value.copyWith(
      practitioner: selectedPractitioner.value,
    );
    // If QueueController is registered, reflect updated practitioner in queue table
    if (Get.isRegistered<QueueController>()) {
      Get.find<QueueController>().updatePractitioner(
        patient.value.queueNumber,
        selectedPractitioner.value,
      );
    }
    // Navigate back to origin route (Queue or Dashboard)
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(returnRoute);
    }
  }

  void addToQueue() {
    Get.snackbar(
      'Add to Queue',
      'Adding to queue...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void onNavSelected(int index) {
    selectedNavIndex.value = index;
    if (index == 0) {
      onBack();
    } else if (index == 1) {
      manageQueue();
    }
  }
}
