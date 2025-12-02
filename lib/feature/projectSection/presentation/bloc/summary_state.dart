import 'package:flutter/material.dart';

import '../../domain/entities/project_summary.dart';

@immutable
sealed class SummaryState {}

final class SummaryInitial extends SummaryState {}

final class SummaryLoading extends SummaryState {}

final class SummaryGenerated extends SummaryState {
  final ProjectSummary summary;
  SummaryGenerated(this.summary);
}

final class SummaryFailure extends SummaryState {
  final String error;
  SummaryFailure(this.error);
}