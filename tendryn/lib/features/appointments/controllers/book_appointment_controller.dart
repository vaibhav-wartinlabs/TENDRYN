import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/queue/models/walk_in_patient.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Controller for the Book Appointment flow across Mobile, Tablet, and Desktop Drawer.
class BookAppointmentController extends GetxController {
  BookAppointmentController({
    String? returnRoute,
    WalkInPatient? initialPatient,
    PatientQuickViewModel? initialQuickPatient,
    DateTime? initialDate,
    String? initialSlot,
    String? initialPractitioner,
  }) : returnRoute = returnRoute ?? AppRoutes.dashboard {
    if (initialDate != null) {
      selectedDate.value = initialDate;
      calendarMonth.value = DateTime(initialDate.year, initialDate.month, 1);
    }
    if (initialSlot != null) {
      selectedSlot.value = initialSlot;
    }
    if (initialPractitioner != null && (practitioners.contains(initialPractitioner) || initialPractitioner.isNotEmpty)) {
      selectedPractitioner.value = initialPractitioner;
    }
    if (initialPatient != null) {
      selectedPatient.value = initialPatient;
      searchText.text = initialPatient.name;
      searchQuery.value = initialPatient.name;
    } else if (initialQuickPatient != null) {
      final p = WalkInPatient(
        name: initialQuickPatient.name,
        fileNumber: initialQuickPatient.fileNumber.replaceAll('#', '').trim(),
        dateOfBirth: initialQuickPatient.dobAndAge.split('·').first.trim(),
        phone: initialQuickPatient.phone,
      );
      selectedPatient.value = p;
      searchText.text = p.name;
      searchQuery.value = p.name;
    }
  }

  final String returnRoute;

  static const mockPatients = [
    WalkInPatient(
      name: 'Thabo Nkosi',
      fileNumber: 'PT-002184',
      dateOfBirth: '12 Mar 1982',
      phone: '082 ••• ••42',
    ),
    WalkInPatient(
      name: 'Thabo Mokoena',
      fileNumber: 'PT-003011',
      dateOfBirth: '04 Nov 1976',
      phone: '071 ••• ••91',
    ),
    WalkInPatient(
      name: 'Lindiwe Ndlovu',
      fileNumber: 'PT-001746',
      dateOfBirth: '20 Jul 1988',
      phone: '083 ••• ••18',
    ),
    WalkInPatient(
      name: 'Sipho Dlamini',
      fileNumber: 'PT-002490',
      dateOfBirth: '15 Sep 1990',
      phone: '082 ••• ••11',
    ),
    WalkInPatient(
      name: 'Amahle Khumalo',
      fileNumber: 'PT-001923',
      dateOfBirth: '03 Feb 1985',
      phone: '073 ••• ••55',
    ),
  ];

  static const practitioners = [
    'Dr Thandi Maseko',
    'Dr Sipho Khumalo',
    'Nurse Z. Mthembu',
  ];

  static const allSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '12:00',
    '14:00',
    '14:30',
  ];

  static const unavailableSlots = {'12:00', '14:00'};

  static const visitTypes = ['Consultation', 'Follow-up'];

  // Search & Patient
  final searchText = TextEditingController();
  final searchQuery = ''.obs;
  final selectedPatient = Rxn<WalkInPatient>();
  final isSearchFocused = false.obs;

  // Practitioner
  final selectedPractitioner = 'Select Practitioner'.obs;
  final isPractitionerExpanded = false.obs;

  // Date & Calendar
  final selectedDate = DateTime(2026, 9, 29).obs;
  final calendarMonth = DateTime(2026, 9, 1).obs;
  final isDateExpanded = true.obs;

  // Slots & Type & Notes
  final selectedSlot = '14:30'.obs;
  final selectedVisitType = 'Consultation'.obs;
  final notesController = TextEditingController();

  // Conflict dialog
  final showConflict = false.obs;
  final conflictPractitioner = ''.obs;
  final conflictSlot = ''.obs;

  /// Patients matching query
  List<WalkInPatient> get filteredPatients {
    final query = searchQuery.value.trim().toLowerCase();
    final all = <WalkInPatient>[...mockPatients];

    if (Get.isRegistered<PatientsController>()) {
      final dir = Get.find<PatientsController>();
      for (final p in dir.patients) {
        if (!all.any((existing) => existing.fileNumber == p.fileNumber)) {
          all.add(WalkInPatient(
            name: p.name,
            fileNumber: p.fileNumber,
            dateOfBirth: p.dateOfBirth,
            phone: p.mobile,
          ));
        }
      }
    }

    if (query.isEmpty) return all;
    return all.where((p) =>
      p.name.toLowerCase().contains(query) ||
      p.fileNumber.toLowerCase().contains(query) ||
      (p.phone?.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  void search(String text) {
    searchQuery.value = text;
    if (selectedPatient.value != null && text.trim() != selectedPatient.value!.name) {
      selectedPatient.value = null;
    }
  }

  void clearSearch() {
    searchText.clear();
    searchQuery.value = '';
    selectedPatient.value = null;
  }

  void selectPatient(WalkInPatient patient) {
    selectedPatient.value = patient;
    searchText.text = patient.name;
    searchQuery.value = patient.name;
  }

  void togglePractitioner() {
    isPractitionerExpanded.value = !isPractitionerExpanded.value;
  }

  void selectPractitioner(String practitioner) {
    selectedPractitioner.value = practitioner;
    isPractitionerExpanded.value = false;
  }

  void toggleDate() {
    isDateExpanded.value = !isDateExpanded.value;
  }

  void previousMonth() {
    calendarMonth.value = DateTime(
      calendarMonth.value.year,
      calendarMonth.value.month - 1,
      1,
    );
  }

  void nextMonth() {
    calendarMonth.value = DateTime(
      calendarMonth.value.year,
      calendarMonth.value.month + 1,
      1,
    );
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectSlot(String slot) {
    if (unavailableSlots.contains(slot)) return;
    selectedSlot.value = slot;
  }

  void selectVisitType(String type) {
    selectedVisitType.value = type;
  }

  Future<void> onRegisterNewPatient() async {
    try {
      final result = await Get.toNamed(
        AppRoutes.registerPatient,
        arguments: {'returnRoute': returnRoute, 'backLabel': 'Back to Book Appointment'},
      );
      if (result is PatientRecord) {
        final newPatient = WalkInPatient(
          name: result.name,
          fileNumber: result.fileNumber,
          dateOfBirth: result.dateOfBirth,
          phone: result.mobile,
        );
        selectPatient(newPatient);
      }
    } catch (_) {
      // In isolated tests where route table is omitted
    }
  }

  void cancel() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(returnRoute);
    }
  }

  void bookAppointment() {
    // If no patient selected yet, fallback to default patient for demo
    selectedPatient.value ??= mockPatients.first;

    // DEMO: always show conflict dialog on every slot/date
    conflictPractitioner.value =
        selectedPractitioner.value == 'Select Practitioner'
            ? 'Dr Thandi Maseko'
            : selectedPractitioner.value;
    conflictSlot.value = selectedSlot.value.isNotEmpty ? selectedSlot.value : '14:30';
    showConflict.value = true;
  }

  void dismissConflict() {
    showConflict.value = false;
  }

  void bookAnyway() {
    showConflict.value = false;
    _confirmBook();
  }

  void chooseAnotherTime() {
    showConflict.value = false;
    // Clear the conflicting slot so user must pick another
    selectedSlot.value = '';
  }

  void _confirmBook() {
    final formattedDate = Formatters.longDate(selectedDate.value);
    Get.closeAllSnackbars();
    Get.snackbar(
      'Appointment Booked',
      'Appointment scheduled for ${selectedPatient.value!.name} with ${selectedPractitioner.value} on $formattedDate at ${selectedSlot.value}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.feedbackSuccessTint,
      colorText: AppColors.feedbackSuccess,
      duration: const Duration(seconds: 3),
    );

    cancel();
  }

  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _monthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
  static const _monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String get formattedSlotHeaderDate {
    final d = selectedDate.value;
    return '${_weekdays[d.weekday - 1]}, ${d.day} ${_monthsShort[d.month - 1]}';
  }

  String get formattedFullDate {
    return Formatters.longDate(selectedDate.value);
  }

  String get formattedCalendarMonth {
    final m = calendarMonth.value;
    return '${_monthsFull[m.month - 1]} ${m.year}';
  }

  @override
  void onClose() {
    searchText.dispose();
    notesController.dispose();
    super.onClose();
  }
}
