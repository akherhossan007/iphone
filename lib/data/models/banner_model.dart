class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final List<String> bgGradient;
  final String targetType;
  final String targetId;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.bgGradient,
    required this.targetType,
    required this.targetId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    List<String> grad = [];
    if (json['bg_gradient'] is List) {
      grad = (json['bg_gradient'] as List).map((e) => e.toString()).toList();
    }
    return BannerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      bgGradient: grad.isNotEmpty ? grad : ['#FF6B00', '#FF8E53'],
      targetType: json['target_type']?.toString() ?? 'category',
      targetId: json['target_id']?.toString() ?? '',
    );
  }
}

