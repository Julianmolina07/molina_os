import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../services/financial_calculator.dart';
import '../accounts/accounts_page.dart';
import '../debts/debts_page.dart';
import '../transactions/add_transaction_page.dart';
import '../transactions/transactions_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionRepository = TransactionRepository(
      DatabaseProvider.instance,
    );

    final debtRepository = DebtRepository(DatabaseProvider.instance);

    const financialCalculator = FinancialCalculator();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MOLINA OS',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Transaction>>(
          stream: transactionRepository.watchAll(),
          builder: (context, transactionSnapshot) {
            if (transactionSnapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error al cargar la información financiera:\n'
                    '${transactionSnapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              );
            }

            if (!transactionSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = transactionSnapshot.data!;

            final summary = financialCalculator.calculate(transactions);

            final accountBalances = financialCalculator
                .calculateAccountBalances(transactions);

            final totalAccountBalance = accountBalances.fold<int>(
              0,
              (total, account) => total + account.balance,
            );

            return StreamBuilder<List<Debt>>(
              stream: debtRepository.watchAll(),
              builder: (context, debtSnapshot) {
                if (debtSnapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error al cargar las deudas:\n'
                        '${debtSnapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  );
                }

                if (!debtSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final debts = debtSnapshot.data!;

                final totalDebt = debts
                    .where((debt) => debt.status == 0 || debt.status == 2)
                    .fold<int>(
                      0,
                      (total, debt) => total + debt.remainingBalance,
                    );

                final activeDebtCount = debts
                    .where((debt) => debt.status == 0 || debt.status == 2)
                    .length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buenos días, Julián',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tu dinero. Tus decisiones. Tu futuro.',
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.onSurface.withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(height: 28),

                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AccountsPage(),
                            ),
                          );
                        },
                        child: _MoneyCard(
                          title: 'DINERO TOTAL',
                          amount: _formatCurrency(totalAccountBalance),
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _MoneyCard(
                        title: 'DISPONIBLE REAL',
                        amount: _formatCurrency(totalAccountBalance),
                        icon: Icons.check_circle_rounded,
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TransactionsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_rounded),
                          label: const Text(
                            'Ver movimientos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Resumen',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Ingresos',
                              amount: _formatCurrency(summary.totalIncome),
                              icon: Icons.trending_up_rounded,
                              iconColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Gastos',
                              amount: _formatCurrency(summary.totalExpenses),
                              icon: Icons.trending_down_rounded,
                              iconColor: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Situación financiera',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 14),

                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DebtsPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Deudas',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.60),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatCurrency(totalDebt),
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Text(
                                'Deudas activas',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.60,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                '$activeDebtCount '
                                '${activeDebtCount == 1 ? 'deuda' : 'deudas'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                'Objetivo principal',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.60,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Salir de deudas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddTransactionPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text(
                            'Registrar movimiento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String _formatCurrency(int amount) {
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
}

class _MoneyCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;

  const _MoneyCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: colorScheme.onSurface.withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
