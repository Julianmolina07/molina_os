enum LoanStatus {
  active,
  paid,
  cancelled,
}

class Loan {
  final String id;

  /// Persona que recibió el dinero.
  final String personId;

  /// Movimiento financiero que originó el préstamo.
  final String initialTransactionId;

  /// Valor originalmente prestado.
  final int originalAmount;

  /// Saldo que todavía debe la persona.
  final int remainingBalance;

  final DateTime startDate;
  final DateTime? dueDate;

  final LoanStatus status;

  final String? notes;

  const Loan({
    required this.id,
    required this.personId,
    required this.initialTransactionId,
    required this.originalAmount,
    required this.remainingBalance,
    required this.startDate,
    this.dueDate,
    this.status = LoanStatus.active,
    this.notes,
  });
}