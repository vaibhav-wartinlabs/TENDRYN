import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/views/lab_referral_details_view.dart';
import 'package:tendryn/features/lab_results/views/patient_lab_info_view.dart';
import 'package:tendryn/features/lab_results/widgets/record_sample_drawer.dart';

class ReferralUpdateNotice {
  const ReferralUpdateNotice({
    required this.patientName,
    required this.testName,
    required this.newStatus,
  });

  final String patientName;
  final String testName;
  final LabReferralStatus newStatus;

  String get message => '$patientName · $testName is now ${newStatus.label}.';
}

class LabReferralController extends GetxController {
  static LabReferralController get to => Get.find<LabReferralController>();

  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController {
    try {
      _searchController.addListener(_noop);
      _searchController.removeListener(_noop);
    } catch (_) {
      _searchController = TextEditingController(text: searchQuery.value);
    }
    return _searchController;
  }
  static void _noop() {}

  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final Rxn<ReferralUpdateNotice> updateNotice = Rxn<ReferralUpdateNotice>();

  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 5;
  final int totalPatientCount = 24;

  // ── Lab Staff Result Tab State ────────────────────────────────────────────
  final RxString resultSearchQuery = ''.obs;
  final RxString resultSelectedFilter = 'All'.obs;
  final RxInt resultCurrentPage = 1.obs;

  final RxList<LabReferralModel> labStaffResults = <LabReferralModel>[
    const LabReferralModel(
      id: 'ref-1',
      patientName: 'John Smith',
      folderNumber: 'TND-000124',
      testsRequested: 'Full Blood Count',
      referralDate: '31 Oct 2026',
      requestedBy: 'Dr Thandi Nkosi',
      queueNumber: 'Q-001',
      status: LabReferralStatus.awaitingResult,
    ),
    const LabReferralModel(
      id: 'ref-3',
      patientName: 'Naledi Molefe',
      folderNumber: 'TND-000118',
      testsRequested: 'Urinalysis',
      referralDate: '29 Oct 2026',
      requestedBy: 'Dr Peter Mahlangu',
      queueNumber: 'Q-003',
      status: LabReferralStatus.awaitingResult,
    ),
    const LabReferralModel(
      id: 'ref-4',
      patientName: 'Amahle Khumalo',
      folderNumber: 'TND-000102',
      testsRequested: 'HbA1c',
      referralDate: '28 Oct 2026',
      requestedBy: 'Dr Thandi Nkosi',
      queueNumber: 'Q-004',
      status: LabReferralStatus.resultReceived,
    ),
    const LabReferralModel(
      id: 'ref-5',
      patientName: 'Sipho Dlamini',
      folderNumber: 'TND-000097',
      testsRequested: 'Thyroid Function',
      referralDate: '27 Oct 2026',
      requestedBy: 'Dr Peter Mahlangu',
      queueNumber: 'Q-005',
      status: LabReferralStatus.resultReceived,
    ),
  ].obs;

  final RxList<LabReferralModel> referrals = <LabReferralModel>[
    const LabReferralModel(
      id: 'ref-1',
      patientName: 'John Smith',
      folderNumber: 'TND-000124',
      testsRequested: 'Full Blood Count',
      referralDate: '31 Oct 2026',
      requestedBy: 'Dr Thandi Nkosi',
      queueNumber: 'Q-001',
      status: LabReferralStatus.requested,
    ),
    const LabReferralModel(
      id: 'ref-2',
      patientName: 'Kabelo Mokoena',
      folderNumber: 'TND-000131',
      testsRequested: 'Lipid Panel',
      referralDate: '30 Oct 2026',
      requestedBy: 'Dr Thandi Nkosi',
      queueNumber: 'Q-002',
      status: LabReferralStatus.sampleTaken,
    ),
    const LabReferralModel(
      id: 'ref-3',
      patientName: 'Naledi Molefe',
      folderNumber: 'TND-000118',
      testsRequested: 'Urinalysis',
      referralDate: '29 Oct 2026',
      requestedBy: 'Dr Peter Mahlangu',
      queueNumber: 'Q-003',
      status: LabReferralStatus.awaitingResult,
    ),
    const LabReferralModel(
      id: 'ref-4',
      patientName: 'Amahle Khumalo',
      folderNumber: 'TND-000102',
      testsRequested: 'HbA1c',
      referralDate: '28 Oct 2026',
      requestedBy: 'Dr Thandi Nkosi',
      queueNumber: 'Q-004',
      status: LabReferralStatus.resultReceived,
    ),
    const LabReferralModel(
      id: 'ref-5',
      patientName: 'Sipho Dlamini',
      folderNumber: 'TND-000097',
      testsRequested: 'Thyroid Function',
      referralDate: '27 Oct 2026',
      requestedBy: 'Dr Peter Mahlangu',
      queueNumber: 'Q-005',
      status: LabReferralStatus.resultReceived,
    ),
    const LabReferralModel(
      id: 'ref-6',
      patientName: 'Sipho Dlamini',
      folderNumber: 'TND-000085',
      testsRequested: 'Urinalysis',
      referralDate: '26 Oct 2026',
      requestedBy: 'Dr Peter Mahlangu',
      queueNumber: 'Q-006',
      status: LabReferralStatus.awaitingResult,
    ),
  ].obs;

  List<LabReferralModel> get filteredReferrals {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return referrals.where((ref) {
      final matchesQuery = query.isEmpty ||
          ref.patientName.toLowerCase().contains(query) ||
          ref.folderNumber.toLowerCase().contains(query) ||
          ref.queueNumber.toLowerCase().contains(query) ||
          ref.testsRequested.toLowerCase().contains(query) ||
          ref.requestedBy.toLowerCase().contains(query);

      final matchesFilter = switch (filter) {
        'Requested' => ref.status == LabReferralStatus.requested,
        'Sample Taken' => ref.status == LabReferralStatus.sampleTaken,
        'Awaiting Result' => ref.status == LabReferralStatus.awaitingResult,
        'Result Received' => ref.status == LabReferralStatus.resultReceived,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<LabReferralModel> get pagedReferrals {
    return filteredReferrals.take(itemsPerPage).toList();
  }

  int get totalPages {
    final count = filteredReferrals.length;
    if (count == 0) return 1;
    return (count / itemsPerPage).ceil();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
  }

  void clearSearch() {
    searchQuery.value = '';
    try {
      searchController.clear();
    } catch (_) {}
    currentPage.value = 1;
  }

  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
    currentPage.value = 1;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= 10) {
      currentPage.value = page;
    }
  }

  void nextPage() {
    if (currentPage.value < 10) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  /// Resolves the freshest referral matching [fallback] across [referrals]
  /// and [labStaffResults]. When [preferResultState] is true (e.g. navigating
  /// from Lab Result Details), preserves Result-origin progression instead of
  /// reverting to an unrecorded referral seed.
  LabReferralModel resolveReferral(
    LabReferralModel fallback, {
    bool preferResultState = false,
  }) {
    final fromReferrals = referrals.firstWhereOrNull((r) => r.id == fallback.id);
    final fromResults =
        labStaffResults.firstWhereOrNull((r) => r.id == fallback.id);

    if (preferResultState) {
      final candidates = <LabReferralModel>[
        fallback,
        ?fromReferrals,
        ?fromResults,
      ];
      return candidates.reduce((best, item) {
        if (item.status.index < best.status.index) return item;
        if (item.status.index == best.status.index &&
            item.uploadedDocumentName != null &&
            best.uploadedDocumentName == null) {
          return item;
        }
        return best;
      });
    }

    if (fromResults != null &&
        fromResults.status == LabReferralStatus.resultReceived &&
        (fromReferrals == null ||
            fromReferrals.status != LabReferralStatus.resultReceived)) {
      return fromResults;
    }
    return fromReferrals ?? fromResults ?? fallback;
  }

  // ── Actions from 3-dots Menu ──────────────────────────────────────────────

  /// Action 1: View Detail
  void onViewDetail(BuildContext context, LabReferralModel referral) {
    final latest = resolveReferral(referral);
    openLabReferralDetailsPage(context, referral: latest);
  }

  /// Action 2: Record Sample
  void onRecordSample(BuildContext context, LabReferralModel referral) {
    final latest = resolveReferral(referral);
    showRecordSamplePanel(context, referral: latest);
  }

  /// Action 3: Patient Lab Information
  void onPatientLabInfo(BuildContext context, LabReferralModel referral) {
    final latest = resolveReferral(referral);
    openPatientLabInfoPage(context, referral: latest);
  }

  void updateReferralStatus(
    String referralId,
    LabReferralStatus newStatus, {
    String? collectionDate,
    String? collectionTime,
    String? sampleRecordedBy,
    String? sampleNotes,
    String? uploadedDocumentName,
    String? resultReceivedAt,
    String? uploadedBy,
  }) {
    final index = referrals.indexWhere((r) => r.id == referralId);
    if (index != -1) {
      final updated = referrals[index].copyWith(
        status: newStatus,
        collectionDate: collectionDate ?? referrals[index].collectionDate,
        collectionTime: collectionTime ?? referrals[index].collectionTime,
        sampleRecordedBy: sampleRecordedBy ?? referrals[index].sampleRecordedBy,
        sampleNotes: sampleNotes ?? referrals[index].sampleNotes,
        uploadedDocumentName:
            uploadedDocumentName ?? referrals[index].uploadedDocumentName,
        resultReceivedAt: resultReceivedAt ?? referrals[index].resultReceivedAt,
        uploadedBy: uploadedBy ?? referrals[index].uploadedBy,
      );
      referrals[index] = updated;
      referrals.refresh();

      final resIdx = labStaffResults.indexWhere((r) => r.id == referralId);
      if (newStatus == LabReferralStatus.awaitingResult ||
          newStatus == LabReferralStatus.resultReceived) {
        if (resIdx != -1) {
          labStaffResults[resIdx] = updated;
        } else {
          labStaffResults.insert(0, updated);
        }
        labStaffResults.refresh();
      }
      return;
    }

    final resIdx = labStaffResults.indexWhere((r) => r.id == referralId);
    if (resIdx != -1) {
      labStaffResults[resIdx] = labStaffResults[resIdx].copyWith(
        status: newStatus,
        collectionDate: collectionDate ?? labStaffResults[resIdx].collectionDate,
        collectionTime: collectionTime ?? labStaffResults[resIdx].collectionTime,
        sampleRecordedBy:
            sampleRecordedBy ?? labStaffResults[resIdx].sampleRecordedBy,
        sampleNotes: sampleNotes ?? labStaffResults[resIdx].sampleNotes,
        uploadedDocumentName:
            uploadedDocumentName ?? labStaffResults[resIdx].uploadedDocumentName,
        resultReceivedAt:
            resultReceivedAt ?? labStaffResults[resIdx].resultReceivedAt,
        uploadedBy: uploadedBy ?? labStaffResults[resIdx].uploadedBy,
      );
      labStaffResults.refresh();
    }
  }

  // ── Lab Staff Result Filters & Pagination ────────────────────────────────
  List<LabReferralModel> get filteredLabStaffResults {
    final query = resultSearchQuery.value.trim().toLowerCase();
    final filter = resultSelectedFilter.value;

    return labStaffResults.where((ref) {
      final matchesQuery = query.isEmpty ||
          ref.patientName.toLowerCase().contains(query) ||
          ref.folderNumber.toLowerCase().contains(query) ||
          ref.queueNumber.toLowerCase().contains(query) ||
          ref.testsRequested.toLowerCase().contains(query);

      final matchesFilter = switch (filter) {
        'Awaiting Result' => ref.status == LabReferralStatus.awaitingResult,
        'Result Received' => ref.status == LabReferralStatus.resultReceived,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<LabReferralModel> get pagedLabStaffResults =>
      filteredLabStaffResults.take(itemsPerPage).toList();

  int get awaitingResultCount => filteredLabStaffResults
      .where((r) => r.status == LabReferralStatus.awaitingResult)
      .length;

  int get resultReceivedCount => filteredLabStaffResults
      .where((r) => r.status == LabReferralStatus.resultReceived)
      .length;

  void onResultSearchChanged(String query) {
    resultSearchQuery.value = query;
    resultCurrentPage.value = 1;
  }

  void clearResultSearch() {
    resultSearchQuery.value = '';
    resultCurrentPage.value = 1;
  }

  void onResultFilterChanged(String filter) {
    resultSelectedFilter.value = filter;
    resultCurrentPage.value = 1;
  }

  void goToResultPage(int page) {
    if (page >= 1 && page <= 10) {
      resultCurrentPage.value = page;
    }
  }

  void nextResultPage() {
    if (resultCurrentPage.value < 10) {
      resultCurrentPage.value++;
    }
  }

  void previousResultPage() {
    if (resultCurrentPage.value > 1) {
      resultCurrentPage.value--;
    }
  }

  Timer? _noticeTimer;

  void showUpdateNotice({
    required String patientName,
    required String testName,
    required LabReferralStatus newStatus,
    Duration duration = const Duration(seconds: 5),
  }) {
    _noticeTimer?.cancel();
    updateNotice.value = ReferralUpdateNotice(
      patientName: patientName,
      testName: testName,
      newStatus: newStatus,
    );
    if (duration > Duration.zero) {
      _noticeTimer = Timer(duration, () {
        updateNotice.value = null;
      });
    }
  }

  void clearUpdateNotice() {
    _noticeTimer?.cancel();
    _noticeTimer = null;
    updateNotice.value = null;
  }

  @override
  void onClose() {
    _noticeTimer?.cancel();
    _noticeTimer = null;
    super.onClose();
  }
}
