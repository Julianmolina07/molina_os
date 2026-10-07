import 'package:drift/drift.dart';

import '../app_database.dart';

class LoanPaymentRepository {
  final AppDatabase database;

  const LoanPaymentRepository(this.database);

  Stream<List<LoanPayment>> watchByLoan(String loanId) {
    return (database.select(database.loanPayments)
          ..where(
            (payment) => payment.loanId.equals(loanId),
          )
          ..orderBy([
            (payment) => OrderingTerm(
                  expression: payment.date,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<List<LoanPayment>> findByLoan(String loanId) {
    return (database.select(database.loanPayments)
          ..where(
            (payment) => payment.loanId.equals(loanId),
          )
          ..orderBy([
            (payment) => OrderingTerm(
                  expression: payment.date,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  Future<LoanPayment?> findById(String id) {
    return (database.select(database.loanPayments)
          ..where(
            (payment) => payment.id.equals(id),
          ))
        .getSingleOrNull();
  }

  Future<void> create(LoanPaymentsCompanion payment) {
    return database.into(database.loanPayments).insert(payment);
  }

  Future<bool> delete(String id) async {
    final deletedRows = await (database.delete(database.loanPayments)
          ..where(
            (payment) => payment.id.equals(id),
          ))
        .go();

    return deletedRows > 0;
  }
}