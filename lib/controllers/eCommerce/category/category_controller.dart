import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/eCommerce/category/category.dart';
import 'package:ekray/services/eCommerce/category_service/category_service.dart';

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, AsyncValue<List<Category>>>(
        (ref) {
  final controller = CategoryController(ref);
  controller.getCategories();
  return controller;
});

class CategoryController extends StateNotifier<AsyncValue<List<Category>>> {
  final Ref ref;
  CategoryController(this.ref) : super(const AsyncLoading());

  Future<void> getCategories() async {
    try {
      final response = await ref.read(categoryServiceProvider).getCategories();
      final List<dynamic> data = response.data['data']['categories'];
      List<Category> categories =
          data.map((category) => Category.fromMap(category)).toList();
      state = AsyncData(categories);
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      state = AsyncError(error.toString(), stackTrace);
    }
  }
}

class SubCategoryController extends StateNotifier<bool> {
  final Ref ref;
  SubCategoryController(this.ref) : super(false);

  List<Category> _subCategories = [];

  List<Category> get subCategories => _subCategories;

  Future<void> getSubCategories({required int id}) async {
    try {
      state = true;
      final response =
          await ref.read(categoryServiceProvider).getSubCategories(id: id);
      List<dynamic> data = response.data['data']['sub_categories'];
      _subCategories =
          data.map((category) => Category.fromMap(category)).toList();
      debugPrint(_subCategories.length.toString());
      state = false;
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      state = false;
    }
  }
}

final subCategoryControllerProvider =
    StateNotifierProvider<SubCategoryController, bool>((ref) {
  return SubCategoryController(ref);
});
