import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/sync_list_cubit.dart';

class PendingChangesSheet extends StatefulWidget {
  const PendingChangesSheet({super.key});

  @override
  State<PendingChangesSheet> createState() => _PendingChangesSheetState();
}

class _PendingChangesSheetState extends State<PendingChangesSheet> {
  @override
  void initState() {
    super.initState();
    context.read<SyncListCubit>().loadPendingItems();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pending Changes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<SyncListCubit, SyncListState>(
              builder: (context, state) {
                if (state is SyncListLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SyncListLoaded) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return const Center(child: Text("No pending changes."));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            _getIconForType(item.type),
                            color: Colors.orange,
                          ),
                          title: Text(item.title),
                          subtitle: Text("Waiting for connection..."),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              _confirmDelete(context, item);
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is SyncListError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(SyncItemType type) {
    switch (type) {
      case SyncItemType.project:
        return Icons.folder_special_rounded;
      case SyncItemType.dailyLog:
        return Icons.assignment_rounded;
      case SyncItemType.transaction:
        return Icons.inventory_2_rounded;
      case SyncItemType.unknown:
        return Icons.sync_problem_rounded;
    }
  }

  void _confirmDelete(BuildContext context, SyncItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Discard Change?"),
            content: const Text(
              "Are you sure you want to delete this unsynced change? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  context.read<SyncListCubit>().deleteItem(item);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }
}
