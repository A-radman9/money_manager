import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view_models/category/category_cubit.dart';
import '../../view_models/category/category_state.dart';
import '../../widgets/loading_and_empty_states.dart';
import '../../../domain/entities/category.dart';
import 'add_edit_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Categories'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Income', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Expense', icon: Icon(Icons.arrow_upward)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddCategory(),
          ),
        ],
      ),
      body: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CategoryUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CategoryDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
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
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _CategoryList(type: 'income'),
            _CategoryList(type: 'expense'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCategory(),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToAddCategory() {
    final currentType = _tabController.index == 0 ? 'income' : 'expense';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(
          categoryType: currentType,
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final String type;
  
  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const LoadingWidget();
        }
        
        if (state is CategoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading categories',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<CategoryCubit>().loadCategories();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is CategoryLoaded) {
          final categories = state.categories.where((cat) => cat.type == type).toList();
          
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${type} categories yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CategoryCubit>().loadCategories();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryListItem(
                  category: category,
                  onEdit: () => _navigateToEditCategory(context, category),
                  onDelete: () => _showDeleteDialog(context, category),
                );
              },
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToEditCategory(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(
          category: category,
          categoryType: category.type,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text('Are you sure you want to delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CategoryCubit>().deleteCategory(category.id!);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _CategoryListItem({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(category.color);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            _getIconData(category.icon),
            color: color,
          ),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          category.isDefault ? 'Default category' : 'Custom category',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: theme.colorScheme.primary,
            ),
            if (!category.isDefault)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }
}
