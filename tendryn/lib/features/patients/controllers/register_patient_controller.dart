import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';

/// Register Patient form state (validation is switched off for now), shared by the desktop and tablet single page
/// and the three-step phone flow. Values are kept across steps.
///
/// There is no patient-creation API yet: a valid registration is added to the
/// in-memory directory for this session only.
class RegisterPatientController extends GetxController {
  static const genders = ['Female', 'Male', 'Other'];

  /// Phone steps: 1 identity, 2 contact and next of kin, 3 health alerts and consent.
  static const stepCount = 3;
  static const stepTitles = ['Identity', 'Contact and Next of Kin', 'Health Alerts and POPIA Consent'];

  final step = 1.obs;

  final saId = TextEditingController();
  final passport = TextEditingController();
  final firstName = TextEditingController();
  final surname = TextEditingController();
  final dateOfBirth = Rxn<DateTime>();
  final gender = RxnString();

  final mobile = TextEditingController();
  final whatsApp = TextEditingController();
  final address = TextEditingController();
  final nextOfKin = TextEditingController();

  final allergies = TextEditingController();
  final chronic = TextEditingController();
  final popiaConsent = false.obs;
  final detailsVerified = false.obs;

  final isSubmitting = false.obs;

  String get dateOfBirthLabel => dateOfBirth.value == null ? '' : Formatters.shortDate(dateOfBirth.value!).padLeft(11, '0');

  void pickDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
  }

  void pickGender(String value) {
    gender.value = value;
  }

  /// Fills date of birth and gender from a complete, valid SA ID number.
  void onSaIdChanged(String value) {
    final id = value.trim();
    if (!_validSaId(id)) return;
    final yy = int.parse(id.substring(0, 2));
    final year = yy > DateTime.now().year % 100 ? 1900 + yy : 2000 + yy;
    dateOfBirth.value = DateTime(year, int.parse(id.substring(2, 4)), int.parse(id.substring(4, 6)));
    gender.value = int.parse(id.substring(6, 10)) >= 5000 ? 'Male' : 'Female';
  }

  /// 13 digits, a real date and a correct Luhn check digit.
  static bool _validSaId(String id) {
    if (!RegExp(r'^\d{13}$').hasMatch(id)) return false;
    final month = int.parse(id.substring(2, 4));
    final day = int.parse(id.substring(4, 6));
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    var sum = 0;
    for (var i = 0; i < 13; i++) {
      var d = int.parse(id[i]);
      if (i.isOdd) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
    }
    return sum % 10 == 0;
  }

  /// Phone: next step or, on the last, register.
  void next() {
    if (step.value < stepCount) {
      step.value++;
    } else {
      register();
    }
  }

  /// Phone header back: the previous step, or leave the flow from step 1.
  void back() => step.value > 1 ? step.value-- : cancel();

  String get backLabel {
    final args = Get.arguments;
    if (args is Map && args['backLabel'] is String) {
      return args['backLabel'] as String;
    }
    return 'Back to Patients';
  }

  /// Adds the patient to the directory (no validation for now).
  void register() {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    final directory = Get.find<PatientsController>();
    final next = directory.patients.map((p) => int.tryParse(p.fileNumber.replaceAll(RegExp(r'\D'), '')) ?? 0).fold(0, (a, b) => a > b ? a : b) + 1;
    final newPatient = PatientRecord(
      name: '${firstName.text.trim()} ${surname.text.trim()}'.trim().isEmpty ? 'Unnamed patient' : '${firstName.text.trim()} ${surname.text.trim()}'.trim(),
      fileNumber: 'PT-${next.toString().padLeft(6, '0')}',
      dateOfBirth: dateOfBirthLabel.isEmpty ? '—' : dateOfBirthLabel,
      mobile: mobile.text.trim().isEmpty ? '—' : mobile.text.trim(),
      lastVisit: '—',
      address: address.text.trim().isEmpty ? '—' : address.text.trim(),
      nextOfKin: nextOfKin.text.trim().isEmpty ? 'Not recorded' : nextOfKin.text.trim(),
      whatsApp: whatsApp.text.trim().isEmpty ? null : whatsApp.text.trim(),
    );
    directory.addPatient(newPatient);
    Get.back(result: newPatient);
    Get.snackbar('Register Patient', 'Patient added to this device’s directory.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    isSubmitting.value = false;
  }

  /// Back to the previous page or Patients directory.
  void cancel() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      final args = Get.arguments;
      if (args is Map && args['returnRoute'] is String) {
        Get.offNamed(args['returnRoute'] as String);
      } else {
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    for (final c in [saId, passport, firstName, surname, mobile, whatsApp, address, nextOfKin, allergies, chronic]) {
      c.dispose();
    }
    super.onClose();
  }
}
