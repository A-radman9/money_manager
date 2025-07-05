import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../view_models/dashboard/dashboard_cubit.dart';
import '../../view_models/dashboard/dashboard_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_and_empty_states.dart';
import '../../../core/constants/app_constants.dart';
import '../transaction/add_transaction_screen.dart';
import '../transaction/transactions_screen.dart';
import 'widgets/balance_overview_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/recent_transactions_card.dart';
import '../settings/settings_screen.dart';
import 'widgets/monthly_summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingWidget(message: 'Loading dashboard...');
          }
          
          if (state is DashboardError) {
            return ErrorStateWidget(
              title: 'Error Loading Dashboard',
              subtitle: state.message,
              actionText: 'Retry',
              onActionPressed: _loadDashboardData,
            );
          }
          
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardCubit>().refreshDashboardData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_getGreeting()}!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Here\'s your financial overview',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Balance Overview
                    BalanceOverviewCard(data: state.data),
                    
                    // Quick Actions
                    QuickActionsCard(onTransactionAdded: _loadDashboardData),
                    
                    // Monthly Summary
                    MonthlySummaryCard(data: state.data),
                    
                    // Recent Transactions
                    RecentTransactionsCard(
                      transactions: state.data.recentTransactions,
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TransactionsScreen(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 100.0), // Space for FAB
                  ],
                ),
              ),
            );
          }
          
          if (state is DashboardRefreshing) {
            // Show previous data while refreshing
            if (state.previousData != null) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardCubit>().refreshDashboardData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good ${_getGreeting()}!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Here\'s your financial overview',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      
                      // Balance Overview
                      BalanceOverviewCard(data: state.previousData!),
                      
                      // Quick Actions
                      QuickActionsCard(onTransactionAdded: _loadDashboardData),
                      
                      // Monthly Summary
                      MonthlySummaryCard(data: state.previousData!),
                      
                      // Recent Transactions
                      RecentTransactionsCard(
                        transactions: state.previousData!.recentTransactions,
                        onViewAll: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TransactionsScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 100.0), // Space for FAB
                    ],
                  ),
                ),
              );
            } else {
              return const LoadingWidget(message: 'Refreshing dashboard...');
            }
          }
          
          return const EmptyStateWidget(
            icon: Icons.dashboard_outlined,
            title: 'Welcome to Money Manager',
            subtitle: 'Start by adding your first transaction',
            actionText: 'Add Transaction',
          );
        },
      ),
      floatingActionButton: FloatingActionButtonCustom(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );

          // Refresh dashboard if transaction was added
          if (result == true) {
            _loadDashboardData();
          }
        },
        icon: Icons.add,
        tooltip: 'Add Transaction',
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }
}
