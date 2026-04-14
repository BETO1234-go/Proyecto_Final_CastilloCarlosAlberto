enum MovementType { incoming, outgoing, adjustment }

class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.createdAt,
    required this.note,
  });

  final String id;
  final String productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final DateTime createdAt;
  final String note;
}
