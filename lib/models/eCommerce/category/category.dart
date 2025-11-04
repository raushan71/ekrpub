import 'dart:convert';

class Category {
  final int id;
  final String name;
  final String thumbnail;
  final List<SubCategory> subCategories;
  Category({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.subCategories,
  });

  Category copyWith({
    int? id,
    String? name,
    String? thumbnail,
    List<SubCategory>? subCategories,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'subCategories': subCategories.map((x) => x.toMap()).toList(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
        id: map['id'].toInt() as int,
        name: map['name'] as String,
        thumbnail: map['thumbnail'] as String,
        subCategories: List<SubCategory>.from(
            (map['sub_categories'] as List<dynamic>).map<SubCategory>(
                (x) => SubCategory.fromMap(x as Map<String, dynamic>))));
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Category(id: $id, name: $name, thumbnail: $thumbnail)';

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.thumbnail == thumbnail;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ thumbnail.hashCode;
}

class SubCategory {
  final int id;
  final String name;
  final String thumbnail;
  SubCategory({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  SubCategory copyWith({
    int? id,
    String? name,
    String? thumbnail,
  }) {
    return SubCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
    };
  }

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'].toInt() as int,
      name: map['name'] as String,
      thumbnail: map['thumbnail'] as String,
    );
  }
}
