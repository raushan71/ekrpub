import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/controllers/common/blog_controller.dart';
import 'package:ekray/models/common/blog.dart';

import '../../../../config/theme.dart';
import '../../../../utils/global_function.dart';
import '../componants/blog_card.dart';

class BlogsLayout extends StatelessWidget {
  const BlogsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Ready Blogs'),
      ),
      backgroundColor: colors(context).accentColor,
      body: Column(
        children: [
          _BlogFilterWidget(),
          _BlogListWidget(),
        ],
      ),
    );
  }
}

class _BlogFilterWidget extends ConsumerWidget {
  const _BlogFilterWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Categories> categories = ref.watch(categoriesProvider);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      height: 66.h,
      width: double.infinity,
      color: GlobalFunction.getContainerColor(),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.w),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...List.generate(
              categories.length + 1,
              (index) {
                if (index == 0) {
                  return BlogCategoryCard(
                    category: Categories(id: 0, name: 'All Brands'),
                    index: index,
                  );
                }
                index--;
                return BlogCategoryCard(
                  category: categories[index],
                  index: index,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _BlogListWidget extends ConsumerStatefulWidget {
  const _BlogListWidget();

  @override
  ConsumerState<_BlogListWidget> createState() => _BlogListWidgetState();
}

class _BlogListWidgetState extends ConsumerState<_BlogListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_srcollListener);
  }

  _srcollListener() {
    final blogListState = ref.read(blogListControllerProvider);

    // Ensure we are not already loading or there are no more pages to load
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !(blogListState is AsyncLoading && blogListState.value != null)) {
      final totalBlogs = blogListState.value!.data.total;
      final totalPages = (totalBlogs / perPageBlogs).ceil();
      if (pageCount < totalPages) {
        pageCount++;
        ref.read(blogListControllerProvider.notifier).getBlogList(
              page: pageCount,
              perPage: perPageBlogs,
              categoryId: ref.read(selectedBlogProvider).id,
            );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blogListControllerProvider);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        color: GlobalFunction.getContainerColor(),
        child: state.when(
          data: (data) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (ref.read(categoriesProvider).isEmpty) {
                ref.read(categoriesProvider.notifier).state =
                    data.data.categories;
              }
            });
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 16.h),
              itemCount: data.data.blogs.length,
              itemBuilder: (context, index) {
                return BlogCardWidget(
                  blog: data.data.blogs[index],
                );
              },
            );
          },
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class BlogCategoryCard extends ConsumerWidget {
  final Categories category;
  final int index;
  const BlogCategoryCard({
    super.key,
    required this.category,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isActive = ref.watch(selectedBlogProvider) == category;
    return GestureDetector(
      onTap: () {
        pageCount = 1;
        perPageBlogs = 10;
        ref.read(selectedBlogProvider.notifier).state = category;
        ref.read(blogListControllerProvider.notifier).getBlogList(
              page: pageCount,
              perPage: perPageBlogs,
              categoryId: category.id,
            );
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
            color: colors(context).accentColor,
            borderRadius: BorderRadius.circular(8.r),
            border: isActive
                ? Border.all(color: Theme.of(context).primaryColor)
                : null),
        child: Text(
          category.name,
          style: AppTextStyle(context).bodyText.copyWith(
                color: isActive ? colors(context).primaryColor : null,
              ),
        ),
      ),
    );
  }
}

int pageCount = 1;
int perPageBlogs = 20;

final selectedBlogProvider = StateProvider<Categories>((ref) => Categories(
      id: 0,
      name: 'All Brands',
    ));
final categoriesProvider = StateProvider<List<Categories>>((ref) => []);
