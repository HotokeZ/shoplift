class Product {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String altText;
  final double? originalPrice;
  bool isFavorite; // Added isFavorite property

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.altText,
    this.originalPrice,
    this.isFavorite = false, // Default value set to false
  });
}