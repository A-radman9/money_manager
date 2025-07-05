import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view_models/category/category_cubit.dart';
import '../../view_models/category/category_state.dart';
import '../../../domain/entities/category.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;
  final String categoryType;

  const AddEditCategoryScreen({
    super.key,
    this.category,
    required this.categoryType,
  });

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedIcon = 'category';
  int _selectedColor = Colors.blue.value;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'food', 'icon': Icons.restaurant, 'label': 'Food'},
    {'name': 'transport', 'icon': Icons.directions_car, 'label': 'Transport'},
    {'name': 'shopping', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'name': 'entertainment', 'icon': Icons.movie, 'label': 'Entertainment'},
    {'name': 'bills', 'icon': Icons.receipt, 'label': 'Bills'},
    {'name': 'health', 'icon': Icons.local_hospital, 'label': 'Health'},
    {'name': 'education', 'icon': Icons.school, 'label': 'Education'},
    {'name': 'salary', 'icon': Icons.work, 'label': 'Salary'},
    {'name': 'business', 'icon': Icons.business, 'label': 'Business'},
    {'name': 'investment', 'icon': Icons.trending_up, 'label': 'Investment'},
    {'name': 'gift', 'icon': Icons.card_giftcard, 'label': 'Gift'},
    {'name': 'category', 'icon': Icons.category, 'label': 'Other'},
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
            
            if (state is CategoryAdded || state is CategoryUpdated) {
              Navigator.of(context).pop();
            } else if (state is CategoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is CategoryValidationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Name
                Text(
                  'Category Name',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      _getSelectedIconData(),
                      color: Color(_selectedColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    if (value.trim().length < 2) {
                      return 'Category name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Icon Selection
                Text(
                  'Select Icon',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableIcons.map((iconData) {
                      final isSelected = _selectedIcon == iconData['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIcon = iconData['name'];
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? Color(_selectedColor).withOpacity(0.2)
                              : theme.cardColor,
                            border: Border.all(
                              color: isSelected 
                                ? Color(_selectedColor)
                                : theme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                iconData['icon'],
                                color: isSelected 
                                  ? Color(_selectedColor)
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                                size: 24,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                iconData['label'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 8,
                                  color: isSelected 
                                    ? Color(_selectedColor)
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Color Selection
                Text(
                  'Select Color',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableColors.map((color) {
                      final isSelected = _selectedColor == color.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color.value;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Category' : 'Add Category',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSelectedIconData() {
    final iconData = _availableIcons.firstWhere(
      (icon) => icon['name'] == _selectedIcon,
      orElse: () => _availableIcons.last,
    );
    return iconData['icon'];
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    
    if (widget.category != null) {
      // Update existing category
      context.read<CategoryCubit>().updateCategory(
        id: widget.category!.id!,
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        type: widget.categoryType,
        isDefault: widget.category!.isDefault,
        createdAt: widget.category!.createdAt,
      );
    } else {
      // Add new category
      context.read<CategoryCubit>().addCategory(
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        type: widget.categoryType,
      );
    }
  }
}
