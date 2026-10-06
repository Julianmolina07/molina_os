import 'package:drift/drift.dart';

import '../app_database.dart';

class DebtRepository {
  final AppDatabase database;

  const DebtRepository(this.database);

  /// Observa todas las deudas registradas.
  Stream<List<Debt>> watchAll() {
    return (database.select(database.debts)..orderBy([
          (debt) => OrderingTerm(
            expression: debt.nextDueDate,
            mode: OrderingMode.asc,
          ),
        ]))
        .watch();
  }

  /// Busca una deuda por su ID.
  Future<Debt?> findById(String id) {
    return (database.select(
      database.debts,
    )..where((debt) => debt.id.equals(id))).getSingleOrNull();
  }

  /// Crea una nueva deuda.
  Future<void> create(DebtsCompanion debt) {
    return database.into(database.debts).insert(debt);
  }

  /// Actualiza una deuda existente.
  Future<bool> updateDebt(DebtsCompanion debt) async {
    final updatedRows = await database.update(database.debts).write(debt);

    return updatedRows > 0;
  }

  /// Registra un abono sobre el capital pendiente.
  ///
  /// El pago no puede superar el saldo actual de la deuda.
  /// Cuando el saldo llega a cero, la deuda pasa automáticamente
  /// a estado "pagada".
  Future<bool> registerPrincipalPayment({
    required String debtId,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('El pago debe ser mayor que cero.');
    }

    final debt = await findById(debtId);

    if (debt == null) {
      return false;
    }

    if (debt.status == 3) {
      throw StateError('No se puede pagar una deuda cancelada.');
    }

    if (amount > debt.remainingBalance) {
      throw StateError('El pago no puede superar el saldo pendiente.');
    }

    final newBalance = debt.remainingBalance - amount;

    final newStatus = newBalance == 0 ? 1 : debt.status;

    final updatedRows =
        await (database.update(
          database.debts,
        )..where((item) => item.id.equals(debtId))).write(
          DebtsCompanion(
            remainingBalance: Value(newBalance),
            status: Value(newStatus),
          ),
        );

    return updatedRows > 0;
  }

  /// Elimina una deuda.
  Future<void> delete(String id) {
    return (database.delete(
      database.debts,
    )..where((debt) => debt.id.equals(id))).go();
  }
}
