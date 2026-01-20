import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/sync_status_cubit.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/pending_changes_sheet.dart';

class OfflineToolbar extends StatelessWidget {
  const OfflineToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline =
            snapshot.data != null &&
            snapshot.data!.contains(ConnectivityResult.none);

        return BlocBuilder<SyncStatusCubit, SyncStatusState>(
          builder: (context, state) {
            final hasPendingChanges = state.totalCount > 0;

            if (!isOffline && !hasPendingChanges) {
              return const SizedBox.shrink();
            }

            return Container(
              color: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Icon(
                      isOffline ? Icons.wifi_off_rounded : Icons.sync,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isOffline
                            ? (hasPendingChanges
                                ? "Offline • ${state.totalCount} unsynced changes"
                                : "You are offline")
                            : "Syncing ${state.totalCount} changes...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (hasPendingChanges)
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const PendingChangesSheet(),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text("View"),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
