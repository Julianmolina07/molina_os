enum DebtType {
  creditCard,
  installmentLoan,
  personal,
  other,
}
enum DebtStatus {
  active,
  paid,
  paused,
}
class Debt {
  final String id;
  final String name;
  final String creditor;
  final DebtType type;
  /// Persona que aparece legalmente como responsable de la deuda.
  final String legalDebtor;
  /// Persona que realmente realiza los pagos.
  final String economicResponsible;
  /// Saldo pendiente actual.
  final int remainingAmount;
  /// Tasa de interés anual, si se conoce.
  final double? annualInterestRate;
  /// Valor aproximado de la cuota periódica.
  final int? installmentAmount;
  /// Día habitual de vencimiento.
  final int? dueDay;
  final DebtStatus status;
  const Debt({
    required this.id,
    required this.name,
    required this.creditor,
    required this.type,
    required this.legalDebtor,
    required this.economicResponsible,
    required this.remainingAmount,
    this.annualInterestRate,
    this.installmentAmount,
    this.dueDay,
    this.status = DebtStatus.active,
  });
}