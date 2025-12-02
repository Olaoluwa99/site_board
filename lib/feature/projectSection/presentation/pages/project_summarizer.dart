import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/gradient_button.dart';
import 'package:site_board/core/common/widgets/loader.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:site_board/core/utils/format_date.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:site_board/feature/projectSection/domain/entities/project_summary.dart';
import 'package:site_board/feature/projectSection/domain/useCases/generate_project_summary.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/summary_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/summary_event.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/summary_state.dart';

import '../../domain/entities/project.dart';

class ProjectSummarizer extends StatefulWidget {
  final Project project;
  final VoidCallback onClose;
  final VoidCallback onCompleted;

  const ProjectSummarizer({
    required this.project,
    required this.onClose,
    required this.onCompleted,
    super.key,
  });

  @override
  State<ProjectSummarizer> createState() => _ProjectSummarizerState();
}

class _ProjectSummarizerState extends State<ProjectSummarizer> {
  SummaryMode _selectedMode = SummaryMode.daily;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
  }

  void _generateSummary() {
    if (_selectedMode == SummaryMode.daily && _selectedDate == null) {
      showSnackBar(context, 'Please select a date for the daily summary.');
      return;
    }
    if (_selectedMode == SummaryMode.custom &&
        (_startDate == null || _endDate == null)) {
      showSnackBar(context, 'Please select a date range.');
      return;
    }

    context.read<SummaryBloc>().add(
      GenerateSummary(
        project: widget.project,
        mode: _selectedMode,
        selectedDate: _selectedDate,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  void _exportPdf(ProjectSummary summary) {
    context.read<SummaryBloc>().add(
      ExportSummaryToPdf(
        summary: summary,
        projectName: widget.project.projectName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Summarizer'),
        actions: [
          IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
        ],
      ),
      body: BlocConsumer<SummaryBloc, SummaryState>(
        listener: (context, state) {
          if (state is SummaryFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is SummaryLoading) {
            return const Loader();
          }

          if (state is SummaryGenerated) {
            return _buildGeneratedView(state.summary);
          }

          return _buildInputView();
        },
      ),
    );
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Summary Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildModeSelector(),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildDateSelectors(),
          const SizedBox(height: 40),
          GradientButton(onClick: _generateSummary, text: 'Generate with AI'),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      children: [
        RadioListTile<SummaryMode>(
          title: const Text('Daily Summary'),
          value: SummaryMode.daily,
          groupValue: _selectedMode,
          onChanged: (val) => setState(() => _selectedMode = val!),
          activeColor: AppPalette.gradient2,
        ),
        RadioListTile<SummaryMode>(
          title: const Text('Custom Range'),
          value: SummaryMode.custom,
          groupValue: _selectedMode,
          onChanged: (val) => setState(() => _selectedMode = val!),
          activeColor: AppPalette.gradient2,
        ),
        RadioListTile<SummaryMode>(
          title: const Text('Full Project Summary'),
          value: SummaryMode.full,
          groupValue: _selectedMode,
          onChanged: (val) => setState(() => _selectedMode = val!),
          activeColor: AppPalette.gradient2,
        ),
      ],
    );
  }

  Widget _buildDateSelectors() {
    if (_selectedMode == SummaryMode.full) {
      return const Text(
        'This will generate a summary based on all logs available in this project.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    }

    if (_selectedMode == SummaryMode.daily) {
      return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPalette.borderColor),
        ),
        title: Text(
          _selectedDate == null
              ? 'Select Date'
              : formatDateBydMMMYYYY(_selectedDate!),
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: widget.project.createdDate,
            lastDate: DateTime.now(),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
          }
        },
      );
    }

    // Custom Mode
    return Column(
      children: [
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppPalette.borderColor),
          ),
          title: Text(
            _startDate == null
                ? 'Start Date'
                : formatDateBydMMMYYYY(_startDate!),
          ),
          trailing: const Icon(Icons.calendar_month),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: widget.project.createdDate,
              firstDate: widget.project.createdDate,
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _startDate = date);
            }
          },
        ),
        const SizedBox(height: 10),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppPalette.borderColor),
          ),
          title: Text(
            _endDate == null ? 'End Date' : formatDateBydMMMYYYY(_endDate!),
          ),
          trailing: const Icon(Icons.calendar_month),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: widget.project.createdDate,
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _endDate = date);
            }
          },
        ),
      ],
    );
  }

  Widget _buildGeneratedView(ProjectSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.gradient2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.whiteColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary.dateRange,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPalette.greyColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.gradient3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(summary.overview, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildSectionList("Completed Tasks", summary.completedTasks),
                const SizedBox(height: 16),
                _buildSectionList(
                  "Issues / Challenges",
                  summary.issuesRaised,
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppPalette.errorColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Upcoming Plans",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.gradient3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary.upcomingPlans,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            onClick: () => _exportPdf(summary),
            text: 'Export to PDF',
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                // Reset to generate another one
                context.read<SummaryBloc>().emit(SummaryInitial());
              },
              child: const Text("Generate New Summary"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionList(
      String title,
      List<String> items, {
        IconData icon = Icons.check_circle_outline,
        Color iconColor = AppPalette.gradient1,
      }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppPalette.gradient3,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}