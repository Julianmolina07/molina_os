import '../data/app_database.dart';
import '../models/transaction.dart' as transaction_model;

class FinancialSummary {
  final int totalIncome;
  final int totalExpenses;
  final int totalMoney;

  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalMoney,
  });
}

class AccountBalance {
  final String accountId;
  final int balance;

  const AccountBalance({required this.accountId, required this.balance});
}

class FinancialCalculator {
  const FinancialCalculator();

  FinancialSummary calculate(
    List<Transaction> transactions, {
    List<DebtPayment> debtPayments = const [],
  }) {
    var totalIncome = 0;
    var totalExpenses = 0;

    for (final transaction in transactions) {
      if (transaction.type == transaction_model.TransactionType.income.index) {
        totalIncome += transaction.amount;
      }

      if (transaction.type == transaction_model.TransactionType.expense.index) {
        totalExpenses += transaction.amount;
      }
    }

    // Los intereses y comisiones de las deudas son gastos reales.
    //
    // El capital NO se suma como gasto porque representa una
    // reducción del pasivo y ya está reflejado como salida de caja
    // en el movimiento debtPayment.
    for (final payment in debtPayments) {
      totalExpenses += payment.interestAmount;
      totalExpenses += payment.feeAmount;
    }

    final totalMoney = totalIncome - totalExpenses;

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalMoney: totalMoney,
    );
  }

  List<AccountBalance> calculateAccountBalances(
    List<Transaction> transactions,
  ) {
    final balances = <String, int>{};

    for (final transaction in transactions) {
      balances.putIfAbsent(transaction.accountId, () => 0);

      final type = transaction_model.TransactionType.values[transaction.type];

      switch (type) {
        case transaction_model.TransactionType.income:
          balances[transaction.accountId] =
              balances[transaction.accountId]! + transaction.amount;

        case transaction_model.TransactionType.expense:
          balances[transaction.accountId] =
              balances[transaction.accountId]! - transaction.amount;

        case transaction_model.TransactionType.transfer:
          balances[transaction.accountId] =
              balances[transaction.accountId]! - transaction.amount;

          final destinationId = transaction.destinationAccountId;

          if (destinationId != null) {
            balances.putIfAbsent(destinationId, () => 0);

            balances[destinationId] =
                balances[destinationId]! + transaction.amount;
          }

        case transaction_model.TransactionType.debtPayment:
          balances[transaction.accountId] =
              balances[transaction.accountId]! - transaction.amount;

        case transaction_model.TransactionType.lending:
          balances[transaction.accountId] =
              balances[transaction.accountId]! - transaction.amount;

        case transaction_model.TransactionType.repayment:
          balances[transaction.accountId] =
              balances[transaction.accountId]! + transaction.amount;
      }
    }

    return balances.entries
        .map(
          (entry) => AccountBalance(accountId: entry.key, balance: entry.value),
        )
        .toList();
  }
}
