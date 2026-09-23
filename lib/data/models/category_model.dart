class CategoryModel {
  final dynamic id;
  final String name;
  final String slug;
  final int count;
  final String image;
  final String icon;
  final List<CategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.count = 0,
    this.image = '',
    this.icon = 'sparkles',
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<CategoryModel> subs = [];
    if (json['subcategories'] is List) {
      for (var s in json['subcategories']) {
        if (s is Map<String, dynamic>) {
          subs.add(CategoryModel.fromJson(s));
        }
      }
    }
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'sparkles',
      subcategories: subs,
    );
  }
}

