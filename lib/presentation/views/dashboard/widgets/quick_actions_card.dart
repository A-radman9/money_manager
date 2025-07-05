import 'package:flutter/material.dart';
import '../../../widgets/custom_card.dart';
import '../../transaction/add_transaction_screen.dart';
import '../../reports/reports_screen.dart';
import '../../category/categories_screen.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback? onTransactionAdded;

  const QuickActionsCard({super.key, this.onTransactionAdded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  l10n.addIncome,
                  Icons.add_circle_outline,
                  Colors.green,
                  () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(
                          initialType: AppConstants.incomeType,
                        ),
                      ),
                    );
                    if (result == true && onTransactionAdded != null) {
                      onTransactionAdded!();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  l10n.addExpense,
                  Icons.remove_circle_outline,
                  Colors.red,
                  () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(
                          initialType: AppConstants.expenseType,
                        ),
                      ),
                    );
                    if (result == true && onTransactionAdded != null) {
                      onTransactionAdded!();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  l10n.reports,
                  Icons.bar_chart,
                  theme.primaryColor,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReportsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  l10n.categories,
                  Icons.category_outlined,
                  Colors.orange,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CategoriesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: color.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
