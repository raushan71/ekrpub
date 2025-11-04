class BlogModel {
  BlogModel({
    required this.message,
    required this.data,
  });
  late final String message;
  late final Data data;

  BlogModel copyWith({
    String? message,
    Data? data,
  }) =>
      BlogModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  BlogModel.fromJson(Map<String, dynamic> json) {
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
    required this.total,
    required this.blogs,
    required this.categories,
  });
  late final int total;
  late final List<Blogs> blogs;
  late final List<Categories> categories;

  Data copyWith({
    int? total,
    List<Blogs>? blogs,
    List<Categories>? categories,
  }) =>
      Data(
        total: total ?? this.total,
        blogs: blogs ?? this.blogs,
        categories: categories ?? this.categories,
      );

  Data.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    blogs = List.from(json['blogs']).map((e) => Blogs.fromJson(e)).toList();
    categories = List.from(json['categories'])
        .map((e) => Categories.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total'] = total;
    data['blogs'] = blogs.map((e) => e.toJson()).toList();
    data['categories'] = categories.map((e) => e.toJson()).toList();
    return data;
  }
}

class Blogs {
  Blogs({
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

  Blogs.fromJson(Map<String, dynamic> json) {
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

class Categories {
  Categories({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Categories &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Categories(id: $id, name: $name)';
}
