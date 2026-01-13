import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/widgets/loader.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:site_board/feature/projectSection/domain/entities/project_material.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/inventory_bloc.dart';
import 'package:site_board/init_dependencies.dart';
import 'package:site_board/core/utils/show_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'material_reports_page.dart';

class InventoryManagerPage extends StatefulWidget {
  final String projectId;
  final bool isAdmin;

  const InventoryManagerPage({
    super.key,
    required this.projectId,
    required this.isAdmin,
  });

  @override
  State<InventoryManagerPage> createState() => _InventoryManagerPageState();
}

class _InventoryManagerPageState extends State<InventoryManagerPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              serviceLocator<InventoryBloc>()
                ..add(InventoryGetMaterials(projectId: widget.projectId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: "View Reports",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MaterialReportsPage(projectId: widget.projectId),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton:
            widget.isAdmin
                ? Builder(
                  builder: (context) {
                    return FloatingActionButton.extended(
                      onPressed: () => _showCreateMaterialDialog(context),
                      label: const Text('Add Item'),
                      icon: const Icon(Icons.add),
                    );
                  },
                )
                : null,
        body: BlocConsumer<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is InventoryFailure) {
              showSnackBar(context, state.error);
            }
            if (state is InventorySuccess) {
              showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Loader();
            }
            if (state is InventoryMaterialsLoaded) {
              if (state.materials.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No materials defined yet.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (widget.isAdmin)
                        TextButton(
                          onPressed: () => _showCreateMaterialDialog(context),
                          child: const Text('Create your first item'),
                        ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.materials.length,
                itemBuilder: (context, index) {
                  final material = state.materials[index];
                  return _MaterialCard(
                    material: material,
                    isAdmin: widget.isAdmin,
                    onRestock: () => _showRestockDialog(context, material),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showCreateMaterialDialog(BuildContext context) {
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Material'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator:
                      (value) => value!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit (e.g. Tons, Bags)',
                    helperText: 'Review carefully. Cannot be changed later.',
                  ),
                  validator:
                      (value) => value!.trim().isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<InventoryBloc>().add(
                    InventoryCreateMaterial(
                      projectId: widget.projectId,
                      name: nameController.text.trim(),
                      unit: unitController.text.trim(),
                    ),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showRestockDialog(BuildContext context, ProjectMaterial material) {
    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Restock ${material.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity to Add (${material.unit})',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) return 'Must be positive';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
                    hintText: 'e.g. Delivery from Vendor X',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // We need the actor ID.
                  // Since we are in a widget, we can access AppUserCubit via context if available
                  // or pass it in.
                  // Assuming AppUserCubit or similar Auth state is available up the tree.
                  // Wait, context.read<InventoryBloc> needs to be dispatched.
                  // BUT we need the actorId (User ID).
                  // I'll grab it from Supabase auth instance directly or assume passed.
                  // Using Supabase instance is easiest for now if Bloc doesn't have it.
                  final userId =
                      serviceLocator<SupabaseClient>().auth.currentUser!.id;

                  context.read<InventoryBloc>().add(
                    InventoryRestockMaterial(
                      projectId: widget.projectId,
                      materialId: material.id,
                      quantity: double.parse(quantityController.text),
                      actorId: userId,
                      note:
                          noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim(),
                    ),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Confirm Restock'),
            ),
          ],
        );
      },
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final ProjectMaterial material;
  final bool isAdmin;
  final VoidCallback onRestock;

  const _MaterialCard({
    required this.material,
    required this.isAdmin,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    // Format quantity to remove trailing zeros
    final qtyString =
        material.currentQuantity % 1 == 0
            ? material.currentQuantity.toInt().toString()
            : material.currentQuantity.toStringAsFixed(2);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.gradient1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.category, color: AppPalette.gradient1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unit: ${material.unit}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  qtyString,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.gradient1,
                  ),
                ),
                Text(
                  'Available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onRestock,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Stock',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
