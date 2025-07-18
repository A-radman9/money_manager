import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../view_models/dashboard/dashboard_cubit.dart';
import '../../view_models/dashboard/dashboard_state.dart';
import '../../view_models/category/category_cubit.dart';
import '../../view_models/category/category_state.dart';
import '../../view_models/transaction/transaction_cubit.dart';
import '../../view_models/transaction/transaction_state.dart';
import '../../widgets/loading_and_empty_states.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/category.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../l10n/app_localizations.dart';

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
    context.read<TransactionCubit>().loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.financialReports),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.overview, icon: const Icon(Icons.pie_chart)),
            Tab(text: l10n.trends, icon: const Icon(Icons.trending_up)),
            Tab(text: l10n.categories, icon: const Icon(Icons.category)),
          ],
        ),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, dashboardState) {
          if (dashboardState is DashboardLoading) {
            return const LoadingWidget();
          }

          if (dashboardState is DashboardError) {
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
                    dashboardState.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardCubit>().loadDashboardData();
                      context.read<TransactionCubit>().loadTransactions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (dashboardState is DashboardLoaded) {
            return BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, transactionState) {
                return BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, categoryState) {
                    final categories = categoryState is CategoryLoaded
                      ? categoryState.categories
                      : <Category>[];

                    final allTransactions = transactionState is TransactionLoaded
                      ? transactionState.transactions
                      : <Transaction>[];

                    if (transactionState is TransactionLoading) {
                      return const LoadingWidget();
                    }

                    return Column(
                      children: [

                        // Tab content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _OverviewTab(transactions: allTransactions, l10n: l10n),
                              _TrendsTab(transactions: allTransactions, l10n: l10n),
                              _CategoriesTab(
                                transactions: allTransactions,
                                categories: categories,
                                l10n: l10n,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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

class _OverviewTab extends StatefulWidget {
  final List<Transaction> transactions;
  final AppLocalizations l10n;

  const _OverviewTab({required this.transactions, required this.l10n});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  int? _selectedYear;
  int? _selectedMonth;
  bool _isFilterActive = false;

  List<Transaction> get _filteredTransactions {
    if (!_isFilterActive) {
      return widget.transactions;
    }

    return widget.transactions.where((transaction) {
      final transactionDate = transaction.date;

      if (_selectedYear != null && transactionDate.year != _selectedYear) {
        return false;
      }

      if (_selectedMonth != null && transactionDate.month != _selectedMonth) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = _filteredTransactions;

    // Calculate totals from filtered transactions
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpenses += transaction.amount;
      }
    }

    final balance = totalIncome - totalExpenses;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          _buildFilterSection(),
          const SizedBox(height: 16),
          // Balance Overview Cards
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: widget.l10n.totalIncome,
                  value: '\$${totalIncome.toStringAsFixed(2)}',
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: widget.l10n.totalExpenses,
                  value: '\$${totalExpenses.toStringAsFixed(2)}',
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetricCard(
            title: widget.l10n.netBalance,
            value: '\$${balance.toStringAsFixed(2)}',
            color: balance >= 0 ? Colors.green : Colors.red,
            icon: balance >= 0 ? Icons.trending_up : Icons.trending_down,
            isLarge: true,
          ),
          
          const SizedBox(height: 24),
          
          // Income vs Expenses Pie Chart
          Text(
            widget.l10n.incomeVsExpenses,
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
                      title: '${widget.l10n.income}\n\$${totalIncome.toStringAsFixed(0)}',
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
                      title: '${widget.l10n.expense}\n\$${totalExpenses.toStringAsFixed(0)}',
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
                      widget.l10n.noDataToDisplay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.l10n.addTransactionsToSeeCharts,
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

  Widget _buildFilterSection() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.filter,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      if (_isFilterActive)
                        Text(
                          _getFilterDescription(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isFilterActive)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      color: Colors.red,
                      tooltip: widget.l10n.clearFilter,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Controls
            Column(
              children: [
                // Year Picker
                _buildYearPicker(
                  label: widget.l10n.year,
                  value: _selectedYear,
                  onChanged: (year) {
                    setState(() {
                      _selectedYear = year;
                      if (_selectedYear == null) _selectedMonth = null;
                      _isFilterActive = _selectedYear != null || _selectedMonth != null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Month Picker
                _buildFilterDropdown(
                  label: widget.l10n.month,
                  value: _selectedMonth?.toString(),
                  icon: Icons.event,
                  items: _selectedYear != null ? _getMonthItems().map((item) =>
                    DropdownMenuItem(
                      value: item.value.toString(),
                      child: item.child!,
                    )
                  ).toList() : [],
                  onChanged: _selectedYear != null ? (value) {
                    setState(() {
                      _selectedMonth = value != null ? int.parse(value) : null;
                      _isFilterActive = _selectedYear != null || _selectedMonth != null;
                    });
                  } : null,
                  enabled: _selectedYear != null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
            ? (value != null ? theme.primaryColor : Colors.grey.shade300)
            : Colors.grey.shade300,
          width: enabled && value != null ? 2 : 1,
        ),
        boxShadow: enabled ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 16,
            color: enabled
              ? (value != null ? theme.primaryColor : Colors.grey.shade600)
              : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          labelStyle: TextStyle(
            color: enabled
              ? (value != null ? theme.primaryColor : Colors.grey.shade600)
              : Colors.grey.shade400,
            fontSize: 12,
            fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
          ),
          isDense: true,
        ),
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        dropdownColor: Colors.white,
        style: TextStyle(
          color: enabled ? Colors.black87 : Colors.grey.shade500,
          fontSize: 13,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: enabled ? theme.primaryColor : Colors.grey.shade400,
        ),
        isExpanded: true,
      ),
    );
  }

  String _getFilterDescription() {
    if (_selectedYear != null && _selectedMonth != null) {
      final months = [
        widget.l10n.january, widget.l10n.february, widget.l10n.march, widget.l10n.april,
        widget.l10n.may, widget.l10n.june, widget.l10n.july, widget.l10n.august,
        widget.l10n.september, widget.l10n.october, widget.l10n.november, widget.l10n.december,
      ];
      return '${months[_selectedMonth! - 1]} $_selectedYear';
    } else if (_selectedYear != null) {
      return '${widget.l10n.year} $_selectedYear';
    } else if (_selectedMonth != null) {
      final months = [
        widget.l10n.january, widget.l10n.february, widget.l10n.march, widget.l10n.april,
        widget.l10n.may, widget.l10n.june, widget.l10n.july, widget.l10n.august,
        widget.l10n.september, widget.l10n.october, widget.l10n.november, widget.l10n.december,
      ];
      return '${widget.l10n.month}: ${months[_selectedMonth! - 1]}';
    }
    return '';
  }

  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _isFilterActive = false;
    });
  }

  Widget _buildYearPicker({
    required String label,
    required int? value,
    required void Function(int?) onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? theme.primaryColor : Colors.grey.shade300,
          width: value != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showYearPicker(value, onChanged),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: value != null ? theme.primaryColor : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: value != null ? theme.primaryColor : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value?.toString() ?? 'Select year',
                      style: TextStyle(
                        color: value != null ? Colors.black87 : Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: value != null ? theme.primaryColor : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showYearPicker(int? currentYear, void Function(int?) onChanged) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.l10n.year),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1900), // No lower limit
              lastDate: DateTime(2200),   // No upper limit
              selectedDate: currentYear != null ? DateTime(currentYear) : now,
              onChanged: (DateTime dateTime) {
                onChanged(dateTime.year);
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.l10n.cancel),
            ),
            if (currentYear != null)
              TextButton(
                onPressed: () {
                  onChanged(null);
                  Navigator.of(context).pop();
                },
                child: Text(
                  widget.l10n.clearFilter,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<int>> _getMonthItems() {
    final months = [
      widget.l10n.january, widget.l10n.february, widget.l10n.march, widget.l10n.april,
      widget.l10n.may, widget.l10n.june, widget.l10n.july, widget.l10n.august,
      widget.l10n.september, widget.l10n.october, widget.l10n.november, widget.l10n.december,
    ];

    return List.generate(12, (index) {
      return DropdownMenuItem(
        value: index + 1,
        child: Text(months[index]),
      );
    });
  }
}

class _TrendsTab extends StatelessWidget {
  final List<Transaction> transactions;
  final AppLocalizations l10n;

  const _TrendsTab({required this.transactions, required this.l10n});

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
            l10n.dailyTrendsLast7Days,
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
              _LegendItem(color: Colors.green, label: l10n.income),
              const SizedBox(width: 24),
              _LegendItem(color: Colors.red, label: l10n.expense),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final AppLocalizations l10n;

  const _CategoriesTab({
    required this.transactions,
    required this.categories,
    required this.l10n,
  });

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  int? _selectedYear;
  int? _selectedMonth;
  bool _isFilterActive = false;

  List<Transaction> get _filteredTransactions {
    if (!_isFilterActive) {
      return widget.transactions;
    }

    return widget.transactions.where((transaction) {
      final transactionDate = transaction.date;

      if (_selectedYear != null && transactionDate.year != _selectedYear) {
        return false;
      }

      if (_selectedMonth != null && transactionDate.month != _selectedMonth) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = _filteredTransactions;

    // Create category lookup map
    final categoryMap = <String, Category>{};
    for (final category in widget.categories) {
      if (category.id != null) {
        categoryMap[category.id!] = category;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          _buildFilterSection(),
          const SizedBox(height: 16),
          // Income by Category Section
          _CategorySection(
            title: widget.l10n.incomeByCategory,
            transactionType: 'income',
            transactions: transactions,
            categoryMap: categoryMap,
            l10n: widget.l10n,
            emptyMessage: widget.l10n.noIncomeData,
            colors: const [
              Colors.green, Colors.teal, Colors.blue, Colors.indigo, Colors.cyan,
              Colors.lightGreen, Colors.blueGrey, Colors.deepPurple, Colors.lightBlue,
            ],
          ),

          const SizedBox(height: 32),

          // Expenses by Category Section
          _CategorySection(
            title: widget.l10n.expensesByCategory,
            transactionType: 'expense',
            transactions: transactions,
            categoryMap: categoryMap,
            l10n: widget.l10n,
            emptyMessage: widget.l10n.noExpenseData,
            colors: const [
              Colors.red, Colors.orange, Colors.pink, Colors.deepOrange, Colors.amber,
              Colors.purple, Colors.brown, Colors.redAccent, Colors.orangeAccent,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.filter,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      if (_isFilterActive)
                        Text(
                          _getFilterDescription(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isFilterActive)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 18),
                      color: Colors.red,
                      tooltip: widget.l10n.clearFilter,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Controls
            Column(
              children: [
                // Year Picker
                _buildYearPicker(
                  label: widget.l10n.year,
                  value: _selectedYear,
                  onChanged: (year) {
                    setState(() {
                      _selectedYear = year;
                      if (_selectedYear == null) _selectedMonth = null;
                      _isFilterActive = _selectedYear != null || _selectedMonth != null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Month Picker
                _buildFilterDropdown(
                  label: widget.l10n.month,
                  value: _selectedMonth?.toString(),
                  icon: Icons.event,
                  items: _selectedYear != null ? _getMonthItems().map((item) =>
                    DropdownMenuItem(
                      value: item.value.toString(),
                      child: item.child!,
                    )
                  ).toList() : [],
                  onChanged: _selectedYear != null ? (value) {
                    setState(() {
                      _selectedMonth = value != null ? int.parse(value) : null;
                      _isFilterActive = _selectedYear != null || _selectedMonth != null;
                    });
                  } : null,
                  enabled: _selectedYear != null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
            ? (value != null ? theme.primaryColor : Colors.grey.shade300)
            : Colors.grey.shade300,
          width: enabled && value != null ? 2 : 1,
        ),
        boxShadow: enabled ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 16,
            color: enabled
              ? (value != null ? theme.primaryColor : Colors.grey.shade600)
              : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          labelStyle: TextStyle(
            color: enabled
              ? (value != null ? theme.primaryColor : Colors.grey.shade600)
              : Colors.grey.shade400,
            fontSize: 12,
            fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
          ),
          isDense: true,
        ),
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        dropdownColor: Colors.white,
        style: TextStyle(
          color: enabled ? Colors.black87 : Colors.grey.shade500,
          fontSize: 13,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: enabled ? theme.primaryColor : Colors.grey.shade400,
        ),
        isExpanded: true,
      ),
    );
  }

  String _getFilterDescription() {
    if (_selectedYear != null && _selectedMonth != null) {
      final months = [
        widget.l10n.january, widget.l10n.february, widget.l10n.march, widget.l10n.april,
        widget.l10n.may, widget.l10n.june, widget.l10n.july, widget.l10n.august,
        widget.l10n.september, widget.l10n.october, widget.l10n.november, widget.l10n.december,
      ];
      return '${months[_selectedMonth! - 1]} $_selectedYear';
    } else if (_selectedYear != null) {
      return '${widget.l10n.year} $_selectedYear';
    } else if (_selectedMonth != null) {
      final months = [
        widget.l10n.january, widget.l10n.february, widget.l10n.march, widget.l10n.april,
        widget.l10n.may, widget.l10n.june, widget.l10n.july, widget.l10n.august,
        widget.l10n.september, widget.l10n.october, widget.l10n.november, widget.l10n.december,
      ];
      return '${widget.l10n.month}: ${months[_selectedMonth! - 1]}';
    }
    return '';
  }

  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _isFilterActive = false;
    });
  }

  Widget _buildYearPicker({
    required String label,
    required int? value,
    required void Function(int?) onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? theme.primaryColor : Colors.grey.shade300,
          width: value != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showYearPicker(value, onChanged),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: value != null ? theme.primaryColor : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: value != null ? theme.primaryColor : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value?.toString() ?? 'Select year',
                      style: TextStyle(
                        color: value != null ? Colors.black87 : Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: value != null ? theme.primaryColor : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showYearPicker(int? currentYear, void Function(int?) onChanged) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.l10n.year),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1900), // No lower limit
              lastDate: DateTime(2200),   // No upper limit
              selectedDate: currentYear != null ? DateTime(currentYear) : now,
              onChanged: (DateTime dateTime) {
                onChanged(dateTime.year);
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.l10n.cancel),
            ),
            if (currentYear != null)
              TextButton(
                onPressed: () {
                  onChanged(null);
                  Navigator.of(context).pop();
                },
                child: Text(
                  widget.l10n.clearFilter,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<int>> _getMonthItems() {
    final months = [
      widget.l10n.january, widget.l10n.february, widget.l10n.march, widget.l10n.april,
      widget.l10n.may, widget.l10n.june, widget.l10n.july, widget.l10n.august,
      widget.l10n.september, widget.l10n.october, widget.l10n.november, widget.l10n.december,
    ];

    return List.generate(12, (index) {
      return DropdownMenuItem(
        value: index + 1,
        child: Text(months[index]),
      );
    });
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final String transactionType;
  final List<Transaction> transactions;
  final Map<String, Category> categoryMap;
  final AppLocalizations l10n;
  final String emptyMessage;
  final List<Color> colors;

  const _CategorySection({
    required this.title,
    required this.transactionType,
    required this.transactions,
    required this.categoryMap,
    required this.l10n,
    required this.emptyMessage,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate category data for the specific transaction type
    final Map<String, double> categoryData = {};
    final Map<String, Color> categoryColors = {};

    for (final transaction in transactions) {
      if (transaction.type == transactionType) {
        final categoryId = transaction.categoryId;
        final category = categoryMap[categoryId];
        final categoryName = category?.getLocalizedName(l10n.localeName) ?? l10n.unknownCategory;

        categoryData[categoryName] = (categoryData[categoryName] ?? 0) + transaction.amount;

        if (!categoryColors.containsKey(categoryName)) {
          categoryColors[categoryName] = colors[categoryColors.length % colors.length];
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
                    emptyMessage,
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
            l10n.categoryBreakdown,
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
                title: Text(entry.key),
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
