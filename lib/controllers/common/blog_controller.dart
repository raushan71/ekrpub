import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/common/blog.dart';
import 'package:ekray/models/common/blog_details.dart';

import '../../services/common/blog_service_provider.dart';

class BlogListController extends StateNotifier<AsyncValue<BlogModel>> {
  final Ref ref;

  BlogListController(this.ref) : super(const AsyncLoading()) {
    getBlogList();
  }

  Future<void> getBlogList({
    int page = 1,
    int perPage = 20,
    int? categoryId,
  }) async {
    try {
      if (page == 1) state = const AsyncLoading();
      final response = await ref.read(blogServiceProvider).getBlogs(
            page: page,
            perPage: perPage,
            categoryId: categoryId,
          );

      // Parse the new data
      var newData = BlogModel.fromJson(response.data);

      // Combine old blogs with new blogs
      var currentBlogs = state.value?.data.blogs ?? [];
      var updatedBlogs = [...currentBlogs, ...newData.data.blogs];

      // Update the state with the new data
      state = AsyncData(
        newData.copyWith(
          data: newData.data.copyWith(blogs: updatedBlogs),
        ),
      );
    } catch (error) {
      debugPrint(error.toString());
      state = AsyncError(error, StackTrace.current);
    }
    return;
  }
}

final blogListControllerProvider =
    StateNotifierProvider<BlogListController, AsyncValue<BlogModel>>(
        (ref) => BlogListController(ref));

class BlogDetailsController extends StateNotifier<AsyncValue<BlogDetails>> {
  final Ref ref;
  final int blogId;
  BlogDetailsController({required this.ref, required this.blogId})
      : super(AsyncValue.loading()) {
    getBlogDetails(blogId: blogId);
  }

  Future<void> getBlogDetails({required int blogId}) async {
    try {
      final response =
          await ref.read(blogServiceProvider).getBlogDetails(blogId: blogId);
      state = AsyncData(BlogDetails.fromJson(response.data));
    } catch (error) {
      debugPrint(error.toString());
      state = AsyncError(error, StackTrace.current);
      rethrow;
    }
  }
}

final blogDetailsProvder = StateNotifierProvider.family<BlogDetailsController,
    AsyncValue<BlogDetails>, int>(
  (ref, blogId) => BlogDetailsController(
    ref: ref,
    blogId: blogId,
  ),
);
