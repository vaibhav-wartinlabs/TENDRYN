import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/models/availability_schedule.dart';
import 'package:tendryn/features/appointments/models/practitioner.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Manage Practitioners: a searchable, paged list; choosing a practitioner opens
/// their working hours, leave and public holidays. There is no availability
/// service yet, so the data is local and nothing is stored.
class AvailabilityController extends GetxController {
  static const pageSize = 4;

  static const practitioners = [
    Practitioner(name: 'Dr. Thandiwe Nkosi', id: 'DOC-1024', specialization: 'General Practitioner', status: PractitionerStatus.available),
    Practitioner(name: 'Dr. Sipho Dlamini', id: 'DOC-1031', specialization: 'Paediatrics', status: PractitionerStatus.onLeave),
    Practitioner(name: 'Dr. Aisha Patel', id: 'DOC-1047', specialization: 'Family Medicine', status: PractitionerStatus.available),
    Practitioner(name: 'Dr. Johan van der Merwe', id: 'DOC-1052', specialization: 'Internal Medicine', status: PractitionerStatus.fullyBooked),
    Practitioner(name: 'Dr. Naledi Molefe', id: 'DOC-1058', specialization: 'Dermatology', status: PractitionerStatus.available),
    Practitioner(name: 'Dr. Kabelo Mokoena', id: 'DOC-1063', specialization: 'Cardiology', status: PractitionerStatus.available),
    Practitioner(name: 'Dr. Lindiwe Ndlovu', id: 'DOC-1069', specialization: 'Obstetrics', status: PractitionerStatus.onLeave),
    Practitioner(name: 'Dr. Pieter Botha', id: 'DOC-1074', specialization: 'Orthopaedics', status: PractitionerStatus.fullyBooked),
    Practitioner(name: 'Dr. Fatima Khan', id: 'DOC-1080', specialization: 'General Practitioner', status: PractitionerStatus.available),
    Practitioner(name: 'Dr. Mandla Zulu', id: 'DOC-1086', specialization: 'Psychiatry', status: PractitionerStatus.available),
    Practitioner(name: 'Dr. Thabo Mokoena', id: 'DOC-1091', specialization: 'Ophthalmology', status: PractitionerStatus.available),
    Practitioner(name: 'Dr. Zanele Mthembu', id: 'DOC-1097', specialization: 'Family Medicine', status: PractitionerStatus.fullyBooked),
  ];

  static const slotLabel = '30-minute appointment slots';

  static const holiday = 'Heritage Day · 24 September';
  static const holidayKind = 'Closed';

  /// Saved availability by practitioner id; practitioners without an entry use the defaults.
  final schedules = <String, AvailabilitySchedule>{}.obs;

  final searchText = TextEditingController();
  final query = ''.obs;

  /// 1-based.
  final page = 1.obs;

  /// The practitioner whose availability is open; null shows the list.
  final selected = Rxn<Practitioner>();

  AvailabilitySchedule scheduleFor(Practitioner p) => schedules[p.id] ?? AvailabilitySchedule.defaults;

  /// Stores an edit for this session (there is no availability service yet).
  void saveSchedule(Practitioner p, AvailabilitySchedule schedule) => schedules[p.id] = schedule;

  AvailabilitySchedule? get selectedSchedule => selected.value == null ? null : scheduleFor(selected.value!);

  /// Day and hours for the selected practitioner; null hours means closed.
  List<(String, String?)> get hoursRows => [
    for (final d in (selectedSchedule ?? AvailabilitySchedule.defaults).days) (d.day, d.label),
    ('Saturday / Sunday', null),
  ];

  /// `Friday 2 October 2026`
  String get leaveDetail => Formatters.longDate((selectedSchedule ?? AvailabilitySchedule.defaults).leaveDate).replaceFirst(',', '');

  /// `Full day`, `Morning` or `Afternoon`
  String get leaveStatus => (selectedSchedule ?? AvailabilitySchedule.defaults).leaveDuration;

  /// Practitioners matching the search text (name or id).
  List<Practitioner> get filtered {
    final text = query.value.trim().toLowerCase();
    if (text.isEmpty) return practitioners;
    return practitioners.where((p) => p.name.toLowerCase().contains(text) || p.id.toLowerCase().contains(text)).toList();
  }

  int get pageCount => (filtered.length / pageSize).ceil().clamp(1, 1 << 30);

  /// The rows of the current page.
  List<Practitioner> get pageEntries {
    final all = filtered;
    final start = ((page.value - 1) * pageSize).clamp(0, all.length);
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  /// `Showing 1–4 of 12 practitioners`
  String get rangeLabel {
    final total = filtered.length;
    if (total == 0) return 'Showing 0 of 0 practitioners';
    final start = (page.value - 1) * pageSize + 1;
    final end = (start + pageSize - 1).clamp(start, total);
    return 'Showing $start–$end of $total practitioners';
  }

  void search(String text) {
    query.value = text;
    page.value = 1;
  }

  void goToPage(int target) => page.value = target.clamp(1, pageCount);

  void select(Practitioner practitioner) => selected.value = practitioner;

  /// Opens the edit form for the selected practitioner.
  void editAvailability() => Get.toNamed(AppRoutes.editAvailability);

  /// Back to the list from a practitioner's availability, or to Appointments.
  void onBack() {
    if (selected.value != null) {
      selected.value = null;
    } else if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.appointments);
    }
  }

  @override
  void onClose() {
    searchText.dispose();
    super.onClose();
  }
}
