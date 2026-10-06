enum ReceivableStatus {
  pending,
  partiallyPaid,
  paid,
  overdue,
}
class Receivable {
  final String id;
  final String personName;
  final int originalAmount;
  final int remainingAmount;
  final DateTime createdAt;
  final DateTime? expectedPaymentDate;
  final ReceivableStatus status;
  final String? note;
  const Receivable({
    required this.id,
    required this.personName,
    required this.originalAmount,
    required this.remainingAmount,
    required this.createdAt,
    this.expectedPaymentDate,
    this.status = ReceivableStatus.pending,
    this.note,
  });
}