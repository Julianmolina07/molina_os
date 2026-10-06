enum TransactionType {
  income,
  expense,
  transfer,
  debtPayment,
  lending,
  repayment,
}
enum TransactionCategory {
  food,
  gasoline,
  entertainment,
  outing,
  travel,
  vehicle,
  bills,
  shopping,
  health,
  education,
  family,
  work,
  debt,
  other,
}
enum TransactionContext {
  alone,
  partner,
  friends,
  family,
  work,
  other,
}
class Transaction {
  final String id;
  final TransactionType type;
  final int amount;
  final String accountId;
  final TransactionCategory category;
  final DateTime date;
  /// Cuenta destino. Se utiliza principalmente para transferencias.
  final String? destinationAccountId;
  /// Persona relacionada con préstamos o pagos.
  final String? personId;
  /// Deuda relacionada con el movimiento.
  final String? debtId;
  /// Contexto en el que ocurrió el gasto.
  final TransactionContext? context;
  final String? note;
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.category,
    required this.date,
    this.destinationAccountId,
    this.personId,
    this.debtId,
    this.context,
    this.note,
  });
}