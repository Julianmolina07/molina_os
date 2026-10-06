import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/debt_repository.dart';
import 'add_debt_page.dart';

class DebtsPage extends StatelessWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final debtRepository =
        DebtRepository(DatabaseProvider.instance);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Deudas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: StreamBuilder<List<Debt>>(
        stream: debtRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar las deudas:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final debts = snapshot.data!;

          final activeDebts = debts.where((debt) {
            return debt.status == 0 || debt.status == 2;
          }).toList();

          final totalOriginal = debts.fold<int>(
            0,
            (total, debt) => total + debt.originalAmount,
          );

          final totalRemaining = debts.fold<int>(
            0,
            (total, debt) => total + debt.remainingBalance,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DebtSummaryCard(
                  totalOriginal: totalOriginal,
                  totalRemaining: totalRemaining,
                  activeCount: activeDebts.length,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deudas activas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${activeDebts.length}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (activeDebts.isEmpty)
                  _EmptyDebtsState(
                    onAddDebt: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddDebtPage(),
                        ),
                      );
                    },
                  )
                else
                  ...activeDebts.map(
                    (debt) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: _DebtCard(debt: debt),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddDebtPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Nueva deuda',
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
      ),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  final int totalOriginal;
  final int totalRemaining;
  final int activeCount;

  const _DebtSummaryCard({
    required this.totalOriginal,
    required this.totalRemaining,
    required this.activeCount,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEUDA TOTAL PENDIENTE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: colorScheme.onSurface
                  .withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(totalRemaining),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  title: 'Original',
                  value: _formatCurrency(totalOriginal),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  title: 'Activas',
                  value: '$activeCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(int amount) {
    final value = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-\$' : '\$'}'
        '${buffer.toString()}';
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface
                .withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;

  const _DebtCard({
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isOverdue = debt.status == 2;

    return Container(
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
                      debt.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      debt.creditor,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface
                            .withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Vencida',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Saldo pendiente',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface
                  .withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(debt.remainingBalance),
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          if (debt.installmentAmount != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DebtDetail(
                    title: 'Cuota',
                    value: _formatCurrency(
                      debt.installmentAmount!,
                    ),
                  ),
                ),
                Expanded(
                  child: _DebtDetail(
                    title: 'Interés',
                    value: '${debt.interestRate}%',
                  ),
                ),
              ],
            ),
          ],
          if (debt.nextDueDate != null) ...[
            const SizedBox(height: 14),
            _DebtDetail(
              title: 'Próximo pago',
              value: _formatDate(debt.nextDueDate!),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatCurrency(int amount) {
    final value = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-\$' : '\$'}'
        '${buffer.toString()}';
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _DebtDetail extends StatelessWidget {
  final String title;
  final String value;

  const _DebtDetail({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface
                .withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _EmptyDebtsState extends StatelessWidget {
  final VoidCallback onAddDebt;

  const _EmptyDebtsState({
    required this.onAddDebt,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off_rounded,
            size: 42,
            color: colorScheme.onSurface
                .withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),
          Text(
            'No tienes deudas registradas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Registra tus deudas para comenzar a '
            'tener una visión real de tu situación financiera.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface
                  .withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: onAddDebt,
            child: const Text('Registrar deuda'),
          ),
        ],
      ),
    );
  }
}