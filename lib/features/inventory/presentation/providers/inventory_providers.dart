import 'dart:async';

import 'package:examen_final/features/inventory/data/repositories/inventory_repository.dart';
import 'package:examen_final/features/inventory/domain/entities/product.dart';
import 'package:examen_final/features/inventory/domain/entities/stock_movement.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  if (kIsWeb) {
    return InMemoryInventoryRepository();
  }
  return SqliteInventoryRepository();
});

final inventoryControllerProvider =
    StateNotifierProvider<InventoryController, InventoryState>((ref) {
      final repository = ref.watch(inventoryRepositoryProvider);
      final controller = InventoryController(repository: repository);
      controller.start();
      return controller;
    });

class InventoryState {
  const InventoryState({
    this.products = const [],
    this.movements = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final List<Product> products;
  final List<StockMovement> movements;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  List<Product> get filteredProducts {
    if (searchQuery.trim().isEmpty) {
      return products;
    }
    final query = searchQuery.toLowerCase();
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query),
        )
        .toList();
  }

  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get inventoryUnits => products.fold(0, (sum, p) => sum + p.stock);

  InventoryState copyWith({
    List<Product>? products,
    List<StockMovement>? movements,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      products: products ?? this.products,
      movements: movements ?? this.movements,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InventoryController extends StateNotifier<InventoryState> {
  InventoryController({required InventoryRepository repository})
    : _repository = repository,
      super(const InventoryState());

  final InventoryRepository _repository;

  void start() {
    unawaited(load());
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repository.listProducts();
      final movements = await _repository.listMovements();
      state = state.copyWith(
        products: products,
        movements: movements,
        isLoading: false,
        error: null,
      );
    } on StateError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query, error: null);
  }

  Future<void> createProduct(Product product) async {
    try {
      await _repository.createProduct(product);
      await load();
    } on StateError catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _repository.updateProduct(product);
      await load();
    } on StateError catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await load();
  }

  Future<void> applyMovement({
    required String productId,
    required MovementType type,
    required int quantity,
    required String note,
  }) async {
    try {
      await _repository.applyMovement(
        productId: productId,
        type: type,
        quantity: quantity,
        note: note,
      );
      await load();
    } on StateError catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  void clearError() {
    if (state.error == null) {
      return;
    }
    state = state.copyWith(error: null);
  }
}
