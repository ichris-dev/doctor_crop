// Farm model
class FarmModel {
  final String id;
  final String name;
  final String location;
  final double sizeInHectares;
  final List<String> crops;
  final DateTime createdAt;
  final String? imageUrl;
  final String farmerId;
  final FarmStatus status;

  FarmModel({
    required this.id,
    required this.name,
    required this.location,
    required this.sizeInHectares,
    required this.crops,
    required this.createdAt,
    this.imageUrl,
    required this.farmerId,
    this.status = FarmStatus.active,
  });
}

enum FarmStatus { active, dormant, harvested }

// Crop model
class CropModel {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String imageUrl;
  final List<String> commonDiseases;
  final String growingSeason;
  final String waterRequirement;

  CropModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrl,
    required this.commonDiseases,
    required this.growingSeason,
    required this.waterRequirement,
  });
}

// Disease model
class DiseaseModel {
  final String id;
  final String name;
  final String affectedCrop;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final String severity; // Low, Medium, High
  final String imageUrl;
  final List<String> similarDiseases;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.affectedCrop,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.severity,
    required this.imageUrl,
    this.similarDiseases = const [],
  });
}

// Product model
class ProductModel {
  final String id;
  final String name;
  final String category; // Fertilizer, Pesticide, Seed, etc.
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final String shopId;
  final String shopName;
  final String safetyInfo;
  final String usageInfo;
  bool isAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.currency = 'RWF',
    required this.imageUrl,
    required this.shopId,
    required this.shopName,
    required this.safetyInfo,
    required this.usageInfo,
    this.isAvailable = true,
  });
}

// Shop model
class ShopModel {
  final String id;
  final String name;
  final String ownerName;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String? email;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final bool isVerified;
  final double distanceKm;

  ShopModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.email,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.categories = const [],
    this.isVerified = false,
    this.distanceKm = 0.0,
  });
}

// Community post model
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final List<String> imageUrls;
  final PostCategory category;
  final DateTime createdAt;
  int likesCount;
  int commentsCount;
  bool isLiked;
  final List<String> tags;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.imageUrls = const [],
    this.category = PostCategory.general,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.tags = const [],
  });
}

enum PostCategory { general, diseaseAlert, harvest, advice, marketplace }

// Detection result model
class DetectionResult {
  final String diseaseName;
  final double confidence;
  final String description;
  final String treatment;
  final String severity;
  final List<String> similarDiseases;
  final DateTime detectedAt;

  DetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.treatment,
    required this.severity,
    this.similarDiseases = const [],
    required this.detectedAt,
  });
}
