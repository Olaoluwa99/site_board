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
  final List<String> initialMaterials;
  // Callback returns the structured usage data AND the string representation
  // for backward compatibility with DailyLog.materialsAvailable
  final Function(List<MaterialUsageItem> items, List<String> stringList)
  onChanged;

  const MaterialSelector({
    super.key,
    required this.projectId,
    required this.onChanged,
    this.initialMaterials = const [],
  });

  @override
  State<MaterialSelector> createState() => _MaterialSelectorState();
}

class _MaterialSelectorState extends State<MaterialSelector> {
  // Map of index -> helper object
  final Map<int, _MaterialRowState> _rows = {};
  int _nextIndex = 0;
  List<ProjectMaterial> _availableMaterials = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Start with one empty row if no initial data
    if (widget.initialMaterials.isEmpty) {
      _addRow();
    }
  }

  void _initializeRowsFromStrings() {
    debugPrint("Initializing rows from strings: ${widget.initialMaterials}");
    if (_isInitialized) return; // Prevent double init

    // If we have initial strings but no materials, we can't match them yet.
    // BUT we should wait for materials?
    // If materials loaded is empty, we still want to show something?
    if (widget.initialMaterials.isNotEmpty && _availableMaterials.isEmpty) {
      // Wait for materials? The listener handles this.
      // Only return if we truly have nothing to do.
      return;
    }

    _rows.clear(); // Clear default empty row
    _nextIndex = 0;

    for (var str in widget.initialMaterials) {
      // Format: "Name: Quantity Unit"
      try {
        debugPrint("Parsing: $str");
        // Format: "Name: Quantity Unit"
        final index = str.indexOf(':'); // Allow ':' without space
        if (index == -1) {
          debugPrint("Invalid format: $str");
          continue;
        }

        final name = str.substring(0, index).trim();
        final rest = str.substring(index + 1).trim(); // Skip ':'
        final qtyPart = rest.split(' ')[0]; // "5.0" from "5.0 bags"
        final quantity = double.tryParse(qtyPart) ?? 0.0;

        debugPrint("Parsed: Name=$name, Qty=$quantity");

        final material =
            _availableMaterials
                .where((m) => m.name.toLowerCase() == name.toLowerCase())
                .firstOrNull;

        if (material != null) {
          debugPrint("Found material match: ${material.name}");
          _rows[_nextIndex] = _MaterialRowState(
            selectedMaterial: material,
            quantity: quantity,
          );
          _nextIndex++;
        } else {
          debugPrint("No material match found for: $name");
        }
      } catch (e) {
        debugPrint("Error parsing material string: $str. Error: $e");
      }
    }

    // If we failed to parse anything, at least show one empty row
    if (_rows.isEmpty) {
      _addRow();
    } else {
      _notifyParent();
    }

    _isInitialized = true;
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
            _initializeRowsFromStrings();
          }
        },
        builder: (context, state) {
          // Debug Header
          final debugHeader = Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Debug: InitMaterials=${widget.initialMaterials.length}, AvailMaterials=${_availableMaterials.length}",
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          );

          if (state is InventoryLoading) {
            return const Padding(padding: EdgeInsets.all(8.0), child: Loader());
          }

          if (state is InventoryFailure) {
            return Center(
              child: Text("Failed to load materials: ${state.error}"),
            );
          }

          if (state is InventoryMaterialsLoaded || state is InventorySuccess) {
            if (_availableMaterials.isEmpty) {
              return Column(
                children: [
                  debugHeader,
                  const Text("No materials configured in Inventory."),
                ],
              );
            }

            return Column(
              children: [
                debugHeader,
                ..._rows.keys.map((index) {
                  final rowState = _rows[index];
                  return _MaterialUsageRow(
                    key: ValueKey(index),
                    materials: _availableMaterials,
                    initialMaterial: rowState?.selectedMaterial,
                    initialQuantity: rowState?.quantity,
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
  final ProjectMaterial? initialMaterial;
  final double? initialQuantity;
  final VoidCallback? onDelete;
  final Function(ProjectMaterial?, double?) onUpdate;

  const _MaterialUsageRow({
    super.key,
    required this.materials,
    this.initialMaterial,
    this.initialQuantity,
    this.onDelete,
    required this.onUpdate,
  });

  @override
  State<_MaterialUsageRow> createState() => _MaterialUsageRowState();
}

class _MaterialUsageRowState extends State<_MaterialUsageRow> {
  ProjectMaterial? _selected;
  late TextEditingController _qtyController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMaterial;
    _qtyController = TextEditingController(
      text:
          widget.initialQuantity != null && widget.initialQuantity! > 0
              ? widget.initialQuantity.toString()
              : '',
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

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
              value: _selected, // Bind value
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
                widget.onUpdate(
                  val,
                  double.tryParse(_qtyController.text),
                ); // Pass current qty
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
