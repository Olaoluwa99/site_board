import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/material_report_control_cubit.dart';

class PdfGenerator {
  static Future<void> generateAndPrint(
    MaterialReportControlState state,
    String projectId,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    final now = DateTime.now();
    final dateStr = DateFormat('MMM d, yyyy').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Site Ledger Report",
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text("Project ID: $projectId"),
                    ],
                  ),
                  pw.Text("Generated: $dateStr"),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Section
            pw.Text(
              "Executive Summary",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  "Total Added",
                  "+${_formatQty(state.totalAdded)}",
                  PdfColors.green,
                ),
                _buildSummaryItem(
                  "Total Used",
                  "-${_formatQty(state.totalUsed)}",
                  PdfColors.red,
                ),
                if (state.showFinancials)
                  _buildSummaryItem(
                    "Total Spend",
                    "\$${state.totalSpend.toStringAsFixed(2)}",
                    PdfColors.blue,
                  ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Transaction Table
            pw.Text(
              "Detailed Ledger",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                "Date",
                "Material",
                "Type",
                "Qty",
                "Actor",
                if (state.showFinancials) "Cost",
              ],
              data:
                  state.filteredTransactions.map((t) {
                    final isIN = t.type == TransactionType.IN;
                    final qtyPrefix = isIN ? '+' : '-';
                    return [
                      DateFormat('MM/dd HH:mm').format(t.timestamp),
                      t.materialName ?? "Unknown",
                      t.type.name,
                      "$qtyPrefix${_formatQty(t.quantityChange)}",
                      t.actorName ?? "-",
                      if (state.showFinancials)
                        (t.unitPrice != null
                            ? "\$${(t.unitPrice! * t.quantityChange).toStringAsFixed(2)}"
                            : "-"),
                    ];
                  }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 50),

            // Signature Block
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text("Prepared by"),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text("Approved by"),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Site_Ledger_Report_$dateStr',
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static String _formatQty(double val) {
    if (val % 1 == 0) return val.toInt().toString();
    return val.toStringAsFixed(1);
  }
}
