import 'package:drift/drift.dart';

import '../app_database.dart';

class DebtPaymentRepository {
  final AppDatabase database;

  const DebtPaymentRepository(this.database);

  Stream<List<DebtPayment>> watchByDebt(String debtId) {
    return (database.select(database.debtPayments)
          ..where((payment) => payment.debtId.equals(debtId))
          ..orderBy([
            (payment) =>
                OrderingTerm(expression: payment.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<DebtPayment>> findByDebt(String debtId) {
    return (database.select(database.debtPayments)
          ..where((payment) => payment.debtId.equals(debtId))
          ..orderBy([
            (payment) =>
                OrderingTerm(expression: payment.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<DebtPayment?> findById(String id) {
    return (database.select(
      database.debtPayments,
    )..where((payment) => payment.id.equals(id))).getSingleOrNull();
  }

  Future<void> create(DebtPaymentsCompanion payment) {
    return database.into(database.debtPayments).insert(payment);
  }

  Future<bool> delete(String id) async {
    final deletedRows = await (database.delete(
      database.debtPayments,
    )..where((payment) => payment.id.equals(id))).go();

    return deletedRows > 0;
  }
}
