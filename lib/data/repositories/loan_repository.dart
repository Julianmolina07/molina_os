import 'package:drift/drift.dart';

import '../app_database.dart';

class LoanRepository {
  final AppDatabase database;

  const LoanRepository(this.database);

  Stream<List<Loan>> watchAll() {
    return (database.select(database.loans)
          ..orderBy([
            (loan) => OrderingTerm(
                  expression: loan.startDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<List<Loan>> watchByPerson(String personId) {
    return (database.select(database.loans)
          ..where(
            (loan) => loan.personId.equals(personId),
          )
          ..orderBy([
            (loan) => OrderingTerm(
                  expression: loan.startDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<List<Loan>> findAllActive() {
    return (database.select(database.loans)
          ..where(
            (loan) => loan.status.equals(0),
          )
          ..orderBy([
            (loan) => OrderingTerm(
                  expression: loan.startDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  Future<Loan?> findById(String id) {
    return (database.select(database.loans)
          ..where((loan) => loan.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> create(LoansCompanion loan) {
    return database.into(database.loans).insert(loan);
  }

  Future<bool> update(LoansCompanion loan) async {
    final updatedRows =
        await database.update(database.loans).write(loan);

    return updatedRows > 0;
  }
}