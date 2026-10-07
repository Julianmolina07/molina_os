import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/database_provider.dart';
import '../../data/repositories/loan_repository.dart';
import 'register_loan_page.dart';
import 'register_loan_payment_page.dart';

class PersonDetailPage extends StatelessWidget {
  final PeopleData person;

  const PersonDetailPage({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final loanRepository = LoanRepository(
      DatabaseProvider.instance,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de persona'),
      ),
      body: StreamBuilder<List<Loan>>(
        stream: loanRepository.watchByPerson(person.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los préstamos.\n\n'
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

          final loans = snapshot.data!;

          final activeLoans = loans
              .where((loan) => loan.status == 0)
              .toList();

          final totalToCollect = activeLoans.fold<int>(
            0,
            (total, loan) => total + loan.remainingBalance,
          );

          final totalOriginal = loans.fold<int>(
            0,
            (total, loan) => total + loan.originalAmount,
          );

          final totalRemaining = loans.fold<int>(
            0,
            (total, loan) => total + loan.remainingBalance,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IDENTIDAD
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_outline,
                        size: 34,
                        color:
                            colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color:
                                  colorScheme.onSurface,
                            ),
                          ),
                          if (person.phone != null &&
                              person.phone!
                                  .trim()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              person.phone!,
                              style: TextStyle(
                                color: colorScheme
                                    .onSurface
                                    .withValues(
                                      alpha: 0.60,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // NOTAS DE LA PERSONA
                if (person.notes != null &&
                    person.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Text(
                      person.notes!,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // RESUMEN
                Text(
                  'Resumen financiero',
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
                      child: _FinancialCard(
                        title: 'Por cobrar',
                        amount:
                            _formatCurrency(totalToCollect),
                        icon: Icons
                            .account_balance_wallet_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FinancialCard(
                        title: 'Préstamos',
                        amount:
                            '${activeLoans.length}',
                        icon: Icons
                            .receipt_long_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _FinancialCard(
                        title: 'Prestado',
                        amount:
                            _formatCurrency(totalOriginal),
                        icon: Icons
                            .arrow_upward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FinancialCard(
                        title: 'Pendiente',
                        amount:
                            _formatCurrency(totalRemaining),
                        icon: Icons
                            .schedule_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final result =
                          await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => RegisterLoanPage(
                            person: person,
                          ),
                        ),
                      );

                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Préstamo registrado correctamente.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.add_card_outlined,
                    ),
                    label: const Text(
                      'Prestar dinero',
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // PRÉSTAMOS
                Text(
                  'Préstamos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 14),

                if (loans.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .account_balance_outlined,
                          size: 42,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.50),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Esta persona todavía no tiene préstamos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            color:
                                colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...loans.map(
                    (loan) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: _LoanCard(
                        loan: loan,
                        person: person,
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

  static String _formatCurrency(int amount) {
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();
    final value = absoluteAmount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-\$' : '\$'}${buffer.toString()}';
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;

  const _FinancialCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 23,
            color: colorScheme.onSurface,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface
                  .withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  final PeopleData person;

  const _LoanCard({
    required this.loan,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final isActive = loan.status == 0;
    final isPaid = loan.status == 1;
    final isCancelled = loan.status == 2;

    final statusText = isActive
        ? 'Activo'
        : isPaid
            ? 'Pagado'
            : isCancelled
                ? 'Cancelado'
                : 'Desconocido';

    final statusIcon = isActive
        ? Icons.schedule_outlined
        : isPaid
            ? Icons.check_circle_outline
            : isCancelled
                ? Icons.cancel_outlined
                : Icons.help_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Préstamo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                statusIcon,
                size: 20,
                color: colorScheme.onSurface
                    .withValues(alpha: 0.70),
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface
                      .withValues(alpha: 0.65),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _LoanAmountRow(
            label: 'Monto original',
            amount: loan.originalAmount,
          ),

          const SizedBox(height: 8),

          _LoanAmountRow(
            label: 'Pendiente',
            amount: loan.remainingBalance,
          ),

          if (loan.dueDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Fecha límite: ${_formatDate(loan.dueDate!)}',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface
                    .withValues(alpha: 0.60),
              ),
            ),
          ],

          if (loan.notes != null &&
              loan.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              loan.notes!,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface
                    .withValues(alpha: 0.70),
              ),
            ),
          ],

          if (isActive) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () async {
                  final result =
                      await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) =>
                          RegisterLoanPaymentPage(
                        loan: loan,
                        person: person,
                      ),
                    ),
                  );

                  if (result == true &&
                      context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cobro registrado correctamente.',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.payments_outlined,
                ),
                label: const Text(
                  'Cobrar',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');
    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _LoanAmountRow extends StatelessWidget {
  final String label;
  final int amount;

  const _LoanAmountRow({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface
                  .withValues(alpha: 0.60),
            ),
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
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

    return '${amount < 0 ? '-\$' : '\$'}${buffer.toString()}';
  }
}