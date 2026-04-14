import 'dart:convert';
import 'dart:typed_data';

import 'package:examen_final/features/inventory/domain/entities/product.dart';
import 'package:examen_final/features/inventory/domain/entities/stock_movement.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportExportService {
  Future<void> exportInventoryCsv({required List<Product> products}) async {
    final date = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final csv = _buildCsv(products);
    final bytes = Uint8List.fromList(utf8.encode(csv));

    final file = XFile.fromData(
      bytes,
      mimeType: 'text/csv',
      name: 'inventario_$date.csv',
    );

    await Share.shareXFiles([file], subject: 'Reporte de inventario CSV');
  }

  Future<void> exportInventoryPdf({
    required List<Product> products,
    required List<StockMovement> movements,
  }) async {
    final date = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final bytes = await _buildPdf(products: products, movements: movements);

    final file = XFile.fromData(
      bytes,
      mimeType: 'application/pdf',
      name: 'inventario_$date.pdf',
    );

    await Share.shareXFiles([file], subject: 'Reporte de inventario PDF');
  }

  String _buildCsv(List<Product> products) {
    final rows = <String>[
      'SKU,Nombre,Categoria,Unidad,Stock,StockMinimo,Costo,Precio,StockBajo',
      ...products.map((p) {
        return [
          _escapeCsv(p.sku),
          _escapeCsv(p.name),
          _escapeCsv(p.category),
          _escapeCsv(p.unit),
          p.stock.toString(),
          p.minStock.toString(),
          p.cost.toStringAsFixed(2),
          p.price.toStringAsFixed(2),
          p.isLowStock ? 'SI' : 'NO',
        ].join(',');
      }),
    ];

    return rows.join('\n');
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<Uint8List> _buildPdf({
    required List<Product> products,
    required List<StockMovement> movements,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: r'$');
    final totalCost = products.fold<double>(
      0,
      (sum, p) => sum + (p.stock * p.cost),
    );
    final totalPotential = products.fold<double>(
      0,
      (sum, p) => sum + (p.stock * p.price),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Reporte de Inventario',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Generado: $generatedAt'),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _metricBox('Productos', products.length.toString()),
              pw.SizedBox(width: 10),
              _metricBox('Valor inventario', currency.format(totalCost)),
              pw.SizedBox(width: 10),
              _metricBox('Valor potencial', currency.format(totalPotential)),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Detalle de productos',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              'SKU',
              'Nombre',
              'Cat',
              'Stock',
              'Min',
              'Costo',
              'Precio',
            ],
            data: products
                .map(
                  (p) => [
                    p.sku,
                    p.name,
                    p.category,
                    p.stock.toString(),
                    p.minStock.toString(),
                    p.cost.toStringAsFixed(2),
                    p.price.toStringAsFixed(2),
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(6),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Ultimos movimientos',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Fecha', 'Producto', 'Tipo', 'Cantidad', 'Nota'],
            data: movements
                .take(20)
                .map(
                  (m) => [
                    DateFormat('dd/MM HH:mm').format(m.createdAt),
                    m.productName,
                    m.type.name,
                    m.quantity.toString(),
                    m.note,
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(6),
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _metricBox(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.blueGrey200),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
