import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../view_models/dashboard/dashboard_cubit.dart';
import '../../view_models/dashboard/dashboard_state.dart';
import '../../view_models/category/category_cubit.dart';
import '../../view_models/category/category_state.dart';
import '../../widgets/loading_and_empty_states.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/category.dart';
import '../../../core/utils/date_utils.dart' as date_utils;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<DashboardCubit>().loadDashboardData();
    context.read<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
          ],
        ),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingWidget();
          }
          
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reports',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardCubit>().loadDashboardData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is DashboardLoaded) {
            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                final categories = categoryState is CategoryLoaded
                  ? categoryState.categories
                  : <Category>[];

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(data: state.data),
                    _TrendsTab(transactions: state.data.recentTransactions),
                    _CategoriesTab(
                      transactions: state.data.recentTransactions,
                      categories: categories,
                    ),
                  ],
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final dynamic data;
  
  const _OverviewTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalIncome = data.totalIncome ?? 0.0;
    final totalExpenses = data.totalExpense ?? 0.0;
    final balance = data.balance ?? 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Overview Cards
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Income',
                  value: '\$${totalIncome.toStringAsFixed(2)}',
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Total Expenses',
                  value: '\$${totalExpenses.toStringAsFixed(2)}',
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetricCard(
            title: 'Net Balance',
            value: '\$${balance.toStringAsFixed(2)}',
            color: balance >= 0 ? Colors.green : Colors.red,
            icon: balance >= 0 ? Icons.trending_up : Icons.trending_down,
            isLarge: true,
          ),
          
          const SizedBox(height: 24),
          
          // Income vs Expenses Pie Chart
          Text(
            'Income vs Expenses',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (totalIncome > 0 || totalExpenses > 0)
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalIncome,
                      title: 'Income\n\$${totalIncome.toStringAsFixed(0)}',
                      color: Colors.green,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: totalExpenses,
                      title: 'Expenses\n\$${totalExpenses.toStringAsFixed(0)}',
                      color: Colors.red,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No data to display',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some transactions to see charts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendsTab extends StatelessWidget {
  final List<Transaction> transactions;

  const _TrendsTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group transactions by date for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) =>
      DateTime(now.year, now.month, now.day - index));

    final dailyData = <DateTime, Map<String, double>>{};

    for (final date in last7Days) {
      dailyData[date] = {'income': 0.0, 'expenses': 0.0};
    }

    for (final transaction in transactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day
      );

      if (dailyData.containsKey(transactionDate)) {
        if (transaction.type == 'income') {
          dailyData[transactionDate]!['income'] =
            (dailyData[transactionDate]!['income'] ?? 0) + transaction.amount;
        } else {
          dailyData[transactionDate]!['expenses'] =
            (dailyData[transactionDate]!['expenses'] ?? 0) + transaction.amount;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Trends (Last 7 Days)',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < last7Days.length) {
                          final date = last7Days.reversed.toList()[index];
                          return Text(
                            '${date.day}/${date.month}',
                            style: theme.textTheme.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  // Income line
                  LineChartBarData(
                    spots: last7Days.reversed.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final date = entry.value;
                      final income = dailyData[date]!['income']!;
                      return FlSpot(index.toDouble(), income);
                    }).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                  // Expenses line
                  LineChartBarData(
                    spots: last7Days.reversed.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final date = entry.value;
                      final expenses = dailyData[date]!['expenses']!;
                      return FlSpot(index.toDouble(), expenses);
                    }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Colors.green, label: 'Income'),
              const SizedBox(width: 24),
              _LegendItem(color: Colors.red, label: 'Expenses'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;

  const _CategoriesTab({
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create category lookup map
    final categoryMap = <String, Category>{};
    for (final category in categories) {
      if (category.id != null) {
        categoryMap[category.id!] = category;
      }
    }

    // Group transactions by category
    final categoryData = <String, double>{};
    final categoryColors = <String, Color>{};
    final colors = [
      Colors.blue, Colors.orange, Colors.purple, Colors.teal,
      Colors.pink, Colors.indigo, Colors.amber, Colors.cyan,
    ];

    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        final categoryId = transaction.categoryId;
        final category = categoryMap[categoryId];
        final categoryName = category?.name ?? 'Unknown Category';

        categoryData[categoryName] = (categoryData[categoryName] ?? 0) + transaction.amount;

        if (!categoryColors.containsKey(categoryName)) {
          categoryColors[categoryName] = colors[categoryColors.length % colors.length];
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (categoryData.isNotEmpty)
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((entry) {
                    final percentage = (entry.value / categoryData.values.reduce((a, b) => a + b)) * 100;
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: categoryColors[entry.key]!,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expense data',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Category breakdown list
          if (categoryData.isNotEmpty) ...[
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...categoryData.entries.map((entry) {
              final percentage = (entry.value / categoryData.values.reduce((a, b) => a + b)) * 100;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: categoryColors[entry.key]!,
                    radius: 12,
                  ),
                  title: Text(entry.key), // Now shows the actual category name
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isLarge;
  
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isLarge ? 28 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: isLarge ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 28 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
