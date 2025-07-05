import 'package:equatable/equatable.dart';
import '../../../domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryAdded extends CategoryState {
  final String categoryId;

  const CategoryAdded(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class CategoryUpdated extends CategoryState {}

class CategoryDeleted extends CategoryState {}

class CategoryOperationLoading extends CategoryState {}

class CategoryOperationSuccess extends CategoryState {
  final String message;

  const CategoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryValidationError extends CategoryState {
  final String message;

  const CategoryValidationError(this.message);

  @override
  List<Object?> get props => [message];
}
