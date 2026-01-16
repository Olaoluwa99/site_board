part of 'material_report_control_cubit.dart';

enum TransactionFilterType { all, onlyIn, onlyOut }

enum ReportViewMode { ledger, trust }

enum ReportControlStatus { initial, loaded }

class MaterialReportControlState extends Equatable {
  final ReportControlStatus status;
  final List<MaterialTransaction> allTransactions;

  // Filters
  final DateTime? startDate;
  final DateTime? endDate;
  final String dateRangeLabel; // "All Time", "This Week", etc.
  final List<String> selectedMaterialIds; // Empty = All
  final TransactionFilterType filterType;

  // View Settings
  final bool showFinancials;
  final ReportViewMode viewMode;

  const MaterialReportControlState({
    this.status = ReportControlStatus.initial,
    this.allTransactions = const [],
    this.startDate,
    this.endDate,
    this.dateRangeLabel = 'All Time',
    this.selectedMaterialIds = const [],
    this.filterType = TransactionFilterType.all,
    this.showFinancials = false,
    this.viewMode = ReportViewMode.ledger,
  });

  /// The Core "Calculator" Logic
  List<MaterialTransaction> get filteredTransactions {
    return allTransactions.where((t) {
      // 1. Date Filter
      if (startDate != null && t.timestamp.isBefore(startDate!)) return false;
      if (endDate != null && t.timestamp.isAfter(endDate!)) return false;

      // 2. Material Filter
      if (selectedMaterialIds.isNotEmpty &&
          !selectedMaterialIds.contains(t.materialId)) {
        return false;
      }

      // 3. Type Filter
      if (filterType == TransactionFilterType.onlyIn &&
          t.type != TransactionType.IN)
        return false;
      if (filterType == TransactionFilterType.onlyOut &&
          t.type != TransactionType.OUT)
        return false;

      return true;
    }).toList();
  }

  // Summary Stats
  double get totalAdded {
    return filteredTransactions
        .where((t) => t.type == TransactionType.IN)
        .fold(0.0, (sum, t) => sum + t.quantityChange);
  }

  double get totalUsed {
    return filteredTransactions
        .where((t) => t.type == TransactionType.OUT)
        .fold(0.0, (sum, t) => sum + t.quantityChange);
  }

  double get netChange => totalAdded - totalUsed;

  // -- Comparison Logic --

  DateTime? get previousStartDate {
    if (startDate == null || endDate == null) return null;
    final duration = endDate!.difference(startDate!);
    return startDate!.subtract(duration);
  }

  DateTime? get previousEndDate {
    if (startDate == null) return null;
    return startDate!;
  }

  List<MaterialTransaction> get previousFilteredTransactions {
    final pStart = previousStartDate;
    final pEnd = previousEndDate;
    if (pStart == null || pEnd == null) return [];

    return allTransactions.where((t) {
      if (t.timestamp.isBefore(pStart)) return false;
      // pEnd is the 'startDate' of current period.
      // Current period includes startDate. So previous must EXCLUDE startDate.
      // So if timestamp >= pEnd, it is not in previous.
      if (!t.timestamp.isBefore(pEnd)) return false;

      // Ensure we respect other filters too (Material & Type)
      if (selectedMaterialIds.isNotEmpty &&
          !selectedMaterialIds.contains(t.materialId)) {
        return false;
      }
      if (filterType == TransactionFilterType.onlyIn &&
          t.type != TransactionType.IN)
        return false;
      if (filterType == TransactionFilterType.onlyOut &&
          t.type != TransactionType.OUT)
        return false;

      return true;
    }).toList();
  }

  double get previousTotalUsed {
    return previousFilteredTransactions
        .where((t) => t.type == TransactionType.OUT)
        .fold(0.0, (sum, t) => sum + t.quantityChange);
  }

  double get previousTotalAdded {
    return previousFilteredTransactions
        .where((t) => t.type == TransactionType.IN)
        .fold(0.0, (sum, t) => sum + t.quantityChange);
  }

  double get totalSpend {
    return filteredTransactions
        .where((t) => t.type == TransactionType.IN)
        .fold(0.0, (sum, t) => sum + (t.quantityChange * (t.unitPrice ?? 0)));
  }

  MaterialReportControlState copyWith({
    ReportControlStatus? status,
    List<MaterialTransaction>? allTransactions,
    DateTime? startDate,
    DateTime? endDate,
    String? dateRangeLabel,
    List<String>? selectedMaterialIds,
    TransactionFilterType? filterType,
    bool? showFinancials,
    ReportViewMode? viewMode,
  }) {
    return MaterialReportControlState(
      status: status ?? this.status,
      allTransactions: allTransactions ?? this.allTransactions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
      selectedMaterialIds: selectedMaterialIds ?? this.selectedMaterialIds,
      filterType: filterType ?? this.filterType,
      showFinancials: showFinancials ?? this.showFinancials,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allTransactions,
    startDate,
    endDate,
    dateRangeLabel,
    selectedMaterialIds,
    filterType,
    showFinancials,
    viewMode,
  ];
}
