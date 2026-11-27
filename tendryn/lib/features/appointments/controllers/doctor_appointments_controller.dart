import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/api/api_exception.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/utils/app_logger.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/models/doctor_appointment.dart';
import 'package:tendryn/features/appointments/widgets/doctor_appointments.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/leave_service.dart';

/// Whether the screen lists one day or the Monday to Friday working week.
enum DoctorScheduleScope {
  day('Today'),
  week('Week');

  const DoctorScheduleScope(this.label);

  final String label;
}

/// The two tabs of the Doctor Appointments screen.
enum DoctorTab { appointments, availability }

/// State for the Doctor role's Appointments screen: day or week scope,
/// selected date, patient search and paging over the doctor's own appointments.
class DoctorAppointmentsController extends GetxController {
  static const pageSize = 6;

  /// The day the stand-in schedule below treats as today (the day shown in Figma).
  static final today = DateTime(2026, 10, 22);

  static const _shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Local stand-in until an appointments service for the signed-in doctor
  /// exists; the API client has no such endpoint yet. Week of 19 October 2026.
  static final schedule = <DoctorAppointment>[
    _a(19, '09:00', 'Sipho Khumalo', 'SWC-42107', null, DoctorAppointmentStatus.checkedIn),
    _a(19, '11:00', 'Lerato Maseko', 'SWC-39954', null, DoctorAppointmentStatus.checkedIn),
    _a(20, '10:00', 'Nomsa Dlamini', 'SWC-41782', null, DoctorAppointmentStatus.noShow),
    _a(21, '09:30', 'Bongani Nkosi', 'SWC-41355', null, DoctorAppointmentStatus.checkedIn),
    _a(21, '14:00', 'Thabo Mokoena', 'SWC-40216', null, DoctorAppointmentStatus.cancelled),
    _a(22, '09:00', 'Nomsa Dlamini', 'SWC-41782', 'Follow-up', DoctorAppointmentStatus.checkedIn),
    _a(22, '09:30', 'Thabo Mokoena', 'SWC-40216', 'Review', DoctorAppointmentStatus.readyForConsultation),
    _a(22, '10:30', 'Lerato Maseko', 'SWC-39954', 'Follow-up', DoctorAppointmentStatus.scheduled),
    _a(22, '11:30', 'Sipho Khumalo', 'SWC-42107', 'Review', DoctorAppointmentStatus.rescheduled),
    _a(22, '14:00', 'Zanele Mthembu', 'SWC-38820', 'New visit', DoctorAppointmentStatus.cancelled),
    _a(22, '15:00', 'Bongani Nkosi', 'SWC-41355', 'Follow-up', DoctorAppointmentStatus.noShow),
    _a(23, '10:00', 'Sipho Khumalo', 'SWC-42107', null, DoctorAppointmentStatus.scheduled),
    _a(23, '13:00', 'Zanele Mthembu', 'SWC-38820', null, DoctorAppointmentStatus.scheduled),
  ];

  static DoctorAppointment _a(int day, String time, String patient, String folder, String? visit, DoctorAppointmentStatus status) =>
      DoctorAppointment(date: DateTime(2026, 10, day), time: time, patient: patient, folderNumber: folder, visit: visit, status: status);

  /// Local stand-in for the doctor's weekly working hours; there is no
  /// availability service for the signed-in doctor yet.
  static const workingWeek = <DoctorWorkingDay>[
    DoctorWorkingDay('Monday', [('09:00', '11:30'), ('14:00', '17:00')]),
    DoctorWorkingDay('Tuesday', [('09:00', '17:00')]),
    DoctorWorkingDay('Wednesday', [('09:00', '17:00')]),
    DoctorWorkingDay('Thursday', [('09:00', '17:00')]),
    DoctorWorkingDay('Friday', [('09:00', '17:00')]),
    DoctorWorkingDay('Saturday'),
    DoctorWorkingDay('Sunday'),
  ];

  /// Local stand-in: public holidays and approved leave.
  static final unavailableDates = <DoctorUnavailableDate>[
    DoctorUnavailableDate(date: DateTime(2026, 12, 25), reason: 'Christmas Day', kind: 'Public holiday'),
    DoctorUnavailableDate(date: DateTime(2026, 12, 26), reason: 'Day of Goodwill', kind: 'Public holiday'),
  ];

  final tab = DoctorTab.appointments.obs;

  /// Leave the doctor has requested in this session. There is no leave service
  /// yet, so requests are kept on this device only.
  final leaveRequests = <DoctorLeaveRequest>[].obs;

  // Request Leave draft: kept while the form is open (and across a layout
  // change); Cancel, close and a successful submit clear it.
  final leaveStart = Rxn<DateTime>();
  final leaveEnd = Rxn<DateTime>();
  final leaveSubmitAttempted = false.obs;

  /// True while a request is being sent; blocks a second submission.
  final isSubmittingLeave = false.obs;

  /// Why the last submission failed; null otherwise. The draft is kept.
  final leaveSubmitError = Rxn<ApiException>();
  final reasonController = TextEditingController();

  final selectedDate = today.obs;
  final scope = DoctorScheduleScope.day.obs;
  final searchQuery = ''.obs;
  final page = 0.obs;

  static bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool isToday(DateTime day) => sameDay(day, today);

  /// `Thursday · 22 October 2026`
  String get dateFieldLabel => Formatters.longDate(selectedDate.value).replaceFirst(',', ' ·');

  /// `Thursday · 22 October`
  String get dayHeading => dayLabel(selectedDate.value);

  /// `Thursday · 22 October`
  static String dayLabel(DateTime d) => Formatters.longDate(d).replaceFirst(',', ' ·').replaceFirst(' ${d.year}', '');

  /// `Thu 22`
  static String shortDayLabel(DateTime d) => '${_shortDays[d.weekday - 1]} ${d.day}';

  /// `1 appt` / `6 appts`
  static String countLabel(int count) => '$count ${count == 1 ? 'appt' : 'appts'}';

  bool get isWeek => scope.value == DoctorScheduleScope.week;

  /// Monday of the selected date's week.
  DateTime get weekStart => selectedDate.value.subtract(Duration(days: selectedDate.value.weekday - 1));

  /// Monday to Friday.
  List<DateTime> get weekDays => [for (var i = 0; i < 5; i++) weekStart.add(Duration(days: i))];

  /// `19 – 23 October 2026` (or `28 September – 2 October 2026` across months).
  String get weekHeading {
    final start = weekStart;
    final end = start.add(const Duration(days: 4));
    if (start.month == end.month) return '${start.day} – ${end.day} ${_months[end.month - 1]} ${end.year}';
    return '${start.day} ${_months[start.month - 1]} – ${end.day} ${_months[end.month - 1]} ${end.year}';
  }

  /// The day's appointments matching the search, in time order.
  List<DoctorAppointment> appointmentsOn(DateTime day) {
    final query = searchQuery.value.trim().toLowerCase();
    return schedule
        .where((a) => sameDay(a.date, day))
        .where((a) => query.isEmpty || a.patient.toLowerCase().contains(query) || a.folderNumber.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  List<DoctorAppointment> get filtered => appointmentsOn(selectedDate.value);

  int get weekTotal => weekDays.fold(0, (sum, d) => sum + appointmentsOn(d).length);

  /// `Mon – Fri working week · 13 appointments`
  String get weekSummary => 'Mon – Fri working week · $weekTotal ${weekTotal == 1 ? 'appointment' : 'appointments'}';

  /// `Showing all 13 appointments · 5 weekdays`
  String get weekFooterLabel => 'Showing all $weekTotal ${weekTotal == 1 ? 'appointment' : 'appointments'} · 5 weekdays';

  int get pageCount => (filtered.length / pageSize).ceil().clamp(1, 1 << 20);
  int get currentPage => page.value.clamp(0, pageCount - 1);

  List<DoctorAppointment> get pageEntries => filtered.skip(currentPage * pageSize).take(pageSize).toList();

  /// `Showing 1–6 of 6 appointments`
  String get footerLabel {
    final total = filtered.length;
    if (total == 0) return 'Showing 0 of 0 appointments';
    final start = currentPage * pageSize + 1;
    final end = (start + pageSize - 1).clamp(start, total);
    return 'Showing $start–$end of $total appointments';
  }

  bool get hasPrevious => currentPage > 0;
  bool get hasNext => currentPage < pageCount - 1;

  void previousPage() => page.value = currentPage - 1;
  void nextPage() => page.value = currentPage + 1;

  void setSearch(String value) {
    searchQuery.value = value;
    page.value = 0;
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    page.value = 0;
  }

  /// Previous / next day, or week when the scope is Week.
  void step(int direction) => selectDate(selectedDate.value.add(Duration(days: (isWeek ? 7 : 1) * direction)));

  /// `Today` shows the current day; `Week` shows the week around the selected date.
  void setScope(DoctorScheduleScope value) {
    scope.value = value;
    if (value == DoctorScheduleScope.day) selectDate(today);
    page.value = 0;
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectDate(picked);
  }

  /// The appointment whose details are open (read by the tablet details page).
  final selected = Rxn<DoctorAppointment>();

  /// Opens the details of [appointment]: a side drawer on desktop, a bottom
  /// sheet on phones and a full page on tablets.
  void viewAppointment(BuildContext context, DoctorAppointment appointment) {
    selected.value = appointment;
    if (ResponsiveHelper.usesDrawer(context)) {
      showDoctorAppointmentDrawer(context, appointment);
    } else if (ResponsiveHelper.isMobile(context)) {
      showDoctorAppointmentSheet(context, appointment);
    } else {
      Get.toNamed(AppRoutes.doctorAppointmentDetails);
    }
  }

  /// Leaves the tablet details page, back to Appointments.
  void closeDetailsPage() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      AppNavigation.goTo(AppRoutes.appointments);
    }
  }

  /// `51` from a directory date of birth like `22 Aug 1975`, at [today].
  static int? ageFrom(String dateOfBirth) {
    final parts = dateOfBirth.split(' ');
    if (parts.length != 3) return null;
    final month = _months.indexWhere((m) => m.startsWith(parts[1])) + 1;
    final day = int.tryParse(parts[0]);
    final year = int.tryParse(parts[2]);
    if (month == 0 || day == null || year == null) return null;
    var age = today.year - year;
    if (today.month < month || (today.month == month && today.day < day)) age--;
    return age;
  }

  /// The directory record for the appointment's patient, if there is one.
  PatientRecord? directoryRecord(DoctorAppointment appointment) =>
      PatientsController.seed.firstWhereOrNull((p) => p.fileNumber == appointment.folderNumber);

  /// `51 yrs · Folder #SWC-41782` (age only when the directory has a date of birth).
  String patientMeta(DoctorAppointment appointment) {
    final age = ageFrom(directoryRecord(appointment)?.dateOfBirth ?? '');
    return [if (age != null) '$age yrs', appointment.folderLabel].join(' · ');
  }

  /// Closes the details, then opens the patient's Doctor profile in Patients.
  Future<void> openPatientProfile(DoctorAppointment appointment, VoidCallback close) async {
    final record = directoryRecord(appointment) ??
        PatientRecord(
          name: appointment.patient,
          fileNumber: appointment.folderNumber,
          dateOfBirth: 'Not recorded',
          mobile: 'Not recorded',
          lastVisit: Formatters.shortDate(appointment.date),
        );
    close();
    await WidgetsBinding.instance.endOfFrame;
    PatientsController.requestDoctorProfile(record);
    AppNavigation.goTo(AppRoutes.patients);
  }

  bool get isAvailabilityTab => tab.value == DoctorTab.availability;

  void setTab(DoctorTab value) => tab.value = value;

  /// `Fri 25 Dec 2026`
  static String unavailableDateLabel(DateTime d) => '${_shortDays[d.weekday - 1]} ${Formatters.shortDate(d)}';

  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// `05 – 09 Oct 2026`, `14 Sep 2026` or `28 Sep – 02 Oct 2026`.
  static String leaveDatesLabel(DoctorLeaveRequest r) {
    String month(DateTime d) => _months[d.month - 1].substring(0, 3);
    if (sameDay(r.start, r.end)) return '${_pad(r.start.day)} ${month(r.start)} ${r.start.year}';
    if (r.start.month == r.end.month && r.start.year == r.end.year) {
      return '${_pad(r.start.day)} – ${_pad(r.end.day)} ${month(r.end)} ${r.end.year}';
    }
    return '${_pad(r.start.day)} ${month(r.start)} – ${_pad(r.end.day)} ${month(r.end)} ${r.end.year}';
  }

  /// `5 working days`: the days in the request that the doctor works.
  static String leaveDurationLabel(DoctorLeaveRequest r) {
    var days = 0;
    for (var d = r.start; !d.isAfter(r.end); d = d.add(const Duration(days: 1))) {
      if (workingWeek[d.weekday - 1].isWorking) days++;
    }
    return '$days working ${days == 1 ? 'day' : 'days'}';
  }

  /// Editing hours needs an availability service for the signed-in doctor; the
  /// existing edit form is the Receptionist's practitioner editor.
  void editWorkingHours(DoctorWorkingDay day) => AppNotice.unavailable('Edit working hours');

  void viewLeaveRequest(DoctorLeaveRequest request) => AppNotice.unavailable('Leave request');

  /// `16 Nov 2026`, as the date fields show it.
  static String leaveDateLabel(DateTime d) => '${_pad(d.day)} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

  /// `Mon 16 Nov · 09:00 · Follow-up`
  static String affectedLabel(DoctorAppointment a) =>
      '${_shortDays[a.date.weekday - 1]} ${a.date.day} ${_months[a.date.month - 1].substring(0, 3)} · ${a.time}${a.visit == null ? '' : ' · ${a.visit}'}';

  String? get startError => leaveSubmitAttempted.value && leaveStart.value == null ? 'Start date is required.' : null;

  String? get endError {
    final start = leaveStart.value;
    final end = leaveEnd.value;
    if (start != null && end != null && end.isBefore(start)) return 'End date must be on or after the start date.';
    return leaveSubmitAttempted.value && end == null ? 'End date is required.' : null;
  }

  /// Booked appointments that fall between the chosen dates, in time order.
  List<DoctorAppointment> get affectedAppointments {
    final start = leaveStart.value;
    final end = leaveEnd.value;
    if (start == null || end == null || end.isBefore(start)) return const [];
    return schedule.where((a) => a.isBooked && !a.date.isBefore(start) && !a.date.isAfter(end)).toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.time.compareTo(b.time);
      });
  }

  /// `3 booked appointments fall in these dates`
  static String affectedHeading(int count) =>
      count == 1 ? '1 booked appointment falls in these dates' : '$count booked appointments fall in these dates';

  void resetLeaveDraft() {
    leaveStart.value = null;
    leaveEnd.value = null;
    leaveSubmitAttempted.value = false;
    leaveSubmitError.value = null;
    reasonController.clear();
  }

  /// Opens Request Leave with an empty form: a drawer on desktop, a bottom
  /// sheet on phones and a full page on tablets.
  void requestLeave(BuildContext context) {
    resetLeaveDraft();
    if (ResponsiveHelper.usesDrawer(context)) {
      showLeaveRequestDrawer(context);
    } else if (ResponsiveHelper.isMobile(context)) {
      showLeaveRequestSheet(context);
    } else {
      Get.toNamed(AppRoutes.doctorLeaveRequest);
    }
  }

  Future<void> pickLeaveDate(BuildContext context, {required bool start}) async {
    final first = start ? today : (leaveStart.value ?? today);
    final current = start ? leaveStart.value : leaveEnd.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(first) ? current : first,
      firstDate: first,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final day = DateTime(picked.year, picked.month, picked.day);
    if (start) {
      leaveStart.value = day;
    } else {
      leaveEnd.value = day;
    }
  }

  /// Validates the draft and sends it to the leave service. Returns true only
  /// once the service has confirmed the request; on failure the draft is kept
  /// and [leaveSubmitError] says why.
  Future<bool> submitLeaveRequest() async {
    if (isSubmittingLeave.value) return false;
    leaveSubmitAttempted.value = true;
    final start = leaveStart.value;
    final end = leaveEnd.value;
    if (start == null || end == null || startError != null || endError != null) return false;
    final reason = reasonController.text.trim();
    leaveSubmitError.value = null;
    isSubmittingLeave.value = true;
    try {
      final service = Get.isRegistered<LeaveService>() ? Get.find<LeaveService>() : null;
      if (service == null) throw const ApiException.unexpected();
      final saved = await service.submit(start: start, end: end, reason: reason.isEmpty ? null : reason);
      leaveRequests.insert(0, saved);
      resetLeaveDraft();
      return true;
    } catch (e, st) {
      final error = ApiException.from(e);
      if (error.type == ApiErrorType.unexpected) AppLogger.error(e, st);
      leaveSubmitError.value = error;
      return false;
    } finally {
      isSubmittingLeave.value = false;
    }
  }

  /// Shows "Leave Request Submitted": a bottom sheet on phones, a dialog elsewhere.
  void showLeaveSubmitted() {
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;
    if (ResponsiveHelper.isMobile(context)) {
      showLeaveSubmittedSheet(context);
    } else {
      showLeaveSubmittedDialog(context);
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}
