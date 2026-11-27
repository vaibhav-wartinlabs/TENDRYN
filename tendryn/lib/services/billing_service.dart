import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/services/api_service.dart';

/// Billing API calls. DTOs mirror InvoiceOut / PaymentOut / CashUpOut / BillingSummary.
class BillingService extends GetxService {
  BillingService({required ApiService api}) : _api = api;

  final ApiService _api;

  Future<List<InvoiceDto>> fetchInvoices({String? patientId, String? status}) async {
    final query = <String, dynamic>{};
    if (patientId != null) query['patient_id'] = patientId;
    if (status != null) query['status'] = status;
    final response = await _api.client.get(
      ApiEndpoints.invoices,
      query: query.isEmpty ? null : query,
      parse: (json) => (json as List<dynamic>)
          .map((e) => InvoiceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<InvoiceDto> fetchInvoice(String id) async {
    final response = await _api.client.get(
      ApiEndpoints.invoice(id),
      parse: (json) => InvoiceDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  /// method is one of cash|card|eft|instant (lowercase). Split payment = one call per method.
  Future<PaymentDto> recordPayment({
    required String invoiceId,
    required String method,
    required double amount,
    String? voidsPaymentId,
  }) async {
    final response = await _api.client.post(
      ApiEndpoints.payments,
      body: {
        'invoice_id': invoiceId,
        'method': method,
        'amount': amount,
        if (voidsPaymentId != null) 'voids_payment_id': voidsPaymentId,
      },
      parse: (json) => PaymentDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<BillingSummaryDto> summary() async {
    final response = await _api.client.get(
      ApiEndpoints.billingSummary,
      parse: (json) => BillingSummaryDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<CashUpDto> createCashUp({DateTime? businessDate, required double countedTotal, String? notes}) async {
    final response = await _api.client.post(
      ApiEndpoints.cashUps,
      body: {
        if (businessDate != null) 'business_date': businessDate.toIso8601String().substring(0, 10),
        'counted_total': countedTotal,
        if (notes != null) 'notes': notes,
      },
      parse: (json) => CashUpDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}

double _num(dynamic v) => v == null ? 0 : (v as num).toDouble();

class InvoiceLineDto {
  const InvoiceLineDto({required this.description, required this.quantity, required this.unitPrice, required this.lineTotal});
  final String description;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  factory InvoiceLineDto.fromJson(Map<String, dynamic> json) => InvoiceLineDto(
        description: json['description'] as String? ?? '',
        quantity: _num(json['quantity']),
        unitPrice: _num(json['unit_price']),
        lineTotal: _num(json['line_total']),
      );
}

class InvoiceDto {
  const InvoiceDto({
    required this.id,
    required this.patientId,
    this.patientName,
    this.fileNumber,
    this.invoiceNumber,
    required this.status,
    required this.total,
    required this.outstanding,
    required this.paid,
    this.issuedOn,
    this.lines = const [],
  });

  final String id;
  final String patientId;
  final String? patientName;
  final String? fileNumber;
  final String? invoiceNumber;
  final String status; // open | part_paid | paid | void
  final double total;
  final double outstanding;
  final double paid;
  final String? issuedOn;
  final List<InvoiceLineDto> lines;

  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        patientName: json['patient_name'] as String?,
        fileNumber: json['file_number'] as String?,
        invoiceNumber: json['invoice_number'] as String?,
        status: json['status'] as String? ?? 'open',
        total: _num(json['total']),
        outstanding: _num(json['outstanding']),
        paid: _num(json['paid']),
        issuedOn: json['issued_on'] as String?,
        lines: ((json['lines'] as List<dynamic>?) ?? [])
            .map((e) => InvoiceLineDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PaymentDto {
  const PaymentDto({required this.id, required this.invoiceId, required this.method, required this.amount});
  final String id;
  final String invoiceId;
  final String method;
  final double amount;

  factory PaymentDto.fromJson(Map<String, dynamic> json) => PaymentDto(
        id: json['id'] as String,
        invoiceId: json['invoice_id'] as String,
        method: json['method'] as String? ?? 'cash',
        amount: _num(json['amount']),
      );
}

class CashUpDto {
  const CashUpDto({required this.id, this.expectedTotal, this.countedTotal, required this.variance});
  final String id;
  final double? expectedTotal;
  final double? countedTotal;
  final double variance;

  factory CashUpDto.fromJson(Map<String, dynamic> json) => CashUpDto(
        id: json['id'] as String,
        expectedTotal: json['expected_total'] == null ? null : _num(json['expected_total']),
        countedTotal: json['counted_total'] == null ? null : _num(json['counted_total']),
        variance: _num(json['variance']),
      );
}

class BillingSummaryDto {
  const BillingSummaryDto({
    required this.toCollect,
    required this.toCollectCount,
    required this.paidToday,
    required this.paidTodayCount,
    required this.cashUpStatus,
  });
  final double toCollect;
  final int toCollectCount;
  final double paidToday;
  final int paidTodayCount;
  final String cashUpStatus;

  factory BillingSummaryDto.fromJson(Map<String, dynamic> json) => BillingSummaryDto(
        toCollect: _num(json['to_collect']),
        toCollectCount: json['to_collect_count'] as int? ?? 0,
        paidToday: _num(json['paid_today']),
        paidTodayCount: json['paid_today_count'] as int? ?? 0,
        cashUpStatus: json['cash_up_status'] as String? ?? 'Not started',
      );
}
