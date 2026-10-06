import 'package:flutter/material.dart';
import 'add_account_page.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/account_repository.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AccountRepository(DatabaseProvider.instance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas'),
      ),
      body: StreamBuilder(
        stream: repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar las cuentas:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final accounts = snapshot.data!;

          if (accounts.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Tus cuentas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aquí estarán tus bancos, billeteras, tarjetas y efectivo.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.account_balance),
                    ),
                    title: const Text('Sin cuentas registradas'),
                    subtitle: const Text(
                      'Agrega tu primera cuenta para comenzar.',
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.account_balance_wallet),
                  ),
                  title: Text(account.name),
                  subtitle: Text(account.currency),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const AddAccountPage(),
    ),
  );
},
        icon: const Icon(Icons.add),
        label: const Text('Agregar cuenta'),
      ),
    );
  }
}