import 'package:drift/drift.dart';

import '../app_database.dart';

class TransactionRepository {
  final AppDatabase database;

  const TransactionRepository(this.database);

  Stream<List<Transaction>> watchAll() {
    return (database.select(database.transactions)..orderBy([
          (transaction) => OrderingTerm(
            expression: transaction.date,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch();
  }

  Stream<List<Transaction>> watchByAccount(String accountId) {
    return (database.select(database.transactions)
          ..where((transaction) => transaction.accountId.equals(accountId))
          ..orderBy([
            (transaction) => OrderingTerm(
              expression: transaction.date,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<Transaction?> findById(String id) {
    return (database.select(
      database.transactions,
    )..where((transaction) => transaction.id.equals(id))).getSingleOrNull();
  }

  Future<void> create(TransactionsCompanion transaction) {
    return database.into(database.transactions).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsCompanion transaction) async {
    final updatedRows = await database
        .update(database.transactions)
        .write(transaction);

    return updatedRows > 0;
  }

  Future<bool> delete(String id) async {
    return database.transaction(() async {
      final transaction = await findById(id);

      if (transaction == null) {
        return false;
      }

      if (transaction.debtId != null) {
        final debtPayment =
            await (database.select(database.debtPayments)..where(
                  (payment) => payment.transactionId.equals(transaction.id),
                ))
                .getSingleOrNull();

        if (debtPayment == null) {
          throw StateError(
            'El pago de deuda asociado al movimiento no existe.',
          );
        }

        final debt =
            await (database.select(database.debts)
                  ..where((item) => item.id.equals(debtPayment.debtId)))
                .getSingleOrNull();

        if (debt == null) {
          throw StateError('La deuda asociada al movimiento no existe.');
        }

        final restoredBalance =
            debt.remainingBalance + debtPayment.principalAmount;

        var restoredStatus = debt.status;

        if (restoredStatus == 1) {
          restoredStatus =
              debt.nextDueDate != null &&
                  debt.nextDueDate!.isBefore(DateTime.now())
              ? 2
              : 0;
        }

        await (database.update(
          database.debts,
        )..where((item) => item.id.equals(debt.id))).write(
          DebtsCompanion(
            remainingBalance: Value(restoredBalance),
            status: Value(restoredStatus),
          ),
        );

        await (database.delete(
          database.debtPayments,
        )..where((payment) => payment.id.equals(debtPayment.id))).go();
      }

      final deletedRows = await (database.delete(
        database.transactions,
      )..where((transaction) => transaction.id.equals(id))).go();

      return deletedRows > 0;
    });
  }
}
