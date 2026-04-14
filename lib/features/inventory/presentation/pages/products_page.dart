import 'package:examen_final/features/inventory/domain/entities/product.dart';
import 'package:examen_final/features/inventory/presentation/pages/barcode_scanner_page.dart';
import 'package:examen_final/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:examen_final/features/inventory/presentation/widgets/product_barcode_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryControllerProvider);
    final controller = ref.read(inventoryControllerProvider.notifier);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: r'$');

    ref.listen(inventoryControllerProvider.select((s) => s.error), (
      previous,
      next,
    ) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next)));
        controller.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => _showProductForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              if (state.isLoading) const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar por nombre, SKU o categoria',
                  suffixIcon: IconButton(
                    tooltip: 'Escanear codigo',
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      final scanResult = await Navigator.of(context)
                          .push<String>(
                            MaterialPageRoute(
                              builder: (_) => const BarcodeScannerPage(),
                            ),
                          );
                      if (scanResult == null || scanResult.trim().isEmpty) {
                        return;
                      }
                      controller.updateSearch(scanResult.trim());
                    },
                  ),
                ),
                onChanged: controller.updateSearch,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.filteredProducts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = state.filteredProducts[index];
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 560;
                          if (compact) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE2E7ED),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.sku}  ${product.category}  ${product.unit}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Chip(
                                          backgroundColor: product.isLowStock
                                              ? const Color(0xFFFFE3D2)
                                              : const Color(0xFFDDF4EB),
                                          label: Text(
                                            'Stock: ${product.stock}',
                                          ),
                                        ),
                                        Text(
                                          currency.format(product.price),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Codigo de barras',
                                          icon: const Icon(Icons.view_column),
                                          onPressed: () =>
                                              _showBarcode(context, product),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () async =>
                                              _showProductForm(
                                                context,
                                                ref,
                                                product: product,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () async {
                                            await controller.deleteProduct(
                                              product.id,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                              '${product.sku}  ${product.category}  ${product.unit}',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Chip(
                                  backgroundColor: product.isLowStock
                                      ? const Color(0xFFFFE3D2)
                                      : const Color(0xFFDDF4EB),
                                  label: Text('Stock: ${product.stock}'),
                                ),
                                Text(currency.format(product.price)),
                                IconButton(
                                  tooltip: 'Codigo de barras',
                                  icon: const Icon(Icons.view_column),
                                  onPressed: () =>
                                      _showBarcode(context, product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () async => _showProductForm(
                                    context,
                                    ref,
                                    product: product,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await controller.deleteProduct(product.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showProductForm(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
  }

  void _showBarcode(BuildContext context, Product product) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF2F4F7),
      isScrollControlled: true,
      builder: (_) => ProductBarcodeSheet(product: product),
    );
  }
}

class ProductFormDialog extends ConsumerStatefulWidget {
  const ProductFormDialog({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  late final TextEditingController _sku;
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _unit;
  late final TextEditingController _stock;
  late final TextEditingController _minStock;
  late final TextEditingController _cost;
  late final TextEditingController _price;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final item = widget.product;
    _sku = TextEditingController(text: item?.sku ?? '');
    _name = TextEditingController(text: item?.name ?? '');
    _category = TextEditingController(text: item?.category ?? '');
    _unit = TextEditingController(text: item?.unit ?? 'pieza');
    _stock = TextEditingController(text: item?.stock.toString() ?? '0');
    _minStock = TextEditingController(text: item?.minStock.toString() ?? '0');
    _cost = TextEditingController(text: item?.cost.toString() ?? '0');
    _price = TextEditingController(text: item?.price.toString() ?? '0');
  }

  @override
  void dispose() {
    _sku.dispose();
    _name.dispose();
    _category.dispose();
    _unit.dispose();
    _stock.dispose();
    _minStock.dispose();
    _cost.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.product == null ? 'Nuevo producto' : 'Editar producto',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Wrap(
              runSpacing: 10,
              children: [
                _field(_sku, 'SKU'),
                _field(_name, 'Nombre'),
                _field(_category, 'Categoria'),
                _field(_unit, 'Unidad'),
                _field(_stock, 'Stock', isNumber: true),
                _field(_minStock, 'Stock minimo', isNumber: true),
                _field(_cost, 'Costo', isDecimal: true),
                _field(_price, 'Precio', isDecimal: true),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber || isDecimal
          ? TextInputType.numberWithOptions(decimal: isDecimal)
          : TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Requerido';
        }
        return null;
      },
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = Product(
      id: widget.product?.id ?? '',
      sku: _sku.text.trim(),
      name: _name.text.trim(),
      category: _category.text.trim(),
      unit: _unit.text.trim(),
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      minStock: int.tryParse(_minStock.text.trim()) ?? 0,
      cost: double.tryParse(_cost.text.trim()) ?? 0,
      price: double.tryParse(_price.text.trim()) ?? 0,
    );

    final controller = ref.read(inventoryControllerProvider.notifier);
    if (widget.product == null) {
      await controller.createProduct(item);
    } else {
      await controller.updateProduct(item);
    }
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }
}
