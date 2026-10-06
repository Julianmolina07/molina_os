import 'package:drift/drift.dart';

import '../app_database.dart';

class TransactionRepository {
  final AppDatabase database;

  const TransactionRepository(this.database);

  Stream<List<Transaction>> watchAll() {
    return (database.select(database.transactions)
          ..orderBy([
            (transaction) => OrderingTerm(
                  expression: transaction.date,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<List<Transaction>> watchByAccount(String accountId) {
    return (database.select(database.transactions)
          ..where(
            (transaction) => transaction.accountId.equals(accountId),
          )
          ..orderBy([
            (transaction) => OrderingTerm(
                  expression: transaction.date,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<Transaction?> findById(String id) {
    return (database.select(database.transactions)
          ..where((transaction) => transaction.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> create(TransactionsCompanion transaction) {
    return database.into(database.transactions).insert(transaction);
  }

  Future<bool> updateTransaction(
    TransactionsCompanion transaction,
  ) async {
    final updatedRows = await database
        .update(database.transactions)
        .write(transaction);

    return updatedRows > 0;
  }

  Future<void> delete(String id) {
    return (database.delete(database.transactions)
          ..where((transaction) => transaction.id.equals(id)))
        .go();
  }
}