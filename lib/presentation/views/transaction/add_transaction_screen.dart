import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view_models/transaction/transaction_cubit.dart';
import '../../view_models/transaction/transaction_state.dart';
import '../../view_models/category/category_cubit.dart';
import '../../view_models/category/category_state.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_date_picker.dart';
import '../../widgets/custom_button.dart';
import '../../../domain/entities/category.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? initialType;

  const AddTransactionScreen({
    super.key,
    this.initialType,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  late String _selectedType;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? AppConstants.expenseType;
    _loadCategories();
  }

  void _loadCategories() {
    context.read<CategoryCubit>().loadCategoriesByType(_selectedType);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTransaction),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TransactionCubit, TransactionState>(
            listener: (context, state) {
              if (state is TransactionAdded) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(true); // Return true to indicate success
              } else if (state is TransactionError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is TransactionOperationLoading) {
                setState(() => _isLoading = true);
              }
            },
          ),
        ],
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Selector
                _buildTypeSelector(l10n),
                const SizedBox(height: 24.0),
                
                // Amount Input
                AmountInputField(
                  label: l10n.amount,
                  controller: _amountController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterAmount;
                    }
                    if (!CurrencyUtils.isValidAmount(value)) {
                      return l10n.pleaseEnterValidAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                
                // Description Input
                CustomInputField(
                  label: l10n.description,
                  controller: _descriptionController,
                  hint: l10n.enterDescription,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterDescription;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                
                // Category Selection
                _buildCategorySelector(l10n),
                const SizedBox(height: 16.0),
                
                // Date Picker
                CustomDatePicker(
                  label: l10n.date,
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                
                // Notes Input
                CustomInputField(
                  label: '${l10n.notes} (${l10n.optional})',
                  controller: _notesController,
                  hint: l10n.addAnyAdditionalNotes,
                  maxLines: 3,
                ),
                const SizedBox(height: 32.0),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: l10n.save,
                    onPressed: _isLoading ? null : _saveTransaction,
                    isLoading: _isLoading,
                    backgroundColor: _selectedType == AppConstants.incomeType
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transactionType,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                AppConstants.expenseType,
                l10n.expense,
                Icons.remove_circle_outline,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildTypeOption(
                AppConstants.incomeType,
                l10n.income,
                Icons.add_circle_outline,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = null; // Reset category when type changes
        });
        _loadCategories();
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? color : theme.dividerColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : theme.iconTheme.color?.withOpacity(0.7),
              size: 32.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected ? color : theme.textTheme.titleSmall?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const SizedBox(
                height: 60.0,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (state is CategoryError) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '${l10n.errorLoadingCategories}: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            
            if (state is CategoryLoaded) {
              final categories = state.categories;
              
              if (categories.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Text('No categories available'),
                );
              }
              
              return Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: categories.map((category) {
                    final isSelected = _selectedCategory?.id == category.id;
                    return _buildCategoryChip(category, isSelected, l10n);
                  }).toList(),
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n.pleaseSelectCategory,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(Category category, bool isSelected, AppLocalizations l10n) {
    final color = Color(category.color);
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconData(category.icon),
              size: 16.0,
              color: color,
            ),
            const SizedBox(width: 6.0),
            Text(
              category.getLocalizedName(l10n.localeName),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case 'work': return Icons.work;
      case 'computer': return Icons.computer;
      case 'trending_up': return Icons.trending_up;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'attach_money': return Icons.attach_money;
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'movie': return Icons.movie;
      case 'receipt': return Icons.receipt;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'more_horiz': return Icons.more_horiz;
      default: return Icons.category;
    }
  }

  void _saveTransaction() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectCategory),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final amount = CurrencyUtils.parseAmount(_amountController.text);
    
    context.read<TransactionCubit>().addTransaction(
      amount: amount,
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategory!.id!,
      type: _selectedType,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }
}
