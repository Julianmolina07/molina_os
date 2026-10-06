import 'package:drift/drift.dart';

import '../app_database.dart';

class DebtRepository {
  final AppDatabase database;

  const DebtRepository(this.database);

  Stream<List<Debt>> watchAll() {
    return (database.select(database.debts)..orderBy([
          (debt) => OrderingTerm(
            expression: debt.nextDueDate,
            mode: OrderingMode.asc,
          ),
        ]))
        .watch();
  }

  Future<Debt?> findById(String id) {
    return (database.select(
      database.debts,
    )..where((debt) => debt.id.equals(id))).getSingleOrNull();
  }

  Future<void> create(DebtsCompanion debt) {
    return database.into(database.debts).insert(debt);
  }

  Future<bool> updateDebt(DebtsCompanion debt) async {
    final updatedRows = await database.update(database.debts).write(debt);

    return updatedRows > 0;
  }

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

  Future<bool> delete(String id) async {
    return database.transaction(() async {
      final debt = await findById(id);

      if (debt == null) {
        return false;
      }

      final payments = await (database.select(
        database.debtPayments,
      )..where((payment) => payment.debtId.equals(id))).get();

      for (final payment in payments) {
        await (database.delete(database.transactions)..where(
              (transaction) => transaction.id.equals(payment.transactionId),
            ))
            .go();
      }

      await (database.delete(
        database.debtPayments,
      )..where((payment) => payment.debtId.equals(id))).go();

      final deletedRows = await (database.delete(
        database.debts,
      )..where((debt) => debt.id.equals(id))).go();

      return deletedRows > 0;
    });
  }
}
