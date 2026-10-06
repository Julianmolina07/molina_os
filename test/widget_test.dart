import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:molina_os/data/app_database.dart';
import 'package:molina_os/data/repositories/account_repository.dart';
import 'package:molina_os/data/repositories/transaction_repository.dart';

void main() {
  test('MOLINA OS puede guardar una cuenta y un movimiento', () async {
    final database = AppDatabase(
      NativeDatabase.memory(),
    );

    final accountRepository = AccountRepository(database);
    final transactionRepository = TransactionRepository(database);

    await accountRepository.create(
      AccountsCompanion.insert(
        id: 'test-account',
        name: 'Cuenta de prueba',
        type: 0,
        currency: const Value('COP'),
        legalOwner: 0,
        economicResponsible: 0,
      ),
    );

    final account = await accountRepository.findById('test-account');

    expect(account, isNotNull);
    expect(account!.name, 'Cuenta de prueba');

    await transactionRepository.create(
      TransactionsCompanion.insert(
        id: 'test-transaction',
        type: 0,
        amount: 50000,
        accountId: 'test-account',
        category: 0,
        date: DateTime(2026, 10, 6, 8, 0),
      ),
    );

    final transaction =
        await transactionRepository.findById('test-transaction');

    expect(transaction, isNotNull);
    expect(transaction!.amount, 50000);
    expect(transaction.accountId, 'test-account');

    await database.close();
  });
}