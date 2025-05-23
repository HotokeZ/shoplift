/// Model class for a cart item
class CartItem {
  final String id; // Firestore document ID
  final String name;
  final double price;
  int quantity;
  final Map<String, String> varieties; // Map of variety type to selected value
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.varieties,
    this.imageUrl,
  });

  /// Calculate the total price for this item
  double get totalPrice => price * quantity;

  /// Create a `CartItem` from Firestore data
  factory CartItem.fromFirestore(String id, Map<String, dynamic> data) {
    return CartItem(
      id: id,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'] as int,
      varieties: Map<String, String>.from(data['varieties'] ?? {}),
      imageUrl: data['image'] as String?,
    );
  }

  /// Create a copy of this item with updated properties
  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    Map<String, String>? varieties,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      varieties: varieties ?? this.varieties,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Model class for the shopping cart
class Cart {
  List<CartItem> items;
  String couponCode;
  final double shippingCost;
  final double taxRate;

  Cart({
    required this.items,
    this.couponCode = '',
    this.shippingCost = 8.0,
    this.taxRate = 0.0,
  });

  /// Calculate the subtotal of all items in the cart
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Calculate the tax amount
  double get tax {
    return subtotal * taxRate;
  }

  /// Calculate the total price including shipping and tax
  double get total {
    return subtotal + shippingCost + tax;
  }

  /// Update the quantity of an item in the cart
  void updateQuantity(String id, int change) {
    final index = items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final newQuantity = items[index].quantity + change;
      if (newQuantity > 0) {
        items[index].quantity = newQuantity;
      }
    }
  }

  /// Remove all items from the cart
  void removeAll() {
    items.clear();
  }

  /// Apply a coupon code
  void applyCoupon(String code) {
    couponCode = code;
    // In a real app, this would validate the coupon and apply discounts
  }
}