enum InvoiceStatus {
  partPaid,
  unpaid,
  paid,
}

class BillingInvoiceModel {
  const BillingInvoiceModel({
    required this.id,
    required this.patientName,
    required this.invoiceNumber,
    required this.status,
    required this.amountText,
    this.fileNumber = 'File #PT-002184 · 082 ••• ••42 · Visit 29 Sep 2026',
    this.visitDate = 'Visit 29 Sep 2026',
    this.consultationFee = 'R 600.00',
    this.dispensedItemsFee = 'R 250.00',
    this.invoiceTotal = 'R 850.00',
    this.alreadyPaid = 'R 500.00',
    this.outstanding = 'R 350.00',
    this.remainingText = 'Part paid · R 350.00 remaining',
  });

  final String id;
  final String patientName;
  final String invoiceNumber;
  final InvoiceStatus status;
  final String amountText;
  final String fileNumber;
  final String visitDate;
  final String consultationFee;
  final String dispensedItemsFee;
  final String invoiceTotal;
  final String alreadyPaid;
  final String outstanding;
  final String remainingText;

  String get statusLabel {
    switch (status) {
      case InvoiceStatus.partPaid:
        return 'Part paid';
      case InvoiceStatus.unpaid:
        return 'Unpaid';
      case InvoiceStatus.paid:
        return 'Paid';
    }
  }
}
