import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../core/constants/app_constants.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryCubit({required this.categoryRepository}) : super(CategoryInitial());

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    
    final result = await categoryRepository.getAllCategories();
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> loadCategoriesByType(String type) async {
    emit(CategoryLoading());
    
    final result = await categoryRepository.getCategoriesByType(type);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> loadDefaultCategories() async {
    emit(CategoryLoading());
    
    final result = await categoryRepository.getDefaultCategories();
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> loadCustomCategories() async {
    emit(CategoryLoading());
    
    final result = await categoryRepository.getCustomCategories();
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> addCategory({
    required String name,
    String? nameAr,
    required String icon,
    required int color,
    required String type,
  }) async {
    emit(CategoryOperationLoading());

    // Check if category already exists
    final existsResult = await categoryRepository.categoryExists(name, type);
    final categoryExists = existsResult.fold(
      (failure) => false,
      (exists) => exists,
    );

    if (categoryExists) {
      emit(CategoryValidationError('A category with this name already exists for $type'));
      return;
    }

    final now = DateTime.now();
    final category = Category(
      name: name,
      nameAr: nameAr,
      icon: icon,
      color: color,
      type: type,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    final result = await categoryRepository.addCategory(category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categoryId) {
        emit(CategoryAdded(categoryId));
        loadCategories(); // Reload categories after adding
      },
    );
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? nameAr,
    required String icon,
    required int color,
    required String type,
    required bool isDefault,
    required DateTime createdAt,
  }) async {
    emit(CategoryOperationLoading());

    final category = Category(
      id: id,
      name: name,
      nameAr: nameAr,
      icon: icon,
      color: color,
      type: type,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await categoryRepository.updateCategory(category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) {
        emit(CategoryUpdated());
        loadCategories(); // Reload categories after updating
      },
    );
  }

  Future<void> deleteCategory(String id) async {
    emit(CategoryOperationLoading());

    final result = await categoryRepository.deleteCategory(id);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) {
        emit(CategoryDeleted());
        loadCategories(); // Reload categories after deleting
      },
    );
  }

  Future<void> getCategoryById(String id) async {
    emit(CategoryLoading());

    final result = await categoryRepository.getCategoryById(id);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (category) {
        if (category != null) {
          emit(CategoryLoaded([category]));
        } else {
          emit(const CategoryError('Category not found'));
        }
      },
    );
  }

  List<Category> getIncomeCategories(List<Category> categories) {
    return categories.where((category) => category.type == AppConstants.incomeType).toList();
  }

  List<Category> getExpenseCategories(List<Category> categories) {
    return categories.where((category) => category.type == AppConstants.expenseType).toList();
  }

  void clearState() {
    emit(CategoryInitial());
  }
}
