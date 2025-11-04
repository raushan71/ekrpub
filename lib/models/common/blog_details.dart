import 'package:ekray/models/common/blog.dart';
import 'package:ekray/models/eCommerce/product/product.dart';

class BlogDetails {
  BlogDetails({
    required this.message,
    required this.data,
  });
  late final String message;
  late final Data data;

  BlogDetails.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final data1 = <String, dynamic>{};
    data1['message'] = message;
    data1['data'] = data.toJson();
    return data1;
  }
}

class Data {
  Data({
    required this.blog,
    required this.relatedBlogs,
    required this.popularBlogs,
    required this.relatedProducts,
  });
  late final Blog blog;
  late final List<Blogs> relatedBlogs;
  late final List<Blogs> popularBlogs;
  late final List<Product> relatedProducts;

  Data.fromJson(Map<String, dynamic> json) {
    blog = Blog.fromJson(json['blog']);
    relatedBlogs =
        List.from(json['related_blogs']).map((e) => Blogs.fromJson(e)).toList();
    popularBlogs =
        List.from(json['popular_blogs']).map((e) => Blogs.fromJson(e)).toList();
    relatedProducts = List.from(json['related_products'])
        .map((e) => Product.fromMap(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['blog'] = blog.toJson();
    data['related_blogs'] = relatedBlogs;
    data['popular_blogs'] = popularBlogs.map((e) => e.toJson()).toList();
    data['related_products'] = relatedProducts.map((e) => e.toJson()).toList();
    return data;
  }
}

class Blog {
  Blog({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.postBy,
    required this.thumbnail,
    required this.totalViews,
    required this.description,
    required this.createdAt,
    required this.isNew,
    required this.tags,
  });
  late final int id;
  late final String title;
  late final String slug;
  late final Category category;
  late final PostBy postBy;
  late final String thumbnail;
  late final int totalViews;
  late final String description;
  late final String createdAt;
  late final bool isNew;
  late final List<Tag> tags;

  Blog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    category = Category.fromJson(json['category']);
    postBy = PostBy.fromJson(json['post_by']);
    thumbnail = json['thumbnail'];
    totalViews = json['total_views'];
    description = json['description'];
    createdAt = json['created_at'];
    isNew = json['is_new'];
    tags = List.from(json['tags']).map((e) => Tag.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['category'] = category.toJson();
    data['post_by'] = postBy.toJson();
    data['thumbnail'] = thumbnail;
    data['total_views'] = totalViews;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['is_new'] = isNew;
    data['tags'] = tags;
    return data;
  }
}

class Category {
  Category({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class PostBy {
  PostBy({
    required this.name,
    required this.profilePhoto,
  });
  late final String name;
  late final String profilePhoto;

  PostBy.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profilePhoto = json['profile_photo'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['profile_photo'] = profilePhoto;
    return data;
  }
}

class PopularBlogs {
  PopularBlogs({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.postBy,
    required this.thumbnail,
    required this.totalViews,
    required this.description,
    required this.createdAt,
    required this.isNew,
  });
  late final int id;
  late final String title;
  late final String slug;
  late final Category category;
  late final PostBy postBy;
  late final String thumbnail;
  late final int totalViews;
  late final String description;
  late final String createdAt;
  late final bool isNew;

  PopularBlogs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    category = Category.fromJson(json['category']);
    postBy = PostBy.fromJson(json['post_by']);
    thumbnail = json['thumbnail'];
    totalViews = json['total_views'];
    description = json['description'];
    createdAt = json['created_at'];
    isNew = json['is_new'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['category'] = category.toJson();
    data['post_by'] = postBy.toJson();
    data['thumbnail'] = thumbnail;
    data['total_views'] = totalViews;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['is_new'] = isNew;
    return data;
  }
}

class Tag {
  Tag({
    required this.id,
    required this.name,
    required this.slug,
  });
  late final int id;
  late final String name;
  late final String slug;

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }
}
