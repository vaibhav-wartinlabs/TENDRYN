import 'package:flutter/material.dart';
import 'package:tendryn/core/theme/app_colors.dart';

/// Where a doctor's appointment stands today (status pill in the Doctor
/// Appointments design).
enum DoctorAppointmentStatus {
  scheduled('Scheduled', AppColors.feedbackInfoTint, AppColors.feedbackInfo),
  checkedIn('Checked in', AppColors.brandTint, AppColors.brandPrimary),
  readyForConsultation('Ready for consultation', AppColors.feedbackSuccessTint, AppColors.feedbackSuccess),
  rescheduled('Rescheduled', AppColors.statusRescheduledTint, AppColors.feedbackWarning),
  cancelled('Cancelled', AppColors.statusCancelledTint, AppColors.safetyCriticalText),
  noShow('No-show', AppColors.statusNoShowTint, AppColors.textSecondary);

  const DoctorAppointmentStatus(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

/// One row of the signed-in doctor's day list.
class DoctorAppointment {
  const DoctorAppointment({
    required this.date,
    required this.time,
    required this.patient,
    required this.folderNumber,
    this.visit,
    required this.status,
    this.durationMinutes = 20,
    this.clinician = 'Dr. Maya Naidoo',
    this.bookedBy = 'Reception',
  });

  /// Date only.
  final DateTime date;

  /// `HH:mm`
  final String time;
  final String patient;

  /// `SWC-41782`
  final String folderNumber;

  /// `Follow-up`, `Review`, `New visit`; not recorded for some bookings.
  final String? visit;
  final DoctorAppointmentStatus status;

  /// Length of the slot, for the `10:30 – 10:50` range.
  final int durationMinutes;

  /// The doctor the appointment is with.
  final String clinician;
  final String bookedBy;

  String get folderLabel => 'Folder #$folderNumber';

  /// Stable key for this booking: date, time and folder.
  String get id => '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${time.replaceAll(':', '')}-$folderNumber';

  /// `10:50` for a 10:30 slot of 20 minutes.
  String get endTime {
    final parts = time.split(':');
    final total = int.parse(parts[0]) * 60 + int.parse(parts[1]) + durationMinutes;
    return '${(total ~/ 60 % 24).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  }

  /// Booked and still to be seen, so leave on this day affects it.
  bool get isBooked => status != DoctorAppointmentStatus.cancelled && status != DoctorAppointmentStatus.noShow;

  bool get isCheckedIn => status == DoctorAppointmentStatus.checkedIn || status == DoctorAppointmentStatus.readyForConsultation;

  String get checkInLabel => isCheckedIn ? 'Checked in' : 'Not checked in';

  /// The note under the details, by where the appointment stands.
  String get statusNote => switch (status) {
        DoctorAppointmentStatus.scheduled || DoctorAppointmentStatus.rescheduled =>
          'The patient has not checked in yet. Open Consultation becomes available once the patient is checked in and ready.',
        DoctorAppointmentStatus.checkedIn => 'The patient is checked in. Open Consultation becomes available once the patient is ready.',
        DoctorAppointmentStatus.readyForConsultation => 'The patient is checked in and ready for consultation.',
        DoctorAppointmentStatus.cancelled => 'This appointment was cancelled.',
        DoctorAppointmentStatus.noShow => 'The patient did not attend this appointment.',
      };
}

/// One weekday of the signed-in doctor's working hours: zero or more
/// `HH:mm` ranges (a split day has two). No ranges means not working.
class DoctorWorkingDay {
  const DoctorWorkingDay(this.day, [this.ranges = const []]);

  final String day;
  final List<(String, String)> ranges;

  bool get isWorking => ranges.isNotEmpty;

  /// `09:00 AM – 05:00 PM`; a split day joins its ranges with [separator]; `—` when not working.
  String hours({String separator = '  |  '}) =>
      isWorking ? ranges.map((r) => '${_time12(r.$1)} – ${_time12(r.$2)}').join(separator) : '—';

  /// `14:00` as `02:00 PM`.
  static String _time12(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:${parts[1]} ${hour < 12 ? 'AM' : 'PM'}';
  }
}

/// A date no appointments can be booked on (public holiday or approved leave).
class DoctorUnavailableDate {
  const DoctorUnavailableDate({required this.date, required this.reason, required this.kind});

  final DateTime date;

  /// `Christmas Day`
  final String reason;

  /// `Public holiday`
  final String kind;
}

/// Where a leave request stands.
enum DoctorLeaveStatus {
  pending('Pending', AppColors.feedbackWarningTint, AppColors.feedbackWarning),
  approved('Approved', AppColors.feedbackSuccessTint, AppColors.feedbackSuccess),
  rejected('Rejected', AppColors.statusCancelledTint, AppColors.safetyCriticalText);

  const DoctorLeaveStatus(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

/// Leave the doctor has requested, from [start] to [end] inclusive.
class DoctorLeaveRequest {
  const DoctorLeaveRequest({required this.start, required this.end, required this.status, this.reason, this.id});

  /// `{id, status, start_date, end_date, reason}` as the leave service returns it.
  factory DoctorLeaveRequest.fromJson(Map<String, dynamic> json) => DoctorLeaveRequest(
        id: json['id'] as String?,
        start: DateTime.parse(json['start_date'] as String),
        end: DateTime.parse(json['end_date'] as String),
        status: DoctorLeaveStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => DoctorLeaveStatus.pending),
        reason: json['reason'] as String?,
      );

  /// Server id, once the request has been submitted.
  final String? id;

  final DateTime start;
  final DateTime end;
  final DoctorLeaveStatus status;

  /// Optional note from the doctor, e.g. `Annual leave`.
  final String? reason;
}
