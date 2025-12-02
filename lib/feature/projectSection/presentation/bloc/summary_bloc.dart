import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/summary_event.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/summary_state.dart';

import '../../domain/useCases/generate_project_summary.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final GenerateProjectSummary _generateProjectSummary;

  SummaryBloc({required GenerateProjectSummary generateProjectSummary})
      : _generateProjectSummary = generateProjectSummary,
        super(SummaryInitial()) {
    on<GenerateSummary>(_onGenerateSummary);
    on<ExportSummaryToPdf>(_onExportSummaryToPdf);
  }

  void _onGenerateSummary(
      GenerateSummary event,
      Emitter<SummaryState> emit,
      ) async {
    emit(SummaryLoading());
    final result = await _generateProjectSummary(
      GenerateProjectSummaryParams(
        project: event.project,
        mode: event.mode,
        selectedDate: event.selectedDate,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
          (failure) => emit(SummaryFailure(failure.message)),
          (summary) => emit(SummaryGenerated(summary)),
    );
  }

  void _onExportSummaryToPdf(
      ExportSummaryToPdf event,
      Emitter<SummaryState> emit,
      ) async {
    try {
      final pdf = pw.Document();
      final summary = event.summary;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Project Summary: ${event.projectName}',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Date Range: ${summary.dateRange}'),
                pw.Divider(),
                pw.SizedBox(height: 20),

                _buildSectionHeader('Overview'),
                pw.Text(summary.overview),
                pw.SizedBox(height: 20),

                _buildSectionHeader('Completed Tasks'),
                ...summary.completedTasks.map(
                      (task) => pw.Bullet(text: task),
                ),
                pw.SizedBox(height: 20),

                _buildSectionHeader('Issues / Challenges'),
                ...summary.issuesRaised.map(
                      (issue) => pw.Bullet(text: issue),
                ),
                pw.SizedBox(height: 20),

                _buildSectionHeader('Upcoming Plans'),
                pw.Text(summary.upcomingPlans),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'summary_${event.projectName}.pdf',
      );
    } catch (e) {
      emit(SummaryFailure("Failed to export PDF: ${e.toString()}"));
    }
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey800,
        ),
      ),
    );
  }
}