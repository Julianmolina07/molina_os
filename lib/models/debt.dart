enum DebtStatus {
  active,
  paid,
  overdue,
  cancelled,
}

enum DebtFrequency {
  oneTime,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
}

class Debt {
  final String id;
  final String creditor;
  final String name;

  /// Valor original de la deuda.
  final int originalAmount;

  /// Saldo de capital pendiente.
  final int remainingBalance;

  /// Tasa de interés anual expresada como porcentaje.
  /// Ejemplo: 24.5 significa 24.5% E.A.
  final double interestRate;

  final DateTime startDate;
  final DateTime? dueDate;

  /// Valor habitual de la cuota.
  final int? installmentAmount;

  final DebtFrequency frequency;

  /// Próxima fecha en la que debe realizarse un pago.
  final DateTime? nextDueDate;

  final DebtStatus status;

  final String? notes;

  const Debt({
    required this.id,
    required this.creditor,
    required this.name,
    required this.originalAmount,
    required this.remainingBalance,
    this.interestRate = 0,
    required this.startDate,
    this.dueDate,
    this.installmentAmount,
    this.frequency = DebtFrequency.monthly,
    this.nextDueDate,
    this.status = DebtStatus.active,
    this.notes,
  });
}