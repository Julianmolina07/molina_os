import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../services/financial_calculator.dart';
import 'add_account_page.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountRepository =
        AccountRepository(DatabaseProvider.instance);

    final transactionRepository =
        TransactionRepository(DatabaseProvider.instance);

    const financialCalculator = FinancialCalculator();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas'),
      ),
      body: StreamBuilder<List<Account>>(
        stream: accountRepository.watchAll(),
        builder: (context, accountSnapshot) {
          if (accountSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar las cuentas:\n'
                  '${accountSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!accountSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final accounts = accountSnapshot.data!;

          if (accounts.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Tus cuentas',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
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
                    title: const Text(
                      'Sin cuentas registradas',
                    ),
                    subtitle: const Text(
                      'Agrega tu primera cuenta para comenzar.',
                    ),
                  ),
                ),
              ],
            );
          }

          return StreamBuilder<List<Transaction>>(
            stream: transactionRepository.watchAll(),
            builder: (context, transactionSnapshot) {
              if (transactionSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error al cargar los movimientos:\n'
                      '${transactionSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (!transactionSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final transactions = transactionSnapshot.data!;

              final balances =
                  financialCalculator.calculateAccountBalances(
                transactions,
              );

              final balanceByAccountId = {
                for (final balance in balances)
                  balance.accountId: balance.balance,
              };

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  100,
                ),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];

                  final balance =
                      balanceByAccountId[account.id] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AccountCard(
                      name: account.name,
                      currency: account.currency,
                      balance: balance,
                    ),
                  );
                },
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

class _AccountCard extends StatelessWidget {
  final String name;
  final String currency;
  final int balance;

  const _AccountCard({
    required this.name,
    required this.currency,
    required this.balance,
  });

  String _formatCurrency(int amount) {
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();
    final value = absoluteAmount.toString();

    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-\$' : '\$'}${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = balance < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currency,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(balance),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isNegative ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}