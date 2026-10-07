import 'package:drift/drift.dart';

import '../data/app_database.dart';
import '../models/transaction.dart' as transaction_model;

class LoanPaymentService {
  final AppDatabase database;

  const LoanPaymentService(this.database);

  Future<void> registerPayment({
    required String loanId,
    required String accountId,
    required int amount,
    DateTime? date,
    String? note,
  }) async {
    if (amount <= 0) {
      throw ArgumentError(
        'El cobro debe ser mayor que cero.',
      );
    }

    final paymentDate = date ?? DateTime.now();

    await database.transaction(() async {
      final loan = await (database.select(database.loans)
            ..where((item) => item.id.equals(loanId)))
          .getSingleOrNull();

      if (loan == null) {
        throw StateError(
          'El préstamo seleccionado no existe.',
        );
      }

      if (loan.status == 2) {
        throw StateError(
          'No se puede cobrar un préstamo cancelado.',
        );
      }

      if (loan.status == 1) {
        throw StateError(
          'Este préstamo ya está completamente pagado.',
        );
      }

      if (amount > loan.remainingBalance) {
        throw StateError(
          'El cobro no puede superar el saldo pendiente.',
        );
      }

      final person = await (database.select(database.people)
            ..where((item) => item.id.equals(loan.personId)))
          .getSingleOrNull();

      if (person == null) {
        throw StateError(
          'La persona asociada al préstamo no existe.',
        );
      }

      final account = await (database.select(database.accounts)
            ..where((item) => item.id.equals(accountId)))
          .getSingleOrNull();

      if (account == null) {
        throw StateError(
          'La cuenta seleccionada no existe.',
        );
      }

      if (!account.active) {
        throw StateError(
          'No se puede utilizar una cuenta inactiva.',
        );
      }

      final newRemainingBalance =
          loan.remainingBalance - amount;

      final newStatus =
          newRemainingBalance == 0 ? 1 : loan.status;

      final timestamp =
          DateTime.now().microsecondsSinceEpoch;

      final transactionId =
          'loan-repayment-$timestamp';

      final paymentId =
          'loan-payment-$timestamp';

      // 1. Actualizar el préstamo.
      await (database.update(database.loans)
            ..where(
              (item) => item.id.equals(loanId),
            ))
          .write(
        LoansCompanion(
          remainingBalance:
              Value(newRemainingBalance),
          status: Value(newStatus),
        ),
      );

      // 2. Registrar entrada de dinero.
      //
      // IMPORTANTE:
      // Esto NO es un ingreso.
      // Es recuperación de dinero que anteriormente
      // habíamos prestado.
      await database.into(database.transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          type:
              transaction_model
                  .TransactionType
                  .repayment
                  .index,
          amount: amount,
          accountId: accountId,
          category:
              transaction_model
                  .TransactionCategory
                  .other
                  .index,
          date: paymentDate,
          personId: Value(loan.personId),
          note: Value(
            note == null || note.trim().isEmpty
                ? null
                : note.trim(),
          ),
        ),
      );

      // 3. Crear el detalle del cobro.
      await database.into(database.loanPayments).insert(
        LoanPaymentsCompanion.insert(
          id: paymentId,
          loanId: loanId,
          transactionId: transactionId,
          amount: amount,
          date: paymentDate,
          note: Value(
            note == null || note.trim().isEmpty
                ? null
                : note.trim(),
          ),
        ),
      );
    });
  }
}