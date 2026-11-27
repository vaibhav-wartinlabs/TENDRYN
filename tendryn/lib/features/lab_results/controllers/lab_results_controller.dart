import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/models/lab_result_model.dart';
import 'package:tendryn/features/lab_results/widgets/create_lab_referral_drawer.dart';
import 'package:tendryn/features/lab_results/widgets/lab_referral_details_drawer.dart';
import 'package:tendryn/features/lab_results/widgets/lab_result_drawer.dart';
import 'package:tendryn/routes/app_routes.dart';

class LabResultsController extends GetxController {
  // Tabs: 0 -> Lab Results, 1 -> Lab Referrals
  final RxInt selectedTab = 0.obs;

  void onViewDetail([LabResultModel? result]) {
    final item = result ?? (results.isNotEmpty ? results.first : null);
    Get.toNamed(AppRoutes.labResultDetails, arguments: item);
  }

  void onViewReferral(BuildContext context, LabReferralModel referral) {
    showLabReferralDetails(context, referral: referral);
  }

  void onCreateReferral(BuildContext context) {
    showCreateLabReferral(context);
  }

  void onRecordReview([LabResultModel? result]) {
    final target = result ?? (results.isNotEmpty ? results.first : null);
    if (target != null && Get.context != null) {
      showLabResultDrawer(
        Get.context!,
        result: target,
      );
    } else {
      AppNotice.unavailable('Record review', 'No lab result selected');
    }
  }

  // Search & Filter
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

  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 4;

  // Lab Results List
  final RxList<LabResultModel> results = <LabResultModel>[].obs;

  static const List<LabReferralModel> defaultReferrals = [
    LabReferralModel(
      id: 'ref-1',
      patientName: 'John Smith',
      folderNumber: '#SWC-10427',
      testsRequested: 'Full blood count',
      referralDate: '08 Oct 2026',
      status: LabReferralStatus.resultReceived,
    ),
    LabReferralModel(
      id: 'ref-2',
      patientName: 'Thabo Mokoena',
      folderNumber: '#SWC-40311',
      testsRequested: 'Renal function, Lipid panel',
      referralDate: '11 Oct 2026',
      status: LabReferralStatus.awaitingResult,
    ),
    LabReferralModel(
      id: 'ref-3',
      patientName: 'Ayanda Zulu',
      folderNumber: '#SWC-42560',
      testsRequested: 'HbA1c',
      referralDate: '12 Oct 2026',
      status: LabReferralStatus.sampleTaken,
    ),
    LabReferralModel(
      id: 'ref-4',
      patientName: 'Peter van Wyk',
      folderNumber: '#SWC-43018',
      testsRequested: 'Lipid panel',
      referralDate: '12 Oct 2026',
      status: LabReferralStatus.requested,
    ),
  ];

  // Lab Referrals List
  late final RxList<LabReferralModel> referrals =
      RxList<LabReferralModel>.from(defaultReferrals);

  @override
  void onInit() {
    super.onInit();
    _seedResults();
    _seedReferrals();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _seedResults() {
    results.assignAll([
      LabResultModel(
        id: 'LR-001',
        patientName: 'John Smith',
        folderNumber: 'SWC-10427',
        testName: 'Full blood count',
        category: 'Hematology',
        resultReceivedDate: '12 Oct 2026 · 10:15',
        sampleCollectedDate: '11 Oct 2026 · 14:30',
        orderingDoctor: 'Dr. Maya Naidoo',
        laboratory: 'Soweto NHLS Laboratory',
        status: LabReviewStatus.awaitingReview,
        clinicalNotes: 'Mild microcytic anemia picture. Correlate with iron studies.',
        parameters: const [
          LabParameter(
            name: 'Hemoglobin (Hb)',
            value: '11.8',
            unit: 'g/dL',
            referenceRange: '13.0 – 17.5',
            flag: LabParameterFlag.low,
          ),
          LabParameter(
            name: 'White Cell Count (WBC)',
            value: '7.4',
            unit: 'x10⁹/L',
            referenceRange: '4.0 – 11.0',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'Platelet Count',
            value: '260',
            unit: 'x10⁹/L',
            referenceRange: '150 – 450',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'Hematocrit (HCT)',
            value: '36.2',
            unit: '%',
            referenceRange: '40.0 – 52.0',
            flag: LabParameterFlag.low,
          ),
          LabParameter(
            name: 'Mean Corpuscular Volume (MCV)',
            value: '76.4',
            unit: 'fL',
            referenceRange: '80.0 – 100.0',
            flag: LabParameterFlag.low,
          ),
        ],
      ),
      LabResultModel(
        id: 'LR-002',
        patientName: 'Nomsa Dlamini',
        folderNumber: 'SWC-41782',
        testName: 'Full blood count',
        category: 'Hematology',
        resultReceivedDate: '12 Oct 2026 · 09:42',
        sampleCollectedDate: '11 Oct 2026 · 11:15',
        orderingDoctor: 'Dr. Thandi Maseko',
        laboratory: 'Soweto NHLS Laboratory',
        status: LabReviewStatus.awaitingReview,
        clinicalNotes: 'Elevated leukocyte count with neutrophilia consistent with acute infection.',
        parameters: const [
          LabParameter(
            name: 'Hemoglobin (Hb)',
            value: '13.5',
            unit: 'g/dL',
            referenceRange: '12.0 – 15.5',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'White Cell Count (WBC)',
            value: '14.2',
            unit: 'x10⁹/L',
            referenceRange: '4.0 – 11.0',
            flag: LabParameterFlag.high,
          ),
          LabParameter(
            name: 'Platelet Count',
            value: '310',
            unit: 'x10⁹/L',
            referenceRange: '150 – 450',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'Neutrophils',
            value: '11.1',
            unit: 'x10⁹/L',
            referenceRange: '2.0 – 7.5',
            flag: LabParameterFlag.high,
          ),
        ],
      ),
      LabResultModel(
        id: 'LR-003',
        patientName: 'Sipho Khumalo',
        folderNumber: 'SWC-42107',
        testName: 'Renal function',
        category: 'Biochemistry',
        resultReceivedDate: '12 Oct 2026 · 08:30',
        sampleCollectedDate: '10 Oct 2026 · 16:00',
        orderingDoctor: 'Dr. Sipho Khumalo',
        laboratory: 'Soweto NHLS Laboratory',
        status: LabReviewStatus.awaitingReview,
        clinicalNotes: 'Normal renal clearance; electrolytes stable.',
        parameters: const [
          LabParameter(
            name: 'Serum Creatinine',
            value: '84',
            unit: 'µmol/L',
            referenceRange: '64 – 104',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'eGFR (CKD-EPI)',
            value: '>90',
            unit: 'mL/min/1.73m²',
            referenceRange: '>90',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'Blood Urea Nitrogen',
            value: '4.9',
            unit: 'mmol/L',
            referenceRange: '2.5 – 7.1',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'Sodium (Na)',
            value: '139',
            unit: 'mmol/L',
            referenceRange: '135 – 145',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'Potassium (K)',
            value: '4.3',
            unit: 'mmol/L',
            referenceRange: '3.5 – 5.1',
            flag: LabParameterFlag.normal,
          ),
        ],
      ),
      LabResultModel(
        id: 'LR-004',
        patientName: 'Lerato Maseko',
        folderNumber: 'SWC-39954',
        testName: 'Lipid panel',
        category: 'Biochemistry',
        resultReceivedDate: '09 Oct 2026 · 14:05',
        sampleCollectedDate: '08 Oct 2026 · 09:10',
        orderingDoctor: 'Dr. Maya Naidoo',
        laboratory: 'Soweto NHLS Laboratory',
        status: LabReviewStatus.reviewed,
        reviewedBy: 'Dr. Maya Naidoo',
        reviewedAt: '09 Oct 2026 · 14:30',
        reviewAction: 'Normal · No follow-up needed',
        reviewImpression: 'Lipid profile within targeted cardiovascular primary prevention range.',
        clinicalNotes: 'Target lipid goals met under current statin regimen.',
        parameters: const [
          LabParameter(
            name: 'Total Cholesterol',
            value: '4.4',
            unit: 'mmol/L',
            referenceRange: '<5.0',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'HDL Cholesterol',
            value: '1.4',
            unit: 'mmol/L',
            referenceRange: '>1.2',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'LDL Cholesterol',
            value: '2.4',
            unit: 'mmol/L',
            referenceRange: '<3.0',
            flag: LabParameterFlag.normal,
          ),
          LabParameter(
            name: 'Triglycerides',
            value: '1.3',
            unit: 'mmol/L',
            referenceRange: '<1.7',
            flag: LabParameterFlag.normal,
          ),
        ],
      ),
    ]);
  }

  void _seedReferrals() {
    if (referrals.isEmpty) {
      referrals.assignAll(defaultReferrals);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim().toLowerCase();
    currentPage.value = 1;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    currentPage.value = 1;
  }

  void setTab(int index) {
    selectedTab.value = index;
    currentPage.value = 1;
    if (referrals.isEmpty) {
      referrals.assignAll(defaultReferrals);
    }
  }

  List<LabResultModel> get filteredResults {
    return results.where((item) {
      // Filter check
      if (selectedFilter.value == 'Awaiting review' &&
          item.status != LabReviewStatus.awaitingReview) {
        return false;
      }
      if (selectedFilter.value == 'Reviewed' &&
          item.status != LabReviewStatus.reviewed) {
        return false;
      }

      // Search query check
      if (searchQuery.value.isNotEmpty) {
        final q = searchQuery.value;
        final matchesName = item.patientName.toLowerCase().contains(q);
        final matchesFolder = item.folderNumber.toLowerCase().contains(q);
        final matchesTest = item.testName.toLowerCase().contains(q);
        return matchesName || matchesFolder || matchesTest;
      }

      return true;
    }).toList();
  }

  List<LabResultModel> get pagedResults {
    final list = filteredResults;
    if (list.isEmpty) return [];
    final start = (currentPage.value - 1) * itemsPerPage;
    if (start >= list.length) return [];
    final end = (start + itemsPerPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages {
    final count = filteredResults.length;
    if (count == 0) return 1;
    return (count / itemsPerPage).ceil();
  }

  List<LabReferralModel> get filteredReferrals {
    if (referrals.isEmpty) {
      referrals.assignAll(defaultReferrals);
    }
    return referrals.where((item) {
      if (searchQuery.value.isNotEmpty) {
        final q = searchQuery.value;
        final matchesName = item.patientName.toLowerCase().contains(q);
        final matchesFolder = item.folderNumber.toLowerCase().contains(q);
        final matchesTest = item.testsRequested.toLowerCase().contains(q);
        return matchesName || matchesFolder || matchesTest;
      }
      return true;
    }).toList();
  }

  List<LabReferralModel> get pagedReferrals {
    final list = filteredReferrals;
    if (list.isEmpty) return [];
    final start = (currentPage.value - 1) * itemsPerPage;
    if (start >= list.length) return [];
    final end = (start + itemsPerPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalReferralPages {
    final count = filteredReferrals.length;
    if (count == 0) return 1;
    return (count / itemsPerPage).ceil();
  }

  int get activeTotalPages =>
      selectedTab.value == 1 ? totalReferralPages : totalPages;

  void nextPage() {
    if (currentPage.value < activeTotalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= activeTotalPages) {
      currentPage.value = page;
    }
  }

  void openDrawer(BuildContext context, LabResultModel result, {int initialTab = 0}) {
    showLabResultDrawer(
      context,
      result: result,
      initialTabIndex: initialTab,
    );
  }

  void recordReview({
    required String resultId,
    required String action,
    required String impression,
    required bool notifyPatient,
  }) {
    final index = results.indexWhere((r) => r.id == resultId);
    if (index != -1) {
      final item = results[index];
      item.status = LabReviewStatus.reviewed;
      item.reviewAction = action;
      item.reviewImpression = impression;
      item.reviewedBy = 'Dr. Maya Naidoo';
      item.reviewedAt = 'Today · Just now';
      results[index] = item;
      results.refresh();
    }
  }
}
