import 'package:examen_final/core/database/database_factory_helper.dart';
import 'package:examen_final/features/inventory/domain/entities/product.dart';
import 'package:examen_final/features/inventory/domain/entities/stock_movement.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

abstract class InventoryRepository {
  Future<List<Product>> listProducts();
  Future<List<StockMovement>> listMovements();
  Future<void> upsertProducts(List<Product> products);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> applyMovement({
    required String productId,
    required MovementType type,
    required int quantity,
    required String note,
  });
}

class InMemoryInventoryRepository implements InventoryRepository {
  InMemoryInventoryRepository()
    : _products = _seedProducts.toList(),
      _movements = <StockMovement>[];

  final List<Product> _products;
  final List<StockMovement> _movements;
  final Uuid _uuid = const Uuid();

  static const List<Product> _seedProducts = [
    Product(
      id: 'api-1',
      sku: 'ALM-001',
      name: 'Taladro Industrial 20V',
      category: 'Herramientas',
      unit: 'pieza',
      stock: 18,
      minStock: 5,
      cost: 1350,
      price: 1890,
    ),
    Product(
      id: 'api-2',
      sku: 'ALM-002',
      name: 'Guante Nitrilo Reforzado',
      category: 'Seguridad',
      unit: 'par',
      stock: 76,
      minStock: 20,
      cost: 42,
      price: 79,
    ),
    Product(
      id: 'api-3',
      sku: 'ALM-003',
      name: 'Disco Corte 4.5"',
      category: 'Consumibles',
      unit: 'pieza',
      stock: 140,
      minStock: 30,
      cost: 16,
      price: 28,
    ),
    Product(
      id: 'api-4',
      sku: 'ALM-004',
      name: 'Multimetro Digital Pro',
      category: 'Electricidad',
      unit: 'pieza',
      stock: 12,
      minStock: 4,
      cost: 640,
      price: 980,
    ),
    Product(
      id: 'api-5',
      sku: 'ALM-005',
      name: 'Cinta Aislante Premium',
      category: 'Electricidad',
      unit: 'pieza',
      stock: 95,
      minStock: 25,
      cost: 12,
      price: 24,
    ),
    Product(
      id: 'api-6',
      sku: 'ALM-006',
      name: 'Llave Ajustable 10"',
      category: 'Herramientas',
      unit: 'pieza',
      stock: 24,
      minStock: 8,
      cost: 110,
      price: 189,
    ),
    Product(
      id: 'api-7',
      sku: 'ALM-007',
      name: 'Martillo de Una',
      category: 'Herramientas',
      unit: 'pieza',
      stock: 35,
      minStock: 10,
      cost: 95,
      price: 169,
    ),
    Product(
      id: 'api-8',
      sku: 'ALM-008',
      name: 'Juego de Destornilladores 6 pzas',
      category: 'Herramientas',
      unit: 'juego',
      stock: 20,
      minStock: 6,
      cost: 185,
      price: 320,
    ),
    Product(
      id: 'api-9',
      sku: 'ALM-009',
      name: 'Pinza de Corte Diagonal',
      category: 'Herramientas',
      unit: 'pieza',
      stock: 28,
      minStock: 8,
      cost: 120,
      price: 210,
    ),
    Product(
      id: 'api-10',
      sku: 'ALM-010',
      name: 'Casco de Seguridad ABS',
      category: 'Seguridad',
      unit: 'pieza',
      stock: 42,
      minStock: 12,
      cost: 135,
      price: 240,
    ),
    Product(
      id: 'api-11',
      sku: 'ALM-011',
      name: 'Lentes de Seguridad Antiempano',
      category: 'Seguridad',
      unit: 'pieza',
      stock: 60,
      minStock: 15,
      cost: 48,
      price: 95,
    ),
    Product(
      id: 'api-12',
      sku: 'ALM-012',
      name: 'Chaleco Reflectante',
      category: 'Seguridad',
      unit: 'pieza',
      stock: 33,
      minStock: 10,
      cost: 75,
      price: 139,
    ),
    Product(
      id: 'api-13',
      sku: 'ALM-013',
      name: 'Bota de Seguridad Talla 42',
      category: 'Seguridad',
      unit: 'par',
      stock: 18,
      minStock: 6,
      cost: 520,
      price: 790,
    ),
    Product(
      id: 'api-14',
      sku: 'ALM-014',
      name: 'Extintor PQS 4.5kg',
      category: 'Seguridad',
      unit: 'pieza',
      stock: 9,
      minStock: 3,
      cost: 780,
      price: 1120,
    ),
    Product(
      id: 'api-15',
      sku: 'ALM-015',
      name: 'Cable THW 12 AWG Rojo',
      category: 'Electricidad',
      unit: 'metro',
      stock: 220,
      minStock: 80,
      cost: 14,
      price: 24,
    ),
    Product(
      id: 'api-16',
      sku: 'ALM-016',
      name: 'Cable THW 12 AWG Negro',
      category: 'Electricidad',
      unit: 'metro',
      stock: 210,
      minStock: 80,
      cost: 14,
      price: 24,
    ),
    Product(
      id: 'api-17',
      sku: 'ALM-017',
      name: 'Interruptor Termomagnetico 20A',
      category: 'Electricidad',
      unit: 'pieza',
      stock: 40,
      minStock: 12,
      cost: 88,
      price: 150,
    ),
    Product(
      id: 'api-18',
      sku: 'ALM-018',
      name: 'Contacto Doble Polarizado',
      category: 'Electricidad',
      unit: 'pieza',
      stock: 55,
      minStock: 20,
      cost: 22,
      price: 45,
    ),
    Product(
      id: 'api-19',
      sku: 'ALM-019',
      name: 'Conector Rapido 3 vias',
      category: 'Electricidad',
      unit: 'pieza',
      stock: 160,
      minStock: 50,
      cost: 6,
      price: 12,
    ),
    Product(
      id: 'api-20',
      sku: 'ALM-020',
      name: 'Tornillo Pija 1 pulgada',
      category: 'Consumibles',
      unit: 'caja',
      stock: 48,
      minStock: 15,
      cost: 58,
      price: 110,
    ),
    Product(
      id: 'api-21',
      sku: 'ALM-021',
      name: 'Taquete Plastico 1/4',
      category: 'Consumibles',
      unit: 'caja',
      stock: 52,
      minStock: 16,
      cost: 40,
      price: 85,
    ),
    Product(
      id: 'api-22',
      sku: 'ALM-022',
      name: 'Silicon Multiusos Transparente',
      category: 'Consumibles',
      unit: 'pieza',
      stock: 30,
      minStock: 10,
      cost: 38,
      price: 72,
    ),
    Product(
      id: 'api-23',
      sku: 'ALM-023',
      name: 'Cinta de Ducto 48mm',
      category: 'Consumibles',
      unit: 'pieza',
      stock: 44,
      minStock: 12,
      cost: 36,
      price: 68,
    ),
    Product(
      id: 'api-24',
      sku: 'ALM-024',
      name: 'Lubricante Aflojatodo 400ml',
      category: 'Consumibles',
      unit: 'pieza',
      stock: 26,
      minStock: 8,
      cost: 64,
      price: 120,
    ),
  ];

  @override
  Future<List<Product>> listProducts() async => List.unmodifiable(_products);

  @override
  Future<List<StockMovement>> listMovements() async {
    final sorted = _movements.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> upsertProducts(List<Product> products) async {
    for (final incoming in products) {
      final index = _products.indexWhere(
        (item) => item.sku.toLowerCase() == incoming.sku.toLowerCase(),
      );
      if (index >= 0) {
        _products[index] = incoming.copyWith(
          id: _products[index].id,
          updatedAt: DateTime.now(),
        );
      } else {
        _products.add(
          incoming.id.isEmpty
              ? incoming.copyWith(id: _uuid.v4(), updatedAt: DateTime.now())
              : incoming,
        );
      }
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    final newItem = product.copyWith(id: _uuid.v4(), updatedAt: DateTime.now());
    _products.add(newItem);
    return newItem;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index < 0) {
      throw StateError('Producto no encontrado');
    }
    final updated = product.copyWith(updatedAt: DateTime.now());
    _products[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    _movements.removeWhere((m) => m.productId == id);
  }

  @override
  Future<void> applyMovement({
    required String productId,
    required MovementType type,
    required int quantity,
    required String note,
  }) async {
    if (quantity <= 0) {
      throw StateError('La cantidad debe ser mayor a cero');
    }

    final index = _products.indexWhere((p) => p.id == productId);
    if (index < 0) {
      throw StateError('Producto no encontrado');
    }

    final product = _products[index];
    final updatedStock = switch (type) {
      MovementType.incoming => product.stock + quantity,
      MovementType.outgoing => product.stock - quantity,
      MovementType.adjustment => quantity,
    };

    if (updatedStock < 0) {
      throw StateError('Stock insuficiente para esta salida');
    }

    _products[index] = product.copyWith(
      stock: updatedStock,
      updatedAt: DateTime.now(),
    );
    _movements.add(
      StockMovement(
        id: _uuid.v4(),
        productId: product.id,
        productName: product.name,
        type: type,
        quantity: quantity,
        createdAt: DateTime.now(),
        note: note,
      ),
    );
  }
}

class SqliteInventoryRepository implements InventoryRepository {
  SqliteInventoryRepository({DatabaseFactory? databaseFactory})
    : _databaseFactory = databaseFactory ?? resolveDatabaseFactory();

  final DatabaseFactory _databaseFactory;
  final Uuid _uuid = const Uuid();
  Database? _db;

  Future<Database> _database() async {
    if (_db != null) {
      return _db!;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(docsDir.path, 'inventory_app.db');
    _db = await _databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE products (
              id TEXT PRIMARY KEY,
              sku TEXT NOT NULL UNIQUE,
              name TEXT NOT NULL,
              category TEXT NOT NULL,
              unit TEXT NOT NULL,
              stock INTEGER NOT NULL,
              min_stock INTEGER NOT NULL,
              cost REAL NOT NULL,
              price REAL NOT NULL,
              updated_at TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE movements (
              id TEXT PRIMARY KEY,
              product_id TEXT NOT NULL,
              product_name TEXT NOT NULL,
              type TEXT NOT NULL,
              quantity INTEGER NOT NULL,
              created_at TEXT NOT NULL,
              note TEXT NOT NULL
            )
          ''');

          await db.execute('CREATE INDEX idx_products_sku ON products (sku)');
          await db.execute('CREATE INDEX idx_products_name ON products (name)');
          await db.execute(
            'CREATE INDEX idx_movements_product ON movements (product_id)',
          );
          await db.execute(
            'CREATE INDEX idx_movements_created ON movements (created_at DESC)',
          );
        },
      ),
    );

    await _seedIfNeeded(_db!);
    return _db!;
  }

  Future<void> _seedIfNeeded(Database db) async {
    for (final item in InMemoryInventoryRepository._seedProducts) {
      final existing = await db.query(
        'products',
        columns: ['id'],
        where: 'sku = ?',
        whereArgs: [item.sku],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        continue;
      }
      await db.insert('products', _productToMap(item));
    }
  }

  @override
  Future<List<Product>> listProducts() async {
    final db = await _database();
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map(_productFromMap).toList();
  }

  @override
  Future<List<StockMovement>> listMovements() async {
    final db = await _database();
    final rows = await db.query('movements', orderBy: 'created_at DESC');
    return rows.map(_movementFromMap).toList();
  }

  @override
  Future<void> upsertProducts(List<Product> products) async {
    final db = await _database();
    await db.transaction((txn) async {
      for (final product in products) {
        final existing = await txn.query(
          'products',
          columns: ['id'],
          where: 'sku = ?',
          whereArgs: [product.sku],
          limit: 1,
        );

        if (existing.isEmpty) {
          final item = product.id.isEmpty
              ? product.copyWith(id: _uuid.v4(), updatedAt: DateTime.now())
              : product;
          await txn.insert(
            'products',
            _productToMap(item),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          final merged = product.copyWith(
            id: existing.first['id'] as String,
            updatedAt: DateTime.now(),
          );
          await txn.update(
            'products',
            _productToMap(merged),
            where: 'id = ?',
            whereArgs: [merged.id],
          );
        }
      }
    });
  }

  @override
  Future<Product> createProduct(Product product) async {
    final db = await _database();
    final item = product.copyWith(id: _uuid.v4(), updatedAt: DateTime.now());
    try {
      await db.insert('products', _productToMap(item));
      return item;
    } on DatabaseException {
      throw StateError('No se pudo crear el producto. Verifica SKU unico.');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final db = await _database();
    final item = product.copyWith(updatedAt: DateTime.now());
    final affected = await db.update(
      'products',
      _productToMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    if (affected == 0) {
      throw StateError('Producto no encontrado');
    }
    return item;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await _database();
    await db.transaction((txn) async {
      await txn.delete('movements', where: 'product_id = ?', whereArgs: [id]);
      await txn.delete('products', where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<void> applyMovement({
    required String productId,
    required MovementType type,
    required int quantity,
    required String note,
  }) async {
    if (quantity <= 0) {
      throw StateError('La cantidad debe ser mayor a cero');
    }

    final db = await _database();
    await db.transaction((txn) async {
      final productRows = await txn.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );
      if (productRows.isEmpty) {
        throw StateError('Producto no encontrado');
      }

      final product = _productFromMap(productRows.first);
      final updatedStock = switch (type) {
        MovementType.incoming => product.stock + quantity,
        MovementType.outgoing => product.stock - quantity,
        MovementType.adjustment => quantity,
      };

      if (updatedStock < 0) {
        throw StateError('Stock insuficiente para esta salida');
      }

      final updatedProduct = product.copyWith(
        stock: updatedStock,
        updatedAt: DateTime.now(),
      );
      await txn.update(
        'products',
        _productToMap(updatedProduct),
        where: 'id = ?',
        whereArgs: [productId],
      );

      await txn.insert('movements', {
        'id': _uuid.v4(),
        'product_id': product.id,
        'product_name': product.name,
        'type': type.name,
        'quantity': quantity,
        'created_at': DateTime.now().toIso8601String(),
        'note': note,
      });
    });
  }

  Product _productFromMap(Map<String, Object?> row) {
    return Product(
      id: row['id'] as String,
      sku: row['sku'] as String,
      name: row['name'] as String,
      category: row['category'] as String,
      unit: row['unit'] as String,
      stock: row['stock'] as int,
      minStock: row['min_stock'] as int,
      cost: (row['cost'] as num).toDouble(),
      price: (row['price'] as num).toDouble(),
      updatedAt: row['updated_at'] == null
          ? null
          : DateTime.tryParse(row['updated_at'] as String),
    );
  }

  Map<String, Object?> _productToMap(Product item) {
    return {
      'id': item.id,
      'sku': item.sku,
      'name': item.name,
      'category': item.category,
      'unit': item.unit,
      'stock': item.stock,
      'min_stock': item.minStock,
      'cost': item.cost,
      'price': item.price,
      'updated_at': item.updatedAt?.toIso8601String(),
    };
  }

  StockMovement _movementFromMap(Map<String, Object?> row) {
    return StockMovement(
      id: row['id'] as String,
      productId: row['product_id'] as String,
      productName: row['product_name'] as String,
      type: MovementType.values.firstWhere((item) => item.name == row['type']),
      quantity: row['quantity'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      note: row['note'] as String,
    );
  }
}
