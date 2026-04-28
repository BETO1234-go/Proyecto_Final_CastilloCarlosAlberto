import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main(List<String> args) async {
  final inputPath = args.isNotEmpty
      ? args[0]
      : 'DOCUMENTO_SISTEMA_CARLOS_ALBERTO_CASTILLO_PINZON.md';
  final outputPath = args.length > 1
      ? args[1]
      : 'DOCUMENTO_SISTEMA_CARLOS_ALBERTO_CASTILLO_PINZON.pdf';

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('No se encontro el archivo de entrada: $inputPath');
    exitCode = 1;
    return;
  }

  final markdown = inputFile.readAsStringSync();
  final lines = markdown.split('\n');

  final document = pw.Document();
  final baseStyle = pw.TextStyle(fontSize: 11);
  final titleStyle = pw.TextStyle(
    fontSize: 20,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey900,
  );
  final h1Style = pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey800,
  );
  final h2Style = pw.TextStyle(
    fontSize: 13,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blueGrey700,
  );

  final widgets = <pw.Widget>[];
  for (final rawLine in lines) {
    final line = rawLine.trimRight();

    if (line.trim().isEmpty) {
      widgets.add(pw.SizedBox(height: 6));
      continue;
    }

    if (line.startsWith('# ')) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10, bottom: 6),
          child: pw.Text(line.replaceFirst('# ', '').trim(), style: titleStyle),
        ),
      );
      continue;
    }

    if (line.startsWith('## ')) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Text(line.replaceFirst('## ', '').trim(), style: h1Style),
        ),
      );
      continue;
    }

    if (line.startsWith('### ')) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 3),
          child: pw.Text(line.replaceFirst('### ', '').trim(), style: h2Style),
        ),
      );
      continue;
    }

    if (line.startsWith('---')) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Divider(thickness: 0.8, color: PdfColors.blueGrey300),
        ),
      );
      continue;
    }

    if (line.startsWith('- ')) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• ', style: baseStyle),
              pw.Expanded(
                child: pw.Text(
                  _cleanMarkdown(line.substring(2)),
                  style: baseStyle,
                ),
              ),
            ],
          ),
        ),
      );
      continue;
    }

    final orderedMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(line);
    if (orderedMatch != null) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${orderedMatch.group(1)}. ', style: baseStyle),
              pw.Expanded(
                child: pw.Text(
                  _cleanMarkdown(orderedMatch.group(2) ?? ''),
                  style: baseStyle,
                ),
              ),
            ],
          ),
        ),
      );
      continue;
    }

    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Text(_cleanMarkdown(line), style: baseStyle),
      ),
    );
  }

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      build: (context) => widgets,
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Pagina ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
    ),
  );

  final bytes = await document.save();
  await File(outputPath).writeAsBytes(bytes, flush: true);
  stdout.writeln('PDF generado correctamente: $outputPath');
}

String _cleanMarkdown(String value) {
  return value
      .replaceAll('**', '')
      .replaceAll('`', '')
      .replaceAll('  ', ' ')
      .trim();
}
