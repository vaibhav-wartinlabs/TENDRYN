import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/consultation/models/consultation_record.dart';
import 'package:tendryn/routes/app_navigation.dart';

class ConsultationController extends GetxController {
  final searchQuery = ''.obs;
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
  final selectedFilter = 'All'.obs;
  final currentPage = 1.obs;
  final pageSize = 4;
  final isProfileOpen = false.obs;

  void setProfileOpen(bool open) {
    isProfileOpen.value = open;
  }

  final allRecords = <ConsultationRecord>[
    const ConsultationRecord(
      id: '1',
      patientName: 'Thabo Mokoena',
      visit: 'Today · Queue Q-004',
      status: ConsultationRecordStatus.inProgress,
      lastUpdated: '12 Oct · 10:34',
      consultationNumber: 'Q-004',
    ),
    const ConsultationRecord(
      id: '2',
      patientName: 'Nomsa Dlamini',
      visit: 'Today',
      status: ConsultationRecordStatus.draft,
      lastUpdated: '12 Oct · 09:18',
      consultationNumber: 'Q-005',
    ),
    const ConsultationRecord(
      id: '3',
      patientName: 'Sipho Khumalo',
      visit: '09 Oct 2026',
      status: ConsultationRecordStatus.signed,
      lastUpdated: '09 Oct · 14:20',
      consultationNumber: 'Q-001',
    ),
    const ConsultationRecord(
      id: '4',
      patientName: 'Lerato Maseko',
      visit: '08 Oct 2026',
      status: ConsultationRecordStatus.signed,
      lastUpdated: '08 Oct · 11:05',
      consultationNumber: 'Q-002',
    ),
  ].obs;

  List<ConsultationRecord> get filteredRecords {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return allRecords.where((record) {
      final matchesQuery =
          query.isEmpty ||
          record.patientName.toLowerCase().contains(query) ||
          record.consultationNumber.toLowerCase().contains(query) ||
          record.visit.toLowerCase().contains(query);

      final matchesFilter =
          filter == 'All' ||
          (filter == 'In progress' &&
              record.status == ConsultationRecordStatus.inProgress) ||
          (filter == 'Draft' &&
              record.status == ConsultationRecordStatus.draft) ||
          (filter == 'Signed' &&
              record.status == ConsultationRecordStatus.signed);

      return matchesQuery && matchesFilter;
    }).toList();
  }

  int get totalRecords => filteredRecords.length;
  int get totalPages => (totalRecords / pageSize).ceil().clamp(1, 999);

  List<ConsultationRecord> get pagedRecords {
    final records = filteredRecords;
    final startIndex = (currentPage.value - 1) * pageSize;
    if (startIndex >= records.length) return [];
    final endIndex = (startIndex + pageSize).clamp(0, records.length);
    return records.sublist(startIndex, endIndex);
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    currentPage.value = 1;
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void startNewConsultation() {
    AppNavigation.goToConsultationWorkspace();
  }

  void openConsultation(ConsultationRecord record) {
    AppNotice.info(
      'Consultation',
      'Opening consultation for ${record.patientName} (${record.status.label}).',
    );
  }

  @override
  void onClose() {
    isProfileOpen.value = false;
    super.onClose();
  }
}
