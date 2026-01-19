import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/sync_list_cubit.dart';
import 'package:site_board/init_dependencies.dart';

class SyncListPage extends StatelessWidget {
  const SyncListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<SyncListCubit>()..loadPendingItems(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Pending Syncs')),
        body: BlocBuilder<SyncListCubit, SyncListState>(
          builder: (context, state) {
            if (state is SyncListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SyncListLoaded) {
              if (state.items.isEmpty) {
                return const Center(child: Text('No pending items.'));
              }

              final projects =
                  state.items
                      .where((i) => i.type == SyncItemType.project)
                      .toList();
              final transactions =
                  state.items
                      .where((i) => i.type == SyncItemType.transaction)
                      .toList();

              return ListView(
                children: [
                  if (projects.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Projects',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...projects.map(
                      (p) => Dismissible(
                        key: Key(p.id),
                        background: Container(
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          context.read<SyncListCubit>().deleteItem(p);
                        },
                        child: ListTile(
                          title: Text(p.title),
                          subtitle: const Text(
                            'New Project (Waiting for sync)',
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (transactions.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Inventory Changes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...transactions.map(
                      (t) => Dismissible(
                        key: Key(t.id),
                        background: Container(
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          context.read<SyncListCubit>().deleteItem(t);
                        },
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: const Text('Waiting for sync'),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            } else if (state is SyncListError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
