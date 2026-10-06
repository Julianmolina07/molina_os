import 'package:drift/drift.dart';

import '../data/app_database.dart';
import '../models/transaction.dart' as transaction_model;
import 'financial_calculator.dart';

class DebtPaymentService {
  final AppDatabase database;

  const DebtPaymentService(this.database);

  /// Registra un pago completo de una deuda.
  ///
  /// El pago se divide en:
  /// - capital: reduce el saldo de la deuda;
  /// - intereses: costo financiero;
  /// - comisiones: costos adicionales.
  ///
  /// El total pagado representa una única salida de dinero de la cuenta.
  ///
  /// La deuda, el movimiento financiero y el desglose del pago
  /// se registran dentro de una única transacción SQLite.
  Future<void> registerPayment({
    required String debtId,
    required String accountId,
    required int totalAmount,
    required int principalAmount,
    int interestAmount = 0,
    int feeAmount = 0,
    DateTime? date,
    String? note,
  }) async {
    if (totalAmount <= 0) {
      throw ArgumentError('El pago total debe ser mayor que cero.');
    }

    if (principalAmount < 0) {
      throw ArgumentError('El capital no puede ser negativo.');
    }

    if (interestAmount < 0) {
      throw ArgumentError('Los intereses no pueden ser negativos.');
    }

    if (feeAmount < 0) {
      throw ArgumentError('Las comisiones no pueden ser negativas.');
    }

    final calculatedTotal = principalAmount + interestAmount + feeAmount;

    if (calculatedTotal != totalAmount) {
      throw StateError(
        'El pago total debe ser igual a la suma de '
        'capital, intereses y comisiones.',
      );
    }

    if (principalAmount == 0 && interestAmount == 0 && feeAmount == 0) {
      throw StateError('El pago debe contener al menos un valor.');
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

      if (principalAmount > debt.remainingBalance) {
        throw StateError(
          'El capital del pago no puede superar el saldo pendiente.',
        );
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
      // incluya transferencias recibidas desde otras cuentas.
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

      if (totalAmount > accountBalance) {
        throw StateError(
          'La cuenta no tiene suficiente dinero disponible '
          'para realizar este pago.',
        );
      }

      final newRemainingBalance = debt.remainingBalance - principalAmount;

      final newStatus = newRemainingBalance == 0 ? 1 : debt.status;

      await (database.update(
        database.debts,
      )..where((item) => item.id.equals(debtId))).write(
        DebtsCompanion(
          remainingBalance: Value(newRemainingBalance),
          status: Value(newStatus),
        ),
      );

      final transactionId =
          'debt-payment-${DateTime.now().microsecondsSinceEpoch}';

      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: transactionId,
              type: transaction_model.TransactionType.debtPayment.index,
              amount: totalAmount,
              accountId: accountId,
              category: transaction_model.TransactionCategory.debt.index,
              date: date ?? DateTime.now(),
              debtId: Value(debtId),
              note: Value(note),
            ),
          );

      await database
          .into(database.debtPayments)
          .insert(
            DebtPaymentsCompanion.insert(
              id: 'debt-payment-detail-${DateTime.now().microsecondsSinceEpoch}',
              debtId: debtId,
              transactionId: transactionId,
              totalAmount: totalAmount,
              principalAmount: principalAmount,
              interestAmount: Value(interestAmount),
              feeAmount: Value(feeAmount),
              date: date ?? DateTime.now(),
              note: Value(note),
            ),
          );
    });
  }

  /// Compatibilidad con la API anterior.
  ///
  /// Los pagos antiguos se consideran pagos 100 % de capital.
  Future<void> registerPrincipalPayment({
    required String debtId,
    required String accountId,
    required int amount,
    DateTime? date,
    String? note,
  }) {
    return registerPayment(
      debtId: debtId,
      accountId: accountId,
      totalAmount: amount,
      principalAmount: amount,
      interestAmount: 0,
      feeAmount: 0,
      date: date,
      note: note,
    );
  }
}
