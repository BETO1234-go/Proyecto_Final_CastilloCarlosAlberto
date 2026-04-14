import 'package:barcode_widget/barcode_widget.dart';
import 'package:examen_final/features/inventory/domain/entities/product.dart';
import 'package:flutter/material.dart';

class ProductBarcodeSheet extends StatelessWidget {
  const ProductBarcodeSheet({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8C0C8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${product.sku}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD9E0E8)),
              ),
              child: BarcodeWidget(
                barcode: Barcode.code128(),
                data: product.sku,
                drawText: true,
                height: 78,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
