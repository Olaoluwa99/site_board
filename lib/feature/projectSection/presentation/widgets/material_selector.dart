import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/loader.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:site_board/feature/projectSection/domain/entities/project_material.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/inventory_bloc.dart';
import 'package:site_board/init_dependencies.dart';

class MaterialUsageItem {
  final ProjectMaterial material;
  final double quantityUsed;

  const MaterialUsageItem({required this.material, required this.quantityUsed});

  // Format for legacy List<String> compatibility
  @override
  String toString() {
    return '${material.name}: $quantityUsed ${material.unit}';
  }
}

class MaterialSelector extends StatefulWidget {
  final String projectId;
  // Callback returns the structured usage data AND the string representation
  // for backward compatibility with DailyLog.materialsAvailable
  final Function(List<MaterialUsageItem> items, List<String> stringList)
  onChanged;

  const MaterialSelector({
    super.key,
    required this.projectId,
    required this.onChanged,
  });

  @override
  State<MaterialSelector> createState() => _MaterialSelectorState();
}

class _MaterialSelectorState extends State<MaterialSelector> {
  // Map of index -> helper object
  final Map<int, _MaterialRowState> _rows = {};
  int _nextIndex = 0;
  List<ProjectMaterial> _availableMaterials = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  void _addRow() {
    setState(() {
      _rows[_nextIndex] = _MaterialRowState();
      _nextIndex++;
    });
    _notifyParent();
  }

  void _removeRow(int index) {
    setState(() {
      _rows.remove(index);
    });
    _notifyParent();
  }

  void _updateRow(int index, ProjectMaterial? material, double? qty) {
    // If material changes, check if it's already selected in another row?
    // Current requirement doesn't strictly forbid duplicate rows, but it's bad UX.
    // For now, allow it, logic will sum them up or just pass as is.
    setState(() {
      final current = _rows[index]!;
      _rows[index] = _MaterialRowState(
        selectedMaterial: material ?? current.selectedMaterial,
        quantity: qty ?? current.quantity,
      );
    });
    _notifyParent();
  }

  void _notifyParent() {
    final validItems = <MaterialUsageItem>[];
    final strings = <String>[];

    _rows.forEach((key, row) {
      if (row.selectedMaterial != null && row.quantity > 0) {
        final item = MaterialUsageItem(
          material: row.selectedMaterial!,
          quantityUsed: row.quantity,
        );
        validItems.add(item);
        strings.add(item.toString());
      }
    });

    widget.onChanged(validItems, strings);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              serviceLocator<InventoryBloc>()
                ..add(InventoryGetMaterials(projectId: widget.projectId)),
      child: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryMaterialsLoaded) {
            setState(() {
              _availableMaterials = state.materials;
            });
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Padding(padding: EdgeInsets.all(8.0), child: Loader());
          }

          if (state is InventoryMaterialsLoaded || state is InventorySuccess) {
            if (_availableMaterials.isEmpty) {
              return const Text("No materials configured in Inventory.");
            }

            return Column(
              children: [
                ..._rows.keys.map((index) {
                  return _MaterialUsageRow(
                    key: ValueKey(index),
                    materials: _availableMaterials,
                    onDelete: _rows.length > 1 ? () => _removeRow(index) : null,
                    onUpdate: (m, q) => _updateRow(index, m, q),
                  );
                }),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _addRow,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppPalette.borderColor,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      '+ Add another material',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.gradient2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MaterialRowState {
  final ProjectMaterial? selectedMaterial;
  final double quantity;

  _MaterialRowState({this.selectedMaterial, this.quantity = 0});
}

class _MaterialUsageRow extends StatefulWidget {
  final List<ProjectMaterial> materials;
  final VoidCallback? onDelete;
  final Function(ProjectMaterial?, double?) onUpdate;

  const _MaterialUsageRow({
    super.key,
    required this.materials,
    this.onDelete,
    required this.onUpdate,
  });

  @override
  State<_MaterialUsageRow> createState() => _MaterialUsageRowState();
}

class _MaterialUsageRowState extends State<_MaterialUsageRow> {
  ProjectMaterial? _selected;
  final TextEditingController _qtyController = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<ProjectMaterial>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Material',
              ),
              items:
                  widget.materials.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(
                        '${m.name} (${m.currentQuantity} ${m.unit})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _selected = val;
                  _validate();
                });
                widget.onUpdate(val, null);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Quantity Input
          Expanded(
            flex: 2,
            child: TextField(
              controller: _qtyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Used',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                errorText: _errorText,
                suffixText: _selected?.unit,
              ),
              onChanged: (val) {
                _validate();
                final q = double.tryParse(val);
                widget.onUpdate(_selected, q);
              },
            ),
          ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: widget.onDelete,
            ),
        ],
      ),
    );
  }

  void _validate() {
    setState(() {
      _errorText = null;
    });

    if (_selected == null) return;

    final val = _qtyController.text.trim();
    if (val.isEmpty) return;

    final qty = double.tryParse(val);
    if (qty == null) {
      setState(() => _errorText = 'Invalid');
      return;
    }

    if (qty > _selected!.currentQuantity) {
      setState(() => _errorText = 'Over limit'); // Strict Visual Feedback
    }
  }
}
