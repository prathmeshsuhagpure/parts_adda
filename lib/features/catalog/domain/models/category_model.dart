class CategoryModel {
  final String id;
  final String name;
  final String? slug;
  final String? icon;
  final String? image;
  final String? parentId;
  final int level;
  final List<CategoryModel> children;
  final int partCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.image,
    this.parentId,
    this.level = 0,
    this.children = const [],
    this.partCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      name: json['name'],
      slug: json['slug'],
      icon: json['icon'],
      image: json['image'],
      parentId: json['parentId'],
      level: json['level'] ?? 0,
      children: (json['children'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      partCount: json['partCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "slug": slug,
      "icon": icon,
      "image": image,
      "parentId": parentId,
      "level": level,
      "children": children.map((e) => e.toJson()).toList(),
      "partCount": partCount,
    };
  }
}

class CategoryInfo {
  final String id;
  final String name;
  final String? slug;

  CategoryInfo({required this.id, required this.name, this.slug});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(id: json['_id'], name: json['name'], slug: json['slug']);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "slug": slug};
  }
}