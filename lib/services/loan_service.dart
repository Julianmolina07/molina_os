import 'package:drift/drift.dart';

import '../data/app_database.dart';
import '../models/transaction.dart' as transaction_model;
import 'financial_calculator.dart';

class LoanService {
  final AppDatabase database;

  const LoanService(this.database);

  Future<void> registerLoan({
    required String personId,
    required String accountId,
    required int amount,
    DateTime? startDate,
    DateTime? dueDate,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError(
        'El valor del préstamo debe ser mayor que cero.',
      );
    }

    final loanDate = startDate ?? DateTime.now();

    await database.transaction(() async {
      final person = await (database.select(database.people)
            ..where((item) => item.id.equals(personId)))
          .getSingleOrNull();

      if (person == null) {
        throw StateError(
          'La persona seleccionada no existe.',
        );
      }

      if (!person.active) {
        throw StateError(
          'No se puede prestar dinero a una persona inactiva.',
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

      if (account.type == 2) {
        throw StateError(
          'No se puede financiar un préstamo con una tarjeta de crédito.',
        );
      }

      final allTransactions =
          await database.select(database.transactions).get();

      final calculator = FinancialCalculator();

      final balances =
          calculator.calculateAccountBalances(allTransactions);

      final accountBalance = balances
              .where(
                (balance) => balance.accountId == accountId,
              )
              .firstOrNull
              ?.balance ??
          0;

      if (amount > accountBalance) {
        throw StateError(
          'La cuenta no tiene suficiente dinero disponible '
          'para realizar este préstamo.',
        );
      }

      final timestamp =
          DateTime.now().microsecondsSinceEpoch;

      final transactionId = 'loan-lending-$timestamp';
      final loanId = 'loan-$timestamp';

      await database.into(database.transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          type: transaction_model.TransactionType.lending.index,
          amount: amount,
          accountId: accountId,
          category:
              transaction_model.TransactionCategory.other.index,
          date: loanDate,
          personId: Value(personId),
          note: Value(
            notes == null || notes.trim().isEmpty
                ? null
                : notes.trim(),
          ),
        ),
      );

      await database.into(database.loans).insert(
        LoansCompanion.insert(
          id: loanId,
          personId: personId,
          initialTransactionId: transactionId,
          originalAmount: amount,
          remainingBalance: amount,
          startDate: loanDate,
          dueDate: Value(dueDate),
          status: const Value(0),
          notes: Value(
            notes == null || notes.trim().isEmpty
                ? null
                : notes.trim(),
          ),
        ),
      );
    });
  }
}