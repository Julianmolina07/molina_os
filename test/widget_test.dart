import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:molina_os/data/app_database.dart';
import 'package:molina_os/data/repositories/account_repository.dart';

void main() {
  test('MOLINA OS puede guardar y leer una cuenta', () async {
    final database = AppDatabase(
      NativeDatabase.memory(),
    );

    final repository = AccountRepository(database);

    await repository.create(
      AccountsCompanion.insert(
        id: 'test-account',
        name: 'Cuenta de prueba',
        type: 0,
        currency: const Value('COP'),
        legalOwner: 0,
        economicResponsible: 0,
      ),
    );

    final account = await repository.findById('test-account');

    expect(account, isNotNull);
    expect(account!.name, 'Cuenta de prueba');
    expect(account.currency, 'COP');

    await database.close();
  });
}