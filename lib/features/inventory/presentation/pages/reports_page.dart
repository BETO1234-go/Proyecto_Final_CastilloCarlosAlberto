import 'package:examen_final/features/inventory/application/report_export_service.dart';
import 'package:examen_final/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  final ReportExportService _exportService = ReportExportService();
  bool _exportingCsv = false;
  bool _exportingPdf = false;
  String _selectedCategory = 'Todas';
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(inventoryControllerProvider);
    final categories = <String>{
      'Todas',
      ...state.products.map((p) => p.category),
    }.toList()..sort();

    final thresholdDate = DateTime.now().subtract(
      Duration(days: _selectedDays),
    );
    final filteredProducts = _selectedCategory == 'Todas'
        ? state.products
        : state.products.where((p) => p.category == _selectedCategory).toList();
    final filteredSku = filteredProducts.map((p) => p.id).toSet();
    final filteredMovements = state.movements
        .where(
          (m) =>
              filteredSku.contains(m.productId) &&
              m.createdAt.isAfter(thresholdDate),
        )
        .toList();

    final currency = NumberFormat.currency(
      locale: 'es_MX',
      symbol: r'$',
      decimalDigits: 2,
    );
    final totalValue = filteredProducts.fold<double>(
      0,
      (sum, p) => sum + (p.stock * p.cost),
    );
    final potentialRevenue = filteredProducts.fold<double>(
      0,
      (sum, p) => sum + (p.stock * p.price),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.isLoading) const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 260,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                        items: [
                          for (final category in categories)
                            DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _selectedCategory = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedDays,
                        decoration: const InputDecoration(
                          labelText: 'Periodo movimientos',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 7,
                            child: Text('Ultimos 7 dias'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('Ultimos 30 dias'),
                          ),
                          DropdownMenuItem(
                            value: 90,
                            child: Text('Ultimos 90 dias'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _selectedDays = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ReportCard(
                  title: 'Valor de inventario',
                  value: currency.format(totalValue),
                ),
                _ReportCard(
                  title: 'Valor potencial venta',
                  value: currency.format(potentialRevenue),
                ),
                _ReportCard(
                  title: 'Movimientos registrados',
                  value: filteredMovements.length.toString(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exportacion',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Los reportes se exportan desde aqui en formato CSV o PDF.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: _exportingCsv
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  setState(() => _exportingCsv = true);
                                  try {
                                    await _exportService.exportInventoryCsv(
                                      products: filteredProducts,
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'CSV generado correctamente',
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No se pudo exportar CSV',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _exportingCsv = false);
                                    }
                                  }
                                },
                          icon: _exportingCsv
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.table_chart),
                          label: Text(
                            _exportingCsv ? 'Exportando...' : 'Exportar CSV',
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _exportingPdf
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  setState(() => _exportingPdf = true);
                                  try {
                                    await _exportService.exportInventoryPdf(
                                      products: filteredProducts,
                                      movements: filteredMovements,
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'PDF generado correctamente',
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No se pudo exportar PDF',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _exportingPdf = false);
                                    }
                                  }
                                },
                          icon: _exportingPdf
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: Text(
                            _exportingPdf ? 'Exportando...' : 'Exportar PDF',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
