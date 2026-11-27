import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';

enum LabReferralStatus {
  resultReceived('Result Received'),
  awaitingResult('Awaiting Result'),
  sampleTaken('Sample Taken'),
  requested('Requested');

  const LabReferralStatus(this.label);
  final String label;
}

class LabReferralModel {
  const LabReferralModel({
    required this.id,
    required this.patientName,
    required this.folderNumber,
    required this.testsRequested,
    required this.referralDate,
    required this.status,
    this.requestedBy = 'Dr Thandi Nkosi',
    this.queueNumber = 'Q-001',
    this.collectionDate,
    this.collectionTime,
    this.sampleRecordedBy,
    this.sampleNotes,
    this.referralReference,
    this.uploadedDocumentName,
    this.resultReceivedAt,
    this.uploadedBy,
  });

  final String id;
  final String patientName;
  final String folderNumber;
  final String testsRequested;
  final String referralDate;
  final LabReferralStatus status;
  final String requestedBy;
  final String queueNumber;
  final String? collectionDate;
  final String? collectionTime;
  final String? sampleRecordedBy;
  final String? sampleNotes;
  final String? referralReference;
  final String? uploadedDocumentName;
  final String? resultReceivedAt;
  final String? uploadedBy;

  String get referenceNumber {
    if (referralReference != null && referralReference!.isNotEmpty) {
      return referralReference!;
    }
    final digits = folderNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return 'LR-${digits.isNotEmpty ? digits : "0042"}';
  }

  /// Prefix + patient slug + reference used when building sample/default
  /// laboratory report document names.
  String get documentStem {
    final patientSlug = patientName.trim().replaceAll(RegExp(r'\s+'), '-');
    final testWords = testsRequested.trim().split(RegExp(r'\s+'));
    final code = testWords
        .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z]'), ''))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join();
    final prefix = code.isNotEmpty ? code : 'LAB';
    return '${prefix}_${patientSlug}_$referenceNumber';
  }

  String get effectiveDocumentName {
    if (uploadedDocumentName != null && uploadedDocumentName!.isNotEmpty) {
      return uploadedDocumentName!;
    }
    return '$documentStem.pdf';
  }

  static String documentTypeLabel(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'JPG image';
    if (lower.endsWith('.png')) return 'PNG image';
    return 'PDF document';
  }

  LabReferralModel copyWith({
    String? id,
    String? patientName,
    String? folderNumber,
    String? testsRequested,
    String? referralDate,
    LabReferralStatus? status,
    String? requestedBy,
    String? queueNumber,
    String? collectionDate,
    String? collectionTime,
    String? sampleRecordedBy,
    String? sampleNotes,
    String? referralReference,
    String? uploadedDocumentName,
    String? resultReceivedAt,
    String? uploadedBy,
  }) {
    return LabReferralModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      folderNumber: folderNumber ?? this.folderNumber,
      testsRequested: testsRequested ?? this.testsRequested,
      referralDate: referralDate ?? this.referralDate,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      queueNumber: queueNumber ?? this.queueNumber,
      collectionDate: collectionDate ?? this.collectionDate,
      collectionTime: collectionTime ?? this.collectionTime,
      sampleRecordedBy: sampleRecordedBy ?? this.sampleRecordedBy,
      sampleNotes: sampleNotes ?? this.sampleNotes,
      referralReference: referralReference ?? this.referralReference,
      uploadedDocumentName: uploadedDocumentName ?? this.uploadedDocumentName,
      resultReceivedAt: resultReceivedAt ?? this.resultReceivedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }
}

class LabReferralStatusPill extends StatelessWidget {
  const LabReferralStatusPill({
    super.key,
    required this.status,
  });

  final LabReferralStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      LabReferralStatus.resultReceived => (
          const Color(0xFFDCFCE7),
          const Color(0xFF15803D),
        ),
      LabReferralStatus.awaitingResult => (
          const Color(0xFFE0E7FF),
          const Color(0xFF4338CA),
        ),
      LabReferralStatus.sampleTaken => (
          const Color(0xFFCCFBF1),
          const Color(0xFF0F766E),
        ),
      LabReferralStatus.requested => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}

