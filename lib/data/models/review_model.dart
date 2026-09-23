class ReviewModel {
  final int id;
  final String author;
  final int rating;
  final String content;
  final String date;
  final String productName;
  final bool verified;

  ReviewModel({
    required this.id,
    required this.author,
    required this.rating,
    required this.content,
    required this.date,
    required this.productName,
    this.verified = true,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      author: json['author'] ?? 'Verified Buyer',
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating'].toString()) ?? 5,
      content: json['content'] ?? '',
      date: json['date'] ?? '',
      productName: json['product_name'] ?? 'Authentic Malaysian Product',
      verified: json['verified'] ?? true,
    );
  }
}
