import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:molina_os/data/app_database.dart';
import 'package:molina_os/data/repositories/account_repository.dart';
import 'package:molina_os/data/repositories/debt_repository.dart';
import 'package:molina_os/data/repositories/transaction_repository.dart';
import 'package:molina_os/models/transaction.dart' as transaction_model;
import 'package:molina_os/services/debt_payment_service.dart';
import 'package:molina_os/services/financial_calculator.dart';

void main() {
  test('MOLINA OS guarda una cuenta y un movimiento financiero', () async {
    final database = AppDatabase(NativeDatabase.memory());

    final accountRepository = AccountRepository(database);
    final transactionRepository = TransactionRepository(database);

    await accountRepository.create(
      AccountsCompanion.insert(
        id: 'account-test',
        name: 'Cuenta principal',
        type: 0,
        currency: const Value('COP'),
        legalOwner: 0,
        economicResponsible: 0,
        active: const Value(true),
      ),
    );

    await transactionRepository.create(
      TransactionsCompanion.insert(
        id: 'transaction-test',
        type: transaction_model.TransactionType.income.index,
        amount: 1500000,
        accountId: 'account-test',
        category: transaction_model.TransactionCategory.work.index,
        date: DateTime(2026, 10, 1),
      ),
    );

    final account = await accountRepository.findById('account-test');

    final transaction = await transactionRepository.findById(
      'transaction-test',
    );

    expect(account, isNotNull);
    expect(account!.name, 'Cuenta principal');
    expect(account.currency, 'COP');

    expect(transaction, isNotNull);
    expect(transaction!.amount, 1500000);
    expect(transaction.type, transaction_model.TransactionType.income.index);

    await database.close();
  });

  test('MOLINA OS guarda y consulta una deuda', () async {
    final database = AppDatabase(NativeDatabase.memory());

    final debtRepository = DebtRepository(database);

    await debtRepository.create(
      DebtsCompanion.insert(
        id: 'debt-test',
        creditor: 'Banco de prueba',
        name: 'Tarjeta de crédito',
        originalAmount: 5000000,
        remainingBalance: 5000000,
        interestRate: const Value(25.0),
        startDate: DateTime(2026, 1, 1),
        installmentAmount: const Value(350000),
        frequency: const Value(3),
        nextDueDate: Value(DateTime(2026, 11, 1)),
        status: const Value(0),
      ),
    );

    final debt = await debtRepository.findById('debt-test');

    expect(debt, isNotNull);
    expect(debt!.creditor, 'Banco de prueba');
    expect(debt.originalAmount, 5000000);
    expect(debt.remainingBalance, 5000000);
    expect(debt.installmentAmount, 350000);
    expect(debt.status, 0);

    await database.close();
  });

  test('MOLINA OS registra un pago de capital de una deuda', () async {
    final database = AppDatabase(NativeDatabase.memory());

    final debtRepository = DebtRepository(database);

    await debtRepository.create(
      DebtsCompanion.insert(
        id: 'payment-test-debt',
        creditor: 'Banco de prueba',
        name: 'Crédito de prueba',
        originalAmount: 8000000,
        remainingBalance: 5400000,
        interestRate: const Value(25.0),
        startDate: DateTime(2026, 1, 15),
        installmentAmount: const Value(450000),
        frequency: const Value(3),
        nextDueDate: Value(DateTime(2026, 11, 15)),
        status: const Value(0),
      ),
    );

    final updated = await debtRepository.registerPrincipalPayment(
      debtId: 'payment-test-debt',
      amount: 400000,
    );

    expect(updated, isTrue);

    final debt = await debtRepository.findById('payment-test-debt');

    expect(debt, isNotNull);
    expect(debt!.remainingBalance, 5000000);
    expect(debt.status, 0);

    await database.close();
  });

  test('MOLINA OS registra un pago con capital, intereses y comisión '
      'sin duplicar la salida de dinero', () async {
    final database = AppDatabase(NativeDatabase.memory());

    final accountRepository = AccountRepository(database);
    final debtRepository = DebtRepository(database);
    final debtPaymentService = DebtPaymentService(database);

    await accountRepository.create(
      AccountsCompanion.insert(
        id: 'breakdown-account-test',
        name: 'Cuenta de prueba',
        type: 0,
        currency: const Value('COP'),
        legalOwner: 0,
        economicResponsible: 0,
        active: const Value(true),
      ),
    );

    await debtRepository.create(
      DebtsCompanion.insert(
        id: 'breakdown-debt-test',
        creditor: 'Banco de prueba',
        name: 'Crédito con intereses',
        originalAmount: 8000000,
        remainingBalance: 5400000,
        interestRate: const Value(25.0),
        startDate: DateTime(2026, 1, 15),
        installmentAmount: const Value(450000),
        frequency: const Value(3),
        nextDueDate: Value(DateTime(2026, 11, 15)),
        status: const Value(0),
      ),
    );

    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'breakdown-initial-income',
            type: transaction_model.TransactionType.income.index,
            amount: 3000000,
            accountId: 'breakdown-account-test',
            category: transaction_model.TransactionCategory.work.index,
            date: DateTime(2026, 10, 1),
          ),
        );

    await debtPaymentService.registerPayment(
      debtId: 'breakdown-debt-test',
      accountId: 'breakdown-account-test',
      totalAmount: 400000,
      principalAmount: 350000,
      interestAmount: 40000,
      feeAmount: 10000,
      date: DateTime(2026, 10, 6),
      note: 'Cuota de prueba con intereses y comisión',
    );

    final debt = await debtRepository.findById('breakdown-debt-test');

    expect(debt, isNotNull);

    // Solo el capital reduce la deuda.
    expect(debt!.remainingBalance, 5050000);
    expect(debt.status, 0);

    final transactions =
        await (database.select(database.transactions)..orderBy([
              (transaction) => OrderingTerm(
                expression: transaction.date,
                mode: OrderingMode.asc,
              ),
            ]))
            .get();

    // Ingreso inicial + un único movimiento de salida.
    expect(transactions, hasLength(2));

    final payment = transactions.last;

    expect(payment.type, transaction_model.TransactionType.debtPayment.index);

    // La salida de dinero es el total completo.
    expect(payment.amount, 400000);
    expect(payment.accountId, 'breakdown-account-test');
    expect(payment.debtId, 'breakdown-debt-test');

    // El desglose contable vive en DebtPayments.
    final debtPayments = await (database.select(
      database.debtPayments,
    )..where((payment) => payment.debtId.equals('breakdown-debt-test'))).get();

    expect(debtPayments, hasLength(1));

    final breakdown = debtPayments.single;

    expect(breakdown.debtId, 'breakdown-debt-test');
    expect(breakdown.transactionId, payment.id);
    expect(breakdown.totalAmount, 400000);
    expect(breakdown.principalAmount, 350000);
    expect(breakdown.interestAmount, 40000);
    expect(breakdown.feeAmount, 10000);

    expect(
      breakdown.totalAmount,
      breakdown.principalAmount +
          breakdown.interestAmount +
          breakdown.feeAmount,
    );

    expect(breakdown.note, 'Cuota de prueba con intereses y comisión');

    final calculator = FinancialCalculator();

    final balances = calculator.calculateAccountBalances(transactions);

    final accountBalance = balances.firstWhere(
      (balance) => balance.accountId == 'breakdown-account-test',
    );

    // 3.000.000 - 400.000 = 2.600.000.
    expect(accountBalance.balance, 2600000);

    final summary = calculator.calculate(
      transactions,
      debtPayments: debtPayments,
    );

    expect(summary.totalIncome, 3000000);

    // $40.000 de intereses + $10.000 de comisión.
    expect(summary.totalExpenses, 50000);

    // El capital de $350.000 no es un gasto.
    expect(summary.totalMoney, 2950000);

    await database.close();
  });

  test(
    'MOLINA OS reconoce una transferencia entrante antes de pagar una deuda',
    () async {
      final database = AppDatabase(NativeDatabase.memory());

      final accountRepository = AccountRepository(database);
      final debtRepository = DebtRepository(database);
      final debtPaymentService = DebtPaymentService(database);

      await accountRepository.create(
        AccountsCompanion.insert(
          id: 'transfer-source-account',
          name: 'Cuenta A',
          type: 0,
          currency: const Value('COP'),
          legalOwner: 0,
          economicResponsible: 0,
          active: const Value(true),
        ),
      );

      await accountRepository.create(
        AccountsCompanion.insert(
          id: 'transfer-destination-account',
          name: 'Cuenta B',
          type: 0,
          currency: const Value('COP'),
          legalOwner: 0,
          economicResponsible: 0,
          active: const Value(true),
        ),
      );

      await debtRepository.create(
        DebtsCompanion.insert(
          id: 'transfer-payment-debt',
          creditor: 'Banco de prueba',
          name: 'Deuda de transferencia',
          originalAmount: 2000000,
          remainingBalance: 700000,
          interestRate: const Value(0),
          startDate: DateTime(2026, 1, 1),
          status: const Value(0),
        ),
      );

      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'transfer-initial-income',
              type: transaction_model.TransactionType.income.index,
              amount: 1000000,
              accountId: 'transfer-source-account',
              category: transaction_model.TransactionCategory.work.index,
              date: DateTime(2026, 10, 1),
            ),
          );

      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'transfer-to-b',
              type: transaction_model.TransactionType.transfer.index,
              amount: 700000,
              accountId: 'transfer-source-account',
              destinationAccountId: const Value('transfer-destination-account'),
              category: transaction_model.TransactionCategory.other.index,
              date: DateTime(2026, 10, 2),
            ),
          );

      await debtPaymentService.registerPayment(
        debtId: 'transfer-payment-debt',
        accountId: 'transfer-destination-account',
        totalAmount: 700000,
        principalAmount: 700000,
        interestAmount: 0,
        feeAmount: 0,
        date: DateTime(2026, 10, 6),
        note: 'Pago desde Cuenta B',
      );

      final debt = await debtRepository.findById('transfer-payment-debt');

      expect(debt, isNotNull);
      expect(debt!.remainingBalance, 0);
      expect(debt.status, 1);

      final transactions = await database.select(database.transactions).get();

      expect(transactions, hasLength(3));

      final calculator = FinancialCalculator();

      final balances = calculator.calculateAccountBalances(transactions);

      final accountBBalance = balances.firstWhere(
        (balance) => balance.accountId == 'transfer-destination-account',
      );

      expect(accountBBalance.balance, 0);

      final debtPayments = await database.select(database.debtPayments).get();

      expect(debtPayments, hasLength(1));
      expect(debtPayments.single.totalAmount, 700000);
      expect(debtPayments.single.principalAmount, 700000);
      expect(debtPayments.single.interestAmount, 0);
      expect(debtPayments.single.feeAmount, 0);

      await database.close();
    },
  );

  test('MOLINA OS rechaza un pago sin fondos y no modifica '
      'la deuda ni crea movimientos ni desglose', () async {
    final database = AppDatabase(NativeDatabase.memory());

    final accountRepository = AccountRepository(database);
    final debtRepository = DebtRepository(database);
    final debtPaymentService = DebtPaymentService(database);

    await accountRepository.create(
      AccountsCompanion.insert(
        id: 'insufficient-funds-account',
        name: 'Cuenta con pocos fondos',
        type: 0,
        currency: const Value('COP'),
        legalOwner: 0,
        economicResponsible: 0,
        active: const Value(true),
      ),
    );

    await debtRepository.create(
      DebtsCompanion.insert(
        id: 'insufficient-funds-debt',
        creditor: 'Banco de prueba',
        name: 'Deuda sin fondos',
        originalAmount: 1000000,
        remainingBalance: 800000,
        interestRate: const Value(0),
        startDate: DateTime(2026, 1, 1),
        status: const Value(0),
      ),
    );

    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'insufficient-funds-income',
            type: transaction_model.TransactionType.income.index,
            amount: 300000,
            accountId: 'insufficient-funds-account',
            category: transaction_model.TransactionCategory.work.index,
            date: DateTime(2026, 10, 1),
          ),
        );

    expect(
      () => debtPaymentService.registerPayment(
        debtId: 'insufficient-funds-debt',
        accountId: 'insufficient-funds-account',
        totalAmount: 400000,
        principalAmount: 350000,
        interestAmount: 40000,
        feeAmount: 10000,
        date: DateTime(2026, 10, 6),
        note: 'Pago rechazado',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('no tiene suficiente dinero disponible'),
        ),
      ),
    );

    final debt = await debtRepository.findById('insufficient-funds-debt');

    expect(debt, isNotNull);
    expect(debt!.remainingBalance, 800000);
    expect(debt.status, 0);

    final transactions = await database.select(database.transactions).get();

    expect(transactions, hasLength(1));
    expect(transactions.first.amount, 300000);

    expect(
      transactions.first.type,
      transaction_model.TransactionType.income.index,
    );

    final debtPayments = await database.select(database.debtPayments).get();

    expect(debtPayments, isEmpty);

    await database.close();
  });
}
