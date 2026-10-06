import 'package:drift/drift.dart';

import '../data/app_database.dart';
import '../models/transaction.dart' as transaction_model;
import 'financial_calculator.dart';

class DebtPaymentService {
  final AppDatabase database;

  const DebtPaymentService(this.database);

  /// Registra un pago de capital de una deuda y descuenta
  /// el mismo dinero de la cuenta seleccionada.
  ///
  /// La actualización de la deuda y la creación del movimiento
  /// financiero ocurren dentro de una única transacción SQLite.
  Future<void> registerPrincipalPayment({
    required String debtId,
    required String accountId,
    required int amount,
    DateTime? date,
    String? note,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('El pago debe ser mayor que cero.');
    }

    await database.transaction(() async {
      final debt = await (database.select(
        database.debts,
      )..where((item) => item.id.equals(debtId))).getSingleOrNull();

      if (debt == null) {
        throw StateError('La deuda seleccionada no existe.');
      }

      if (debt.status == 3) {
        throw StateError('No se puede pagar una deuda cancelada.');
      }

      if (amount > debt.remainingBalance) {
        throw StateError('El pago no puede superar el saldo pendiente.');
      }

      final account = await (database.select(
        database.accounts,
      )..where((item) => item.id.equals(accountId))).getSingleOrNull();

      if (account == null) {
        throw StateError('La cuenta seleccionada no existe.');
      }

      if (!account.active) {
        throw StateError('No se puede utilizar una cuenta inactiva.');
      }

      // Se consultan TODAS las transacciones para que el cálculo
      // incluya tanto movimientos propios de la cuenta como
      // transferencias recibidas desde otras cuentas.
      final allTransactions = await database
          .select(database.transactions)
          .get();

      final calculator = FinancialCalculator();

      final balances = calculator.calculateAccountBalances(allTransactions);

      final accountBalance =
          balances
              .where((balance) => balance.accountId == accountId)
              .firstOrNull
              ?.balance ??
          0;

      if (amount > accountBalance) {
        throw StateError(
          'La cuenta no tiene suficiente dinero disponible '
          'para realizar este pago.',
        );
      }

      final newBalance = debt.remainingBalance - amount;

      final newStatus = newBalance == 0 ? 1 : debt.status;

      await (database.update(
        database.debts,
      )..where((item) => item.id.equals(debtId))).write(
        DebtsCompanion(
          remainingBalance: Value(newBalance),
          status: Value(newStatus),
        ),
      );

      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'debt-payment-${DateTime.now().microsecondsSinceEpoch}',
              type: transaction_model.TransactionType.debtPayment.index,
              amount: amount,
              accountId: accountId,
              category: transaction_model.TransactionCategory.debt.index,
              date: date ?? DateTime.now(),
              debtId: Value(debtId),
              note: Value(note),
            ),
          );
    });
  }
}
