import 'package:flutter/material.dart';
import '../../../widgets/custom_card.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../../../view_models/dashboard/dashboard_state.dart';

class MonthlySummaryCard extends StatelessWidget {
  final DashboardData data;

  const MonthlySummaryCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthName = date_utils.DateUtils.formatMonthYear(now);
    
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'This Month ($monthName)',
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
                  color: data.monthlyBalance >= 0 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  data.monthlyBalance >= 0 ? 'Surplus' : 'Deficit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: data.monthlyBalance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          
          // Monthly balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.monthlyBalance >= 0
                    ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                    : [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: data.monthlyBalance >= 0 
                    ? Colors.green.withOpacity(0.2) 
                    : Colors.red.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Balance',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  CurrencyUtils.formatAmount(data.monthlyBalance),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: data.monthlyBalance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          
          // Monthly income and expense
          Row(
            children: [
              Expanded(
                child: _buildMonthlyItem(
                  context,
                  'Income',
                  data.monthlyIncome,
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildMonthlyItem(
                  context,
                  'Expense',
                  data.monthlyExpense,
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          
          // Progress indicators
          _buildProgressIndicator(
            context,
            'Income vs Expense',
            data.monthlyIncome,
            data.monthlyExpense,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyItem(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.0,
                color: color,
              ),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            CurrencyUtils.formatAmount(amount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    String label,
    double income,
    double expense,
  ) {
    final theme = Theme.of(context);
    final total = income + expense;
    final incomePercentage = total > 0 ? income / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 8.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: Row(
            children: [
              if (incomePercentage > 0)
                Expanded(
                  flex: (incomePercentage * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.green,
                    ),
                  ),
                ),
              if (incomePercentage < 1)
                Expanded(
                  flex: ((1 - incomePercentage) * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _buildLegendItem('Income', Colors.green, incomePercentage),
            const SizedBox(width: 16.0),
            _buildLegendItem('Expense', Colors.red, 1 - incomePercentage),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          '$label (${(percentage * 100).toStringAsFixed(1)}%)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
