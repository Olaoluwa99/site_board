import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/project_summary.dart';
import '../../domain/useCases/generate_project_summary.dart';

@immutable
sealed class SummaryEvent {}

class GenerateSummary extends SummaryEvent {
  final Project project;
  final SummaryMode mode;
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;

  GenerateSummary({
    required this.project,
    required this.mode,
    this.selectedDate,
    this.startDate,
    this.endDate,
  });
}

class ExportSummaryToPdf extends SummaryEvent {
  final ProjectSummary summary;
  final String projectName;

  ExportSummaryToPdf({required this.summary, required this.projectName});
}