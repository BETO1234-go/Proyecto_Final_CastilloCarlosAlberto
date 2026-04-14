class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.minStock,
    required this.cost,
    required this.price,
    this.updatedAt,
  });

  final String id;
  final String sku;
  final String name;
  final String category;
  final String unit;
  final int stock;
  final int minStock;
  final double cost;
  final double price;
  final DateTime? updatedAt;

  bool get isLowStock => stock <= minStock;

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? category,
    String? unit,
    int? stock,
    int? minStock,
    double? cost,
    double? price,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
