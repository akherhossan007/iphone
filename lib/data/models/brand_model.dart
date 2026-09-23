class BrandModel {
  final dynamic id;
  final String name;
  final String slug;
  final String? customLogo;
  final int count;
  final String tagline;
  final String badge;

  BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.customLogo,
    this.count = 0,
    this.tagline = 'Malaysia Direct Import',
    this.badge = '100% Authentic',
  });

  String get logoUrl {
    if (customLogo != null && customLogo!.isNotEmpty) {
      return customLogo!;
    }
    final cleanSlug = slug.toLowerCase().trim().replaceAll(' ', '-');
    return 'https://glowbaybd.com/wp-content/themes/glowbayhp/assets/brands/$cleanSlug.png';
  }

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? (json['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? ''),
      customLogo: json['logo']?.toString() ?? json['image']?.toString() ?? json['logo_url']?.toString(),
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      tagline: json['tagline']?.toString() ?? 'Malaysia Direct Import',
      badge: json['badge']?.toString() ?? '100% Authentic',
    );
  }
}
