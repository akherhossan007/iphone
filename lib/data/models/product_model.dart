class DescriptionBlock {
  final bool isImage;
  final String content;

  const DescriptionBlock({required this.isImage, required this.content});
}

class ProductAttributeModel {
  final String name;
  final String label;
  final List<String> options;

  ProductAttributeModel({
    required this.name,
    required this.label,
    required this.options,
  });

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    final opts = <String>[];
    if (json['options'] is List) {
      for (var o in json['options']) {
        if (o != null) opts.add(o.toString());
      }
    }
    return ProductAttributeModel(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      options: opts,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'label': label,
    'options': options,
  };
}

class ProductVariationModel {
  final int id;
  final String sku;
  final double price;
  final double regularPrice;
  final double? salePrice;
  final bool onSale;
  final bool inStock;
  final String stockStatus;
  final int? stockQuantity;
  final String image;
  final Map<String, dynamic> attributes;
  final double weightG;

  ProductVariationModel({
    required this.id,
    required this.sku,
    required this.price,
    required this.regularPrice,
    this.salePrice,
    required this.onSale,
    required this.inStock,
    required this.stockStatus,
    this.stockQuantity,
    required this.image,
    required this.attributes,
    required this.weightG,
  });

  String get attributeSummary {
    if (attributes.isEmpty) return '';
    return attributes.values.map((v) => v.toString()).join(' / ');
  }

  factory ProductVariationModel.fromJson(Map<String, dynamic> json) {
    final p = (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0;
    final rp = (json['regular_price'] != null) ? double.tryParse(json['regular_price'].toString()) ?? p : p;
    return ProductVariationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      sku: json['sku']?.toString() ?? '',
      price: p,
      regularPrice: rp > 0 ? rp : p,
      salePrice: json['sale_price'] != null ? double.tryParse(json['sale_price'].toString()) : null,
      onSale: json['on_sale'] == true,
      inStock: json['in_stock'] == true || json['stock_status'] == 'instock',
      stockStatus: json['stock_status']?.toString() ?? 'instock',
      stockQuantity: json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) : null,
      image: json['image']?.toString() ?? '',
      attributes: json['attributes'] is Map ? Map<String, dynamic>.from(json['attributes']) : {},
      weightG: (json['weight_g'] != null) ? double.tryParse(json['weight_g'].toString()) ?? 0.0 : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'price': price,
    'regular_price': regularPrice,
    'sale_price': salePrice,
    'on_sale': onSale,
    'in_stock': inStock,
    'stock_status': stockStatus,
    'stock_quantity': stockQuantity,
    'image': image,
    'attributes': attributes,
    'weight_g': weightG,
  };
}

class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String permalink;
  final double price;
  final double regularPrice;
  final double? salePrice;
  final bool onSale;
  final int discountPercentage;
  final String currency;
  final String image;
  final List<String> gallery;
  final bool inStock;
  final String stockStatus;
  final int? stockQuantity;
  final double weightG;
  final String sku;
  final List<String> brands;
  final List<String> brandSlugs;
  final List<int> brandIds;
  final List<String> categories;
  final List<int> categoryIds;
  final List<String> categorySlugs;
  final int? subCategoryId;
  final String subCategoryName;
  final String? subCategorySlug;
  final int totalSales;
  final int ratingCount;
  final double averageRating;
  final bool isAuthentic;
  final String origin;
  final String shortDescription;
  final String? descriptionHtml;
  final int soldPercentage;
  final Map<String, dynamic>? authenticityGuarantee;
  final Map<String, dynamic>? shippingInfo;
  final List<ProductModel> relatedProducts;
  final String type;
  final bool isVariable;
  final List<ProductAttributeModel> attributes;
  final List<ProductVariationModel> variations;
  final Map<String, dynamic> defaultAttributes;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.permalink,
    required this.price,
    required this.regularPrice,
    this.salePrice,
    required this.onSale,
    required this.discountPercentage,
    required this.currency,
    required this.image,
    required this.gallery,
    required this.inStock,
    required this.stockStatus,
    this.stockQuantity,
    required this.weightG,
    required this.sku,
    required this.brands,
    this.brandSlugs = const [],
    this.brandIds = const [],
    required this.categories,
    this.categoryIds = const [],
    this.categorySlugs = const [],
    this.subCategoryId,
    this.subCategoryName = '',
    this.subCategorySlug,
    required this.totalSales,
    required this.ratingCount,
    required this.averageRating,
    required this.isAuthentic,
    required this.origin,
    required this.shortDescription,
    this.descriptionHtml,
    this.soldPercentage = 45,
    this.authenticityGuarantee,
    this.shippingInfo,
    this.relatedProducts = const [],
    this.type = 'simple',
    this.isVariable = false,
    this.attributes = const [],
    this.variations = const [],
    this.defaultAttributes = const {},
  });

  bool get hasVariations => (isVariable || type == 'variable') && variations.isNotEmpty;

  double get rating => averageRating > 0 ? averageRating : 4.9;

  /// Returns weight in kilograms. Prioritizes multipacks (e.g. 3kg x 4 = 12kg), then WooCommerce weight, then title fallback.
  double get weightInKg {
    final lowerTitle = name.toLowerCase();

    // 1. Check title for multipack patterns (e.g. "3kg x 4", "3kg * 4", "3kg × 4", "4 x 3kg")
    final multiKg1 = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|kilo|liter|litre|l)\s*[xX*×]\s*(\d+)').firstMatch(lowerTitle);
    if (multiKg1 != null) {
      final perUnit = double.tryParse(multiKg1.group(1) ?? '0') ?? 0;
      final count = double.tryParse(multiKg1.group(2) ?? '1') ?? 1;
      if (perUnit > 0 && count > 0) return perUnit * count;
    }

    final multiKg2 = RegExp(r'(\d+)\s*[xX*×]\s*(\d+(?:\.\d+)?)\s*(?:kg|kilo|liter|litre|l)').firstMatch(lowerTitle);
    if (multiKg2 != null) {
      final count = double.tryParse(multiKg2.group(1) ?? '1') ?? 1;
      final perUnit = double.tryParse(multiKg2.group(2) ?? '0') ?? 0;
      if (perUnit > 0 && count > 0) return perUnit * count;
    }

    final multiGram1 = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g|gm|gram|ml)\s*[xX*×]\s*(\d+)').firstMatch(lowerTitle);
    if (multiGram1 != null) {
      final perUnitG = double.tryParse(multiGram1.group(1) ?? '0') ?? 0;
      final count = double.tryParse(multiGram1.group(2) ?? '1') ?? 1;
      if (perUnitG > 0 && count > 0) return (perUnitG * count) / 1000.0;
    }

    final multiGram2 = RegExp(r'(\d+)\s*[xX*×]\s*(\d+(?:\.\d+)?)\s*(?:g|gm|gram|ml)').firstMatch(lowerTitle);
    if (multiGram2 != null) {
      final count = double.tryParse(multiGram2.group(1) ?? '1') ?? 1;
      final perUnitG = double.tryParse(multiGram2.group(2) ?? '0') ?? 0;
      if (perUnitG > 0 && count > 0) return (perUnitG * count) / 1000.0;
    }

    // 2. Check WooCommerce meta weight if explicitly set
    if (weightG > 50) {
      // Numbers like 250, 500, 1000, 3000 are grams
      return weightG / 1000.0;
    }
    if (weightG > 0) {
      // Numbers like 0.5, 1, 3, 12 are kilograms
      return weightG;
    }

    // 3. Fallback: single item weight from product title (e.g. "12kg", "400g")
    final singleKgMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kg|kilo)\b').firstMatch(lowerTitle);
    if (singleKgMatch != null) {
      final val = double.tryParse(singleKgMatch.group(1) ?? '0') ?? 0;
      if (val > 0) return val;
    }
    final gramMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g|gm|gram)\b').firstMatch(lowerTitle);
    if (gramMatch != null) {
      final val = double.tryParse(gramMatch.group(1) ?? '0') ?? 0;
      if (val > 0) return (val / 1000.0).clamp(0.1, 50.0);
    }
    return 0.5; // Default fallback for cosmetics/skincare: 500g (0.5 kg)
  }

  List<DescriptionBlock> get descriptionBlocks {
    final raw = (descriptionHtml != null && descriptionHtml!.trim().isNotEmpty)
        ? descriptionHtml!
        : (shortDescription.trim().isNotEmpty ? shortDescription : '');

    if (raw.isEmpty) {
      return [
        const DescriptionBlock(
          isImage: false,
          content: 'Experience authentic Malaysian international formulation designed to hydrate, nourish and restore skin barrier. Sourced fresh from Kuala Lumpur authorized brand counters.',
        )
      ];
    }

    final imgRegex = RegExp(r"""<img[^>]+src=["']([^"']+)["'][^>]*>""", caseSensitive: false);
    final matches = imgRegex.allMatches(raw).toList();

    if (matches.isEmpty) {
      return [DescriptionBlock(isImage: false, content: _cleanHtml(raw))];
    }

    final List<DescriptionBlock> blocks = [];
    int lastEnd = 0;

    for (var m in matches) {
      if (m.start > lastEnd) {
        final textSlice = raw.substring(lastEnd, m.start);
        final cleaned = _cleanHtml(textSlice);
        if (cleaned.isNotEmpty) {
          blocks.add(DescriptionBlock(isImage: false, content: cleaned));
        }
      }

      final src = m.group(1);
      if (src != null && src.trim().isNotEmpty) {
        blocks.add(DescriptionBlock(isImage: true, content: src.trim()));
      }
      lastEnd = m.end;
    }

    if (lastEnd < raw.length) {
      final textSlice = raw.substring(lastEnd);
      final cleaned = _cleanHtml(textSlice);
      if (cleaned.isNotEmpty) {
        blocks.add(DescriptionBlock(isImage: false, content: cleaned));
      }
    }

    return blocks;
  }

  static String _cleanHtml(String text) {
    return text
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), ' • ')
        .replaceAll(RegExp(r'<h[1-6][^>]*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8211;', '-')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String get description {
    String raw = '';
    if (descriptionHtml != null && descriptionHtml!.trim().isNotEmpty) {
      raw = descriptionHtml!;
    } else if (shortDescription.trim().isNotEmpty) {
      raw = shortDescription;
    }

    if (raw.isEmpty) {
      return 'Experience authentic Malaysian international formulation designed to hydrate, nourish and restore skin barrier. Sourced fresh from Kuala Lumpur authorized brand counters.';
    }

    return _cleanHtml(raw);
  }

  int get routineStep => 1;
  String get howToUse => 'Apply evenly onto clean skin after cleansing and toning. Gently pat until fully absorbed. Suitable for daily morning and nighttime skincare routines.';
  String get ingredients => 'Key Actives: Hyaluronic Acid, 3 Essential Ceramides (1, 3, 6-II), Niacinamide, Centella Asiatica & Vitamin E.';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> brandList = [];
    List<String> brandSlugList = [];
    List<int> brandIdList = [];
    if (json['brands'] is List) {
      for (var b in json['brands']) {
        if (b is Map) {
          if (b['name'] != null) brandList.add(b['name'].toString());
          if (b['slug'] != null) brandSlugList.add(b['slug'].toString());
          if (b['id'] != null) {
            final parsedId = int.tryParse(b['id'].toString());
            if (parsedId != null) brandIdList.add(parsedId);
          }
        } else if (b is String) {
          brandList.add(b);
          brandSlugList.add(b.toLowerCase().trim().replaceAll(' ', '-'));
        }
      }
    }

    List<int> catIds = [];
    List<String> catSlugs = [];
    List<String> catList = [];
    String subName = '';
    int? subId;
    String? subSlug;

    if (json['categories'] is List) {
      const parentIds = {1735, 1672, 1675, 1690, 1607, 1687, 1752, 1680, 1696, 1843, 1695};
      const parentSlugs = {
        'skin-care', 'skincare', 'haircare', 'hair-care', 'personal-care',
        'baby-care', 'makeup', 'oralcare', 'oral-care', 'bath-body-2',
        'hand-foot-care', 'health', 'uncategorized'
      };
      const parentNames = {
        'skin care', 'skincare', 'hair care', 'haircare', 'personal care',
        'baby care', 'makeup', 'oral care', 'health', 'bath & body',
        'hand & foot care', 'uncategorized'
      };

      Map<String, dynamic>? selectedSubCat;

      for (var c in json['categories']) {
        if (c is Map) {
          final id = c['id'] is int ? c['id'] as int : int.tryParse(c['id']?.toString() ?? '') ?? 0;
          final name = c['name']?.toString() ?? '';
          final slug = c['slug']?.toString().toLowerCase() ?? '';
          final parent = c['parent'] is int ? c['parent'] as int : int.tryParse(c['parent']?.toString() ?? '') ?? 0;

          if (id > 0) catIds.add(id);
          if (slug.isNotEmpty) catSlugs.add(slug);
          if (name.isNotEmpty) catList.add(name);

          // Subcategory priority:
          // 1. Explicit parent > 0
          // 2. ID is not a top parent ID
          // 3. Slug is not a top parent slug
          if (parent > 0) {
            selectedSubCat = Map<String, dynamic>.from(c);
          } else if (selectedSubCat == null && id > 0 && !parentIds.contains(id)) {
            selectedSubCat = Map<String, dynamic>.from(c);
          } else if (selectedSubCat == null && slug.isNotEmpty && !parentSlugs.contains(slug) && !parentNames.contains(name.toLowerCase())) {
            selectedSubCat = Map<String, dynamic>.from(c);
          }
        } else if (c is String) {
          catList.add(c);
          final clean = c.toLowerCase().trim();
          if (selectedSubCat == null && !parentNames.contains(clean) && !parentSlugs.contains(clean)) {
            selectedSubCat = {
              'name': c,
              'slug': clean.replaceAll(' ', '-'),
            };
          }
        }
      }

      if (selectedSubCat == null && json['categories'].isNotEmpty) {
        final last = json['categories'].last;
        if (last is Map) {
          selectedSubCat = Map<String, dynamic>.from(last);
        } else if (last is String) {
          selectedSubCat = {
            'name': last,
            'slug': last.toLowerCase().trim().replaceAll(' ', '-'),
          };
        }
      }

      if (selectedSubCat != null) {
        subName = selectedSubCat['name']?.toString() ?? '';
        subId = selectedSubCat['id'] is int ? selectedSubCat['id'] as int : int.tryParse(selectedSubCat['id']?.toString() ?? '');
        subSlug = selectedSubCat['slug']?.toString();
      } else if (catList.isNotEmpty) {
        subName = catList.last;
      }
    }

    String mainImage = json['image']?.toString() ?? '';
    List<String> galList = [];
    if (json['images'] is List) {
      for (var img in json['images']) {
        if (img is Map && img['src'] != null && img['src'].toString().isNotEmpty) {
          galList.add(img['src'].toString());
        } else if (img is String && img.isNotEmpty) {
          galList.add(img);
        }
      }
      if (mainImage.isEmpty && galList.isNotEmpty) {
        mainImage = galList.first;
      }
    }
    if (json['gallery'] is List) {
      for (var g in json['gallery']) {
        if (g != null && g.toString().isNotEmpty) {
          if (!galList.contains(g.toString())) galList.add(g.toString());
        }
      }
    }
    if (mainImage.isEmpty && galList.isNotEmpty) {
      mainImage = galList.first;
    }

    List<ProductModel> related = [];
    if (json['related_products'] is List) {
      for (var r in json['related_products']) {
        if (r is Map<String, dynamic>) {
          related.add(ProductModel.fromJson(r));
        }
      }
    }

    List<ProductAttributeModel> attrList = [];
    if (json['attributes'] is List) {
      for (var a in json['attributes']) {
        if (a is Map<String, dynamic>) {
          attrList.add(ProductAttributeModel.fromJson(a));
        } else if (a is Map) {
          attrList.add(ProductAttributeModel.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }

    List<ProductVariationModel> varList = [];
    if (json['variations'] is List) {
      for (var v in json['variations']) {
        if (v is Map<String, dynamic>) {
          varList.add(ProductVariationModel.fromJson(v));
        } else if (v is Map) {
          varList.add(ProductVariationModel.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      permalink: json['permalink']?.toString() ?? '',
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      regularPrice: (json['regular_price'] != null && json['regular_price'].toString().isNotEmpty)
          ? double.tryParse(json['regular_price'].toString()) ?? 0.0
          : (json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0),
      salePrice: (json['sale_price'] != null && json['sale_price'].toString().isNotEmpty)
          ? double.tryParse(json['sale_price'].toString())
          : null,
      onSale: json['on_sale'] == true,
      discountPercentage: json['discount_percentage'] is int
          ? json['discount_percentage']
          : int.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? '৳',
      image: mainImage,
      gallery: galList.isNotEmpty ? galList : (mainImage.isNotEmpty ? [mainImage] : []),
      inStock: json['in_stock'] == true || json['stock_status'] == 'instock',
      stockStatus: json['stock_status']?.toString() ?? 'instock',
      stockQuantity: json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) : null,
      weightG: (json['weight'] != null && json['weight'].toString().isNotEmpty)
          ? double.tryParse(json['weight'].toString()) ?? 0.0
          : ((json['weight_g'] != null)
              ? double.tryParse(json['weight_g'].toString()) ?? 0.0
              : ((json['weight_kg'] != null)
                  ? double.tryParse(json['weight_kg'].toString()) ?? 0.0
                  : 0.0)),
      sku: json['sku']?.toString() ?? '',
      brands: brandList,
      brandSlugs: brandSlugList,
      brandIds: brandIdList,
      categories: catList,
      categoryIds: catIds,
      categorySlugs: catSlugs,
      subCategoryId: subId,
      subCategoryName: subName,
      subCategorySlug: subSlug,
      totalSales: json['total_sales'] is int ? json['total_sales'] : int.tryParse(json['total_sales']?.toString() ?? '0') ?? 0,
      ratingCount: json['rating_count'] is int ? json['rating_count'] : int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      averageRating: (json['average_rating'] != null) ? double.tryParse(json['average_rating'].toString()) ?? 5.0 : 5.0,
      isAuthentic: json['is_authentic'] != false,
      origin: json['origin']?.toString() ?? 'Malaysia',
      shortDescription: json['short_description']?.toString() ?? '',
      descriptionHtml: json['description_html']?.toString() ?? json['description']?.toString() ?? json['post_content']?.toString(),
      soldPercentage: json['sold_percentage'] is int ? json['sold_percentage'] : int.tryParse(json['sold_percentage']?.toString() ?? '45') ?? 45,
      authenticityGuarantee: json['authenticity_guarantee'] is Map<String, dynamic> ? json['authenticity_guarantee'] : null,
      shippingInfo: json['shipping_info'] is Map<String, dynamic> ? json['shipping_info'] : null,
      relatedProducts: related,
      type: json['type']?.toString() ?? (varList.isNotEmpty ? 'variable' : 'simple'),
      isVariable: json['is_variable'] == true || json['type'] == 'variable' || varList.isNotEmpty,
      attributes: attrList,
      variations: varList,
      defaultAttributes: json['default_attributes'] is Map ? Map<String, dynamic>.from(json['default_attributes']) : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'permalink': permalink,
      'price': price,
      'regular_price': regularPrice,
      'sale_price': salePrice,
      'on_sale': onSale,
      'discount_percentage': discountPercentage,
      'currency': currency,
      'image': image,
      'gallery': gallery,
      'in_stock': inStock,
      'stock_status': stockStatus,
      'stock_quantity': stockQuantity,
      'weight': weightG,
      'sku': sku,
      'brands': brands,
      'categories': categories,
      'category_ids': categoryIds,
      'category_slugs': categorySlugs,
      'sub_category_id': subCategoryId,
      'sub_category_name': subCategoryName,
      'sub_category_slug': subCategorySlug,
      'total_sales': totalSales,
      'rating_count': ratingCount,
      'average_rating': averageRating,
      'is_authentic': isAuthentic,
      'origin': origin,
      'short_description': shortDescription,
      'description_html': descriptionHtml,
      'sold_percentage': soldPercentage,
      'authenticity_guarantee': authenticityGuarantee,
      'shipping_info': shippingInfo,
      'type': type,
      'is_variable': isVariable,
      'attributes': attributes.map((a) => a.toJson()).toList(),
      'variations': variations.map((v) => v.toJson()).toList(),
      'default_attributes': defaultAttributes,
    };
  }
}
