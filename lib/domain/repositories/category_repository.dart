import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../../core/errors/failures.dart';

abstract class CategoryRepository {
  Future<Either<Failure, String>> addCategory(Category category);
  Future<Either<Failure, Category?>> getCategoryById(String id);
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<Either<Failure, List<Category>>> getCategoriesByType(String type);
  Future<Either<Failure, List<Category>>> getDefaultCategories();
  Future<Either<Failure, List<Category>>> getCustomCategories();
  Future<Either<Failure, void>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, bool>> categoryExists(String name, String type);
}
