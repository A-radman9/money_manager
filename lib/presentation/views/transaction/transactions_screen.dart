import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view_models/transaction/transaction_cubit.dart';
import '../../view_models/transaction/transaction_state.dart';
import '../../view_models/category/category_cubit.dart';
import '../../view_models/category/category_state.dart';
import '../../widgets/loading_and_empty_states.dart';
import '../../widgets/custom_date_picker.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/category.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../core/utils/currency_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  String _searchQuery = '';
  String? _selectedType;
  String? _selectedCategoryId;
  DateTime? _fromDate;
  DateTime? _toDate;
  double? _minAmount;
  double? _maxAmount;
  bool _isFilterActive = false;

  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().loadTransactions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allTransactions),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _isFilterActive ? Colors.amber : Colors.white,
            ),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransactionCubit>().loadTransactions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.primaryColor.withOpacity(0.1),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchTransactions,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ),
          // Transactions List
          Expanded(
            child: BlocListener<TransactionCubit, TransactionState>(
              listener: (context, state) {
                if (state is TransactionUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is TransactionDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is TransactionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
          if (state is TransactionLoading) {
            return const LoadingWidget();
          }
          
          if (state is TransactionError) {
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
                    'Error loading transactions',
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
                      context.read<TransactionCubit>().loadTransactions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start by adding your first transaction',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TransactionCubit>().loadTransactions();
              },
              child: _buildFilteredTransactionsList(state.transactions),
            );
          }

          return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredTransactionsList(List<Transaction> transactions) {
    final l10n = AppLocalizations.of(context)!;

    // Apply all filters
    final filteredTransactions = transactions.where((transaction) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final searchMatch = transaction.description.toLowerCase().contains(_searchQuery) ||
               transaction.amount.toString().contains(_searchQuery) ||
               (transaction.notes?.toLowerCase().contains(_searchQuery) ?? false) ||
               date_utils.DateUtils.formatDisplayDate(transaction.date, Localizations.localeOf(context).languageCode).toLowerCase().contains(_searchQuery);
        if (!searchMatch) return false;
      }

      // Type filter
      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }

      // Category filter
      if (_selectedCategoryId != null && transaction.categoryId != _selectedCategoryId) {
        return false;
      }

      // Date range filter
      if (_fromDate != null && transaction.date.isBefore(_fromDate!)) {
        return false;
      }
      if (_toDate != null && transaction.date.isAfter(_toDate!)) {
        return false;
      }

      // Amount range filter
      if (_minAmount != null && transaction.amount < _minAmount!) {
        return false;
      }
      if (_maxAmount != null && transaction.amount > _maxAmount!) {
        return false;
      }

      return true;
    }).toList();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isFilterActive || _searchQuery.isNotEmpty ? Icons.search_off : Icons.receipt_long,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isFilterActive
                ? l10n.noTransactionsMatchFilter
                : _searchQuery.isNotEmpty
                  ? '${l10n.noTransactionsFound} "$_searchQuery"'
                  : l10n.noTransactionsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isFilterActive
                ? l10n.adjustFilters
                : _searchQuery.isNotEmpty
                  ? l10n.tryAdjustingSearch
                  : l10n.addFirstTransaction,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _isFilterActive) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_searchQuery.isNotEmpty) ...[
                    ElevatedButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      child: Text(l10n.clearSearch),
                    ),
                    if (_isFilterActive) const SizedBox(width: 12),
                  ],
                  if (_isFilterActive) ...[
                    ElevatedButton(
                      onPressed: _resetFilters,
                      child: Text(l10n.resetFilters),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _TransactionListItem(
          transaction: transaction,
          onTap: () => _navigateToEditTransaction(transaction),
          onDelete: () => _showDeleteDialog(transaction),
        );
      },
    );
  }

  void _navigateToEditTransaction(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _showDeleteDialog(Transaction transaction) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteTransaction),
          content: Text('${l10n.deleteTransactionConfirm}\n"${transaction.description}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TransactionCubit>().deleteTransaction(transaction.id!);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedType: _selectedType,
        selectedCategoryId: _selectedCategoryId,
        fromDate: _fromDate,
        toDate: _toDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        onApplyFilters: (type, categoryId, fromDate, toDate, minAmount, maxAmount) {
          setState(() {
            _selectedType = type;
            _selectedCategoryId = categoryId;
            _fromDate = fromDate;
            _toDate = toDate;
            _minAmount = minAmount;
            _maxAmount = maxAmount;
            _isFilterActive = type != null ||
                            categoryId != null ||
                            fromDate != null ||
                            toDate != null ||
                            minAmount != null ||
                            maxAmount != null;
          });
        },
        onResetFilters: _resetFilters,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategoryId = null;
      _fromDate = null;
      _toDate = null;
      _minAmount = null;
      _maxAmount = null;
      _isFilterActive = false;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _TransactionListItem({
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == 'income';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isIncome 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.description,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              date_utils.DateUtils.formatDisplayDate(transaction.date, Localizations.localeOf(context).languageCode),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                transaction.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onTap?.call();
                } else if (value == 'delete') {
                  onDelete?.call();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final String? selectedType;
  final String? selectedCategoryId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minAmount;
  final double? maxAmount;
  final Function(String?, String?, DateTime?, DateTime?, double?, double?) onApplyFilters;
  final VoidCallback onResetFilters;

  const _FilterDialog({
    this.selectedType,
    this.selectedCategoryId,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String? _selectedType;
  late String? _selectedCategoryId;
  late DateTime? _fromDate;
  late DateTime? _toDate;
  late double? _minAmount;
  late double? _maxAmount;

  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedCategoryId = widget.selectedCategoryId;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    _minAmount = widget.minAmount;
    _maxAmount = widget.maxAmount;

    if (_minAmount != null) {
      _minAmountController.text = _minAmount.toString();
    }
    if (_maxAmount != null) {
      _maxAmountController.text = _maxAmount.toString();
    }

    // Load all categories
    context.read<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.filterTransactions),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Filter
              Text(
                l10n.transactionType,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  hintText: l10n.allTypes,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.allTypes),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.incomeType,
                    child: Text(l10n.income),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.expenseType,
                    child: Text(l10n.expense),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    // Reset category selection when transaction type changes
                    // or validate if current selection is still valid
                    _validateAndResetCategorySelection();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Category Filter
              Text(
                l10n.category,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    _categories = state.categories;

                    // Filter categories based on selected transaction type
                    List<Category> filteredCategories;
                    if (_selectedType == null) {
                      // Show all categories when "All Types" is selected
                      filteredCategories = state.categories;
                    } else {
                      // Show only categories matching the selected transaction type
                      filteredCategories = state.categories
                          .where((category) => category.type == _selectedType)
                          .toList();
                    }

                    // Check if selected category is still valid for the current filter
                    String? validCategoryId = _selectedCategoryId;
                    if (_selectedCategoryId != null) {
                      bool isValidCategory = filteredCategories
                          .any((category) => category.id == _selectedCategoryId);
                      if (!isValidCategory) {
                        validCategoryId = null;
                        // Update the state if the selection is invalid
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                          }
                        });
                      }
                    }

                    return DropdownButtonFormField<String>(
                      value: validCategoryId,
                      decoration: InputDecoration(
                        hintText: l10n.allCategories,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.allCategories),
                        ),
                        ...filteredCategories.map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                              ? (category.nameAr ?? category.name)
                              : category.name,
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),

              // Date Range Filter
              Text(
                l10n.dateRange,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  CustomDatePicker(
                    label: l10n.fromDate,
                    selectedDate: _fromDate,
                    onDateSelected: (date) {
                      setState(() {
                        _fromDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomDatePicker(
                    label: l10n.toDate,
                    selectedDate: _toDate,
                    onDateSelected: (date) {
                      setState(() {
                        _toDate = date;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount Range Filter
              Text(
                l10n.amountRange,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  TextFormField(
                    controller: _minAmountController,
                    decoration: InputDecoration(
                      labelText: l10n.minAmount,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minAmount = double.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _maxAmountController,
                    decoration: InputDecoration(
                      labelText: l10n.maxAmount,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxAmount = double.tryParse(value);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onResetFilters();
            Navigator.of(context).pop();
          },
          child: Text(l10n.resetFilters),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApplyFilters(
              _selectedType,
              _selectedCategoryId,
              _fromDate,
              _toDate,
              _minAmount,
              _maxAmount,
            );
            Navigator.of(context).pop();
          },
          child: Text(l10n.applyFilters),
        ),
      ],
    );
  }

  void _validateAndResetCategorySelection() {
    if (_selectedCategoryId != null && _categories.isNotEmpty) {
      // Find the selected category
      final selectedCategoryIndex = _categories.indexWhere(
        (category) => category.id == _selectedCategoryId,
      );

      // If category exists and transaction type is selected
      if (selectedCategoryIndex != -1 && _selectedType != null) {
        final selectedCategory = _categories[selectedCategoryIndex];
        // If category doesn't match the selected transaction type, reset selection
        if (selectedCategory.type != _selectedType) {
          _selectedCategoryId = null;
        }
      }
    }
  }
}
