import 'package:get/get.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/controllers/availability_controller.dart';
import 'package:tendryn/features/appointments/models/availability_schedule.dart';
import 'package:tendryn/features/appointments/models/practitioner.dart';

/// Edit availability for the practitioner chosen in Manage Practitioners. Edits
/// live in a draft until Save, so Cancel and Back discard them. Saving updates
/// the shared schedule for this session only: there is no availability service.
class EditAvailabilityController extends GetxController {
  /// Half-hour times from 06:00 to 20:00.
  static final slots = [for (var m = 6 * 60; m <= 20 * 60; m += 30) '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}'];

  final AvailabilityController _availability = Get.find<AvailabilityController>();

  late final Practitioner practitioner = _availability.selected.value ?? AvailabilityController.practitioners.first;

  late final days = List.of(_availability.scheduleFor(practitioner).days).obs;
  late final leaveDate = _availability.scheduleFor(practitioner).leaveDate.obs;
  late final leaveDuration = _availability.scheduleFor(practitioner).leaveDuration.obs;

  final isSaving = false.obs;

  /// `Fri 2 Oct 2026`
  String get leaveDateLabel {
    final d = leaveDate.value;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[d.weekday - 1]} ${Formatters.shortDate(d)}';
  }

  /// Start times that stay before the day's end.
  List<String> startOptions(int i) => slots.where((t) => t.compareTo(days[i].end) < 0).toList();

  /// End times that stay after the day's start.
  List<String> endOptions(int i) => slots.where((t) => t.compareTo(days[i].start) > 0).toList();

  void setStart(int i, String time) => days[i] = days[i].copyWith(start: time);

  void setEnd(int i, String time) => days[i] = days[i].copyWith(end: time);

  void setLeaveDate(DateTime date) => leaveDate.value = date;

  void setLeaveDuration(String value) => leaveDuration.value = value;

  /// Stores the draft and returns to the availability view.
  void save() {
    if (isSaving.value) return;
    isSaving.value = true;
    _availability.saveSchedule(
      practitioner,
      AvailabilitySchedule(days: List.of(days), leaveDate: leaveDate.value, leaveDuration: leaveDuration.value),
    );
    Get.back();
    Get.snackbar('Availability', 'Changes saved on this device.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    isSaving.value = false;
  }

  /// Discards the draft.
  void cancel() => Get.back();
}
