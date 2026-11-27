import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';

/// State of the Nurse "Record Sample" form for one lab referral: the collection
/// date and time, the collection status, validation and submission.
///
/// There is no sample-collection service or endpoint yet, so [submit] validates
/// and then says nothing was recorded; it never reports a sample as saved.
class RecordSampleController extends GetxController {
  RecordSampleController({required this.detail});

  final LabReferralDetail detail;

  /// The only collection status Figma shows. Other options are not designed.
  static const statuses = ['Sample Taken'];

  /// Figma's default collection time.
  static const defaultTime = TimeOfDay(hour: 9, minute: 30);

  late final date = Rxn<DateTime>(_referralDate ?? DateTime.now());
  final time = Rxn<TimeOfDay>(defaultTime);
  final status = RxnString(statuses.first);

  final dateError = RxnString();
  final timeError = RxnString();
  final statusError = RxnString();

  /// True while a submission is running; blocks a second one.
  final isSaving = false.obs;

  DateTime? get _referralDate => parseShortDate(detail.referral.date);

  String get dateLabel => date.value == null ? '' : Formatters.shortDate(date.value!);

  String get timeLabel {
    final t = time.value;
    if (t == null) return '';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return; // cancelled: keep the current value
    date.value = picked;
    dateError.value = null;
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: time.value ?? defaultTime);
    if (picked == null) return;
    time.value = picked;
    timeError.value = null;
  }

  void selectStatus(String value) {
    status.value = value;
    statusError.value = null;
  }

  /// Sets the three error messages; true when the form is valid. Entered values are kept.
  bool validate() {
    final d = date.value;
    final referral = _referralDate;
    dateError.value = d == null
        ? 'Select the collection date.'
        : (referral != null && DateUtils.dateOnly(d).isBefore(DateUtils.dateOnly(referral)))
            ? 'The collection date can’t be before the referral date.'
            : null;
    timeError.value = time.value == null ? 'Select the collection time.' : null;
    statusError.value = status.value == null ? 'Select the collection status.' : null;
    return dateError.value == null && timeError.value == null && statusError.value == null;
  }

  /// Save Sample. Validates the form, updates the referral to resultReceived,
  /// updates NursePatientProfileController if present, and returns the updated detail.
  Future<LabReferralDetail?> submit() async {
    if (isSaving.value) return null;
    if (!validate()) return null;
    isSaving.value = true;
    try {
      final updatedReferral = LabReferral(
        test: detail.referral.test,
        date: detail.referral.date,
        requestedBy: detail.referral.requestedBy,
        status: LabReferralStatus.resultReceived,
      );
      final updatedDetail = LabReferralDetail(
        patientName: detail.patientName,
        patientId: detail.patientId,
        referral: updatedReferral,
      );
      if (Get.isRegistered<NursePatientProfileController>()) {
        Get.find<NursePatientProfileController>().updateReferral(updatedReferral);
      }
      return updatedDetail;
    } finally {
      isSaving.value = false;
    }
  }

  /// `27 Oct 2026` -> a date, or null when it is not in that format.
  static DateTime? parseShortDate(String text) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = months.indexOf(parts[1]) + 1;
    final year = int.tryParse(parts[2]);
    if (day == null || month == 0 || year == null) return null;
    return DateTime(year, month, day);
  }
}
