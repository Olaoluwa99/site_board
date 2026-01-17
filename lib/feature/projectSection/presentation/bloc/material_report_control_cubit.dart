import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';

part 'material_report_control_state.dart';

class MaterialReportControlCubit extends Cubit<MaterialReportControlState> {
  MaterialReportControlCubit() : super(const MaterialReportControlState());

  void setTransactions(List<MaterialTransaction> transactions) {
    emit(
      state.copyWith(
        allTransactions: transactions,
        status: ReportControlStatus.loaded,
      ),
    );
  }

  void updateDateRange(DateTime? start, DateTime? end, String label) {
    emit(state.copyWith(startDate: start, endDate: end, dateRangeLabel: label));
  }

  void toggleMaterial(String materialId) {
    final current = List<String>.from(state.selectedMaterialIds);
    if (current.contains(materialId)) {
      current.remove(materialId);
    } else {
      current.add(materialId);
    }
    emit(state.copyWith(selectedMaterialIds: current));
  }

  void setFilterType(TransactionFilterType type) {
    emit(state.copyWith(filterType: type));
  }

  void toggleFinancials() {
    emit(state.copyWith(showFinancials: !state.showFinancials));
  }

  void setViewMode(ReportViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }
}
