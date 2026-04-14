import 'package:examen_final/features/inventory/domain/entities/stock_movement.dart';
import 'package:examen_final/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:examen_final/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryControllerProvider);
    final palette = Theme.of(context).extension<InventoryPalette>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Control')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.isLoading) const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _MetricCard(
                  label: 'Productos',
                  value: state.products.length.toString(),
                  icon: Icons.inventory_2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                _MetricCard(
                  label: 'Unidades en stock',
                  value: state.inventoryUnits.toString(),
                  icon: Icons.warehouse,
                  color: palette.mint,
                ),
                _MetricCard(
                  label: 'Stock bajo',
                  value: state.lowStockCount.toString(),
                  icon: Icons.warning_amber,
                  color: palette.signal,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Ultimos movimientos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.movements.length.clamp(0, 12),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final movement = state.movements[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _movementColor(movement.type, palette),
                        foregroundColor: Colors.white,
                        child: Icon(_movementIcon(movement.type)),
                      ),
                      title: Text(movement.productName),
                      subtitle: Text(movement.note),
                      trailing: Text(
                        '${DateFormat('dd/MM HH:mm').format(movement.createdAt)}\n${movement.quantity}',
                        textAlign: TextAlign.end,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _movementColor(MovementType type, InventoryPalette palette) {
    return switch (type) {
      MovementType.incoming => palette.mint,
      MovementType.outgoing => palette.signal,
      MovementType.adjustment => Colors.blueGrey,
    };
  }

  IconData _movementIcon(MovementType type) {
    return switch (type) {
      MovementType.incoming => Icons.arrow_downward,
      MovementType.outgoing => Icons.arrow_upward,
      MovementType.adjustment => Icons.tune,
    };
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                foregroundColor: Colors.white,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
