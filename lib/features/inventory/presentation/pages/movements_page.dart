import 'package:examen_final/features/inventory/domain/entities/stock_movement.dart';
import 'package:examen_final/features/inventory/presentation/pages/barcode_scanner_page.dart';
import 'package:examen_final/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MovementsPage extends ConsumerStatefulWidget {
  const MovementsPage({super.key});

  @override
  ConsumerState<MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends ConsumerState<MovementsPage> {
  String? _selectedProductId;
  MovementType _selectedType = MovementType.incoming;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);
    final controller = ref.read(inventoryControllerProvider.notifier);

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
      appBar: AppBar(title: const Text('Movimientos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              if (state.isLoading) const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 640;
                      final largeWidth = compact ? constraints.maxWidth : 280.0;
                      final mediumWidth = compact
                          ? constraints.maxWidth
                          : 240.0;
                      final smallWidth = compact ? constraints.maxWidth : 120.0;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: largeWidth,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedProductId,
                              hint: const Text('Selecciona producto'),
                              items: [
                                for (final p in state.products)
                                  DropdownMenuItem(
                                    value: p.id,
                                    child: Text(
                                      '${p.name} (${p.stock})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedProductId = value),
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Escanear SKU',
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final scanResult = await Navigator.of(context)
                                  .push<String>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const BarcodeScannerPage(),
                                    ),
                                  );
                              if (scanResult == null ||
                                  scanResult.trim().isEmpty) {
                                return;
                              }
                              final query = scanResult.trim().toLowerCase();
                              String? matchId;
                              for (final product in state.products) {
                                if (product.sku.toLowerCase() == query) {
                                  matchId = product.id;
                                  break;
                                }
                              }
                              if (matchId == null) {
                                if (!context.mounted) {
                                  return;
                                }
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'No se encontro producto para SKU: ${scanResult.trim()}',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() => _selectedProductId = matchId);
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                          ),
                          SizedBox(
                            width: mediumWidth,
                            child: DropdownButtonFormField<MovementType>(
                              isExpanded: true,
                              initialValue: _selectedType,
                              items: const [
                                DropdownMenuItem(
                                  value: MovementType.incoming,
                                  child: Text('Entrada'),
                                ),
                                DropdownMenuItem(
                                  value: MovementType.outgoing,
                                  child: Text('Salida'),
                                ),
                                DropdownMenuItem(
                                  value: MovementType.adjustment,
                                  child: Text('Ajuste total'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _selectedType =
                                    value ?? MovementType.incoming,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: smallWidth,
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cantidad',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: mediumWidth,
                            child: TextField(
                              controller: _noteController,
                              decoration: const InputDecoration(
                                labelText: 'Nota',
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _selectedProductId == null
                                ? null
                                : () async {
                                    await controller.applyMovement(
                                      productId: _selectedProductId!,
                                      type: _selectedType,
                                      quantity:
                                          int.tryParse(
                                            _quantityController.text.trim(),
                                          ) ??
                                          0,
                                      note: _noteController.text.trim().isEmpty
                                          ? 'Movimiento manual'
                                          : _noteController.text.trim(),
                                    );
                                    if (!mounted) {
                                      return;
                                    }
                                    _quantityController.clear();
                                    _noteController.clear();
                                  },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Registrar'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.movements.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final movement = state.movements[index];
                      return ListTile(
                        title: Text(
                          movement.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          movement.note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Text(_movementLabel(movement.type)),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(movement.createdAt),
                            ),
                            Text(movement.quantity.toString()),
                          ],
                        ),
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

  String _movementLabel(MovementType type) {
    return switch (type) {
      MovementType.incoming => 'ENT',
      MovementType.outgoing => 'SAL',
      MovementType.adjustment => 'AJU',
    };
  }
}
