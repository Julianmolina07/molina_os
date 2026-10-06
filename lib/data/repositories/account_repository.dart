import 'package:drift/drift.dart';

import '../app_database.dart';

class AccountRepository {
  final AppDatabase database;

  const AccountRepository(this.database);

  Stream<List<Account>> watchAll() {
    return (database.select(
      database.accounts,
    )..where((account) => account.active.equals(true))).watch();
  }

  Future<List<Account>> findActivePaymentAccounts() {
    return (database.select(database.accounts)
          ..where(
            (account) =>
                account.active.equals(true) & account.type.isNotIn([2]),
          )
          ..orderBy([
            (account) =>
                OrderingTerm(expression: account.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<Account?> findById(String id) {
    return (database.select(
      database.accounts,
    )..where((account) => account.id.equals(id))).getSingleOrNull();
  }

  Future<void> create(AccountsCompanion account) {
    return database.into(database.accounts).insert(account);
  }

  Future<bool> updateAccount(AccountsCompanion account) async {
    final updatedRows = await database.update(database.accounts).write(account);

    return updatedRows > 0;
  }

  Future<void> deactivate(String id) {
    return (database.update(database.accounts)
          ..where((account) => account.id.equals(id)))
        .write(const AccountsCompanion(active: Value(false)));
  }
}
