# Backend integration (branch: claude/backend-integration)

This branch adds the **service layer** that connects the app to the Tendryn backend. The backend
now serves every screen's data (auth, dashboard, queue, patients, appointments, consultation,
vitals, billing, lab). This branch wires the plumbing; **controller wiring per screen is the
remaining step** (listed below). Run `flutter analyze` after pulling — these files were authored
without a local Dart toolchain.

## What's in this branch

- `lib/core/api/api_endpoints.dart` — all backend paths (patients, appointments, encounters,
  vitals, invoices, payments, cash-ups, billing summary, lab).
- `lib/core/api/api_client.dart` — added `patch<T>()` (needed by `PATCH /encounters/{id}`).
- `lib/services/*_service.dart` — new `GetxService`s following the `QueueService`/`DashboardService`
  pattern, each with small **DTOs** that mirror the backend JSON:
  `patient_service.dart`, `appointments_service.dart`, `billing_service.dart`,
  `consultation_service.dart`, `vitals_service.dart`, `lab_service.dart`.
- `lib/routes/initial_binding.dart` — registers all new services.
- `lib/core/api/mock_interceptor.dart` — minimal mock responses for the new endpoints so screens
  render with `USE_MOCK_API=true`.

## Run against the live backend

Start the backend (from the `tendryn` backend repo):
```powershell
.\scripts\dev\run_dev_server.ps1 -Http       # http://localhost:8000, seeded SQLite
```
Run the app:
```powershell
flutter run -d windows ^
  --dart-define=USE_MOCK_API=false ^
  --dart-define=DEV_OPEN_DASHBOARD=false ^
  --dart-define=API_BASE_URL=http://localhost:8000/v1
```
Demo login: `lerato@ubuntuclinic.co.za` / `password123`.

## Wiring a screen (the pattern)

Each feature controller currently holds a static seed list. Replace it with a service call. Example
(Patients):

```dart
// patients_binding.dart
Get.lazyPut(() => PatientsController(patients: Get.find<PatientService>()));

// patients_controller.dart
class PatientsController extends GetxController {
  PatientsController({required PatientService patients}) : _patients = patients;
  final PatientService _patients;

  final rows = <PatientDto>[].obs;
  final loading = false.obs;

  @override
  void onInit() { super.onInit(); load(); }

  Future<void> load({String? query}) async {
    loading.value = true;
    try {
      rows.assignAll(await _patients.search(query: query));
    } on ApiException catch (e) {
      AppNotice.error(e.message);
    } finally {
      loading.value = false;
    }
  }
}
```
Then in the view, build your display model from the DTO (e.g. `PatientRecord` from `PatientDto`),
or add a `PatientRecord.fromDto(PatientDto)` mapper.

## Remaining controller wiring (per feature)

| Feature | Controller(s) | Replace | With service call |
|---|---|---|---|
| Patients | `patients_controller` (seed/nurseSeed/stats), `register_patient_controller` (register), `patient_details_controller` (getById), `patient_edit_controller` (update) | static lists | `PatientService.search/getById/register/update/stats` |
| Appointments | `appointments_controller`, `doctor_appointments_controller`, `appointment_detail_controller`, `reschedule_controller`, `book_appointment_controller` | static schedule | `AppointmentsService.fetchDay/book/checkIn/reschedule/cancel/noShow` |
| Consultation | `consultation_controller`, `clinical_consultation_view` state | static records; local submit | `ConsultationService.fetchConsultations/createEncounter/updateEncounter/signOff/addDiagnosis/addPrescription/addAddendum` |
| Vitals/Triage | `vitals_triage_controller`, `record_vitals_triage_controller` | seed; toast | `VitalsService.recordVital` (loop the 7 readings) after `ConsultationService.createEncounter` |
| Billing | `billing_controller` (invoices/recordPayment/cashUp), `invoice_details_view` (payment) | static invoices | `BillingService.fetchInvoices/fetchInvoice/recordPayment/summary/createCashUp` |
| Lab | `lab_results_controller`, `lab_referral_controller`, `lab_result_details_controller`, drawers | seeds; in-place mutation | `LabService.fetchReferrals/createReferral/recordSample/uploadResult/fetchResults/getResult/recordReview` |

## Notes / mapping cues

- Money (`total`, `outstanding`, `paid`) is a JSON number; format to `R %,.2f` in the view; parse
  user input back to `double` on submit.
- Payment `method` must be lowercase (`cash`/`card`/`eft`/`instant`). Split payment = one
  `recordPayment` call per method.
- Status strings already use the app's enum `.name` spelling where it mattered (queue:
  `withNurse`/`waitingForDoctor`; consultation: `inProgress`/`signed`). Map others with
  `Enum.values.asNameMap()[s]`.
- Clinical writes (encounters, vitals, diagnoses, prescriptions) return **403** when the patient
  has no POPIA consent — surface `ApiException` (statusCode 403) on the patient banner.
- Appointment `scheduled_start` is a full ISO-8601 timestamp; combine the FE's date + `HH:mm`.
