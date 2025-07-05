import 'package:flutter/material.dart';
import '../../../widgets/custom_card.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../view_models/dashboard/dashboard_state.dart';
import '../../../../l10n/app_localizations.dart';

class BalanceOverviewCard extends StatelessWidget {
  final DashboardData data;

  const BalanceOverviewCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.totalBalance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: data.balance >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.balance >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16.0,
                      color: data.balance >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      data.balance >= 0 ? l10n.positive : l10n.negative,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: data.balance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          
          // Main balance
          Text(
            CurrencyUtils.formatAmount(data.balance),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: data.balance >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 24.0),
          
          // Income and Expense breakdown
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  context,
                  l10n.totalIncome,
                  data.totalIncome,
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildBalanceItem(
                  context,
                  l10n.totalExpenses,
                  data.totalExpense,
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Icon(
                  icon,
                  size: 16.0,
                  color: color,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            CurrencyUtils.formatAmount(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
