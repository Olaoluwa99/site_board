import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:site_board/feature/projectSection/domain/useCases/add_recent_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/delete_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/delete_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/generate_project_summary.dart';
import 'package:site_board/feature/projectSection/domain/useCases/leave_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/manage_log_task.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_member.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/summary_bloc.dart';
import 'package:site_board/core/common/bloc/theme/theme_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:site_board/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:site_board/core/network/connection_checker.dart';
import 'package:site_board/core/secrets/app_secrets.dart';
import 'package:site_board/feature/auth/data/datasources/auth_remote_data_source.dart';
import 'package:site_board/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:site_board/feature/auth/domain/repository/auth_repository.dart';
import 'package:site_board/feature/auth/domain/usecases/current_user.dart';
import 'package:site_board/feature/auth/domain/usecases/delete_account.dart';
import 'package:site_board/feature/auth/domain/usecases/user_login.dart';
import 'package:site_board/feature/auth/domain/usecases/user_logout.dart';
import 'package:site_board/feature/auth/domain/usecases/user_sign_up.dart';
import 'package:site_board/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:site_board/feature/projectSection/data/dataSources/gemini_remote_data_source.dart';
import 'package:site_board/feature/projectSection/data/dataSources/project_local_data_source.dart';
import 'package:site_board/feature/projectSection/data/dataSources/project_remote_data_source.dart';
import 'package:site_board/feature/projectSection/data/repositories/project_repository_impl.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/create_project.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_all_projects.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_project_by_id.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_project_by_link.dart';
import 'package:site_board/feature/projectSection/domain/useCases/get_recent_projects.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_project.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';
import 'package:site_board/feature/projectSection/data/dataSources/inventory_remote_data_source.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import 'package:site_board/feature/projectSection/data/repositories/inventory_repository_impl.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/inventory_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:site_board/core/network/sync_manager.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/sync_list_cubit.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/sync_status_cubit.dart';
import 'package:site_board/feature/projectSection/data/dataSources/inventory_local_data_source.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await serviceLocator.reset();

  Supabase? supabase;
  try {
    supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      anonKey: AppSecrets.supabaseAnonKey,
    );
  } catch (e) {
    try {
      supabase = Supabase.instance;
    } catch (_) {
      rethrow;
    }
  }

  final appDocsDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocsDir.path);

  final recentProjectBox = await Hive.openBox('recent_projects');
  final offlineProjectBox = await Hive.openBox('offline_projects');
  final transactionBox = await Hive.openBox('transactions');
  final materialsBox = await Hive.openBox('materials');
  await Hive.openBox('settings'); // Open stored settings box

  // Register Core Services (Supabase & Boxes)
  serviceLocator.registerLazySingleton(() => supabase!.client);

  serviceLocator.registerLazySingleton<Box>(
    () => recentProjectBox,
    instanceName: 'recent',
  );
  serviceLocator.registerLazySingleton<Box>(
    () => offlineProjectBox,
    instanceName: 'offline',
  );
  serviceLocator.registerLazySingleton<Box>(
    () => transactionBox,
    instanceName: 'transactions',
  );
  serviceLocator.registerLazySingleton<Box>(
    () => materialsBox,
    instanceName: 'materials',
  );

  // Register Core Services (Network & User)
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );

  // Initialize Features (Order matters: Sync last)
  try {
    _initAuth();
    debugPrint("Auth initialized");
    _initProject();
    debugPrint("Project initialized");
    _initInventory();
    debugPrint("Inventory initialized");
    _initTheme();
    debugPrint("Theme initialized");
  } catch (e, stack) {
    debugPrint("Error initializing features: $e\n$stack");
    rethrow;
  }

  // Debug: Print what we have
  // Note: GetIt doesn't provide a public list of keys easily, so we rely on control flow logs.

  // Sync initializes last because it resolves dependencies immediately
  debugPrint("Initializing Sync...");
  _initSync();
  debugPrint("Sync initialized");
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerFactory(() => UserLogout(serviceLocator()))
    ..registerFactory(() => DeleteAccount(serviceLocator()))
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        userLogout: serviceLocator(),
        deleteAccount: serviceLocator(),
      ),
    );
}

void _initProject() {
  serviceLocator
    // DataSource
    ..registerFactory<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<GeminiRemoteDataSource>(
      () => GeminiRemoteDataSourceImpl(),
    )
    ..registerLazySingleton<ProjectLocalDataSource>(
      () => ProjectLocalDataSourceImpl(
        serviceLocator<Box>(instanceName: 'recent'),
        serviceLocator<Box>(instanceName: 'offline'),
      ),
    )
    ..registerFactory<ProjectRepository>(
      () => ProjectRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // UseCases
    ..registerFactory(() => CreateProject(serviceLocator()))
    ..registerFactory(() => UpdateProject(serviceLocator()))
    ..registerFactory(() => CreateDailyLog(serviceLocator()))
    ..registerFactory(() => UpdateDailyLog(serviceLocator()))
    ..registerFactory(() => ManageLogTask(serviceLocator()))
    ..registerFactory(() => GetAllProjects(serviceLocator()))
    ..registerFactory(() => GetRecentProjects(serviceLocator()))
    ..registerFactory(() => GetProjectById(serviceLocator()))
    ..registerFactory(() => GetProjectByLink(serviceLocator()))
    ..registerFactory(() => UpdateMember(serviceLocator()))
    ..registerFactory(() => AddRecentProject(serviceLocator()))
    ..registerFactory(() => GenerateProjectSummary(serviceLocator()))
    ..registerFactory(() => DeleteProject(serviceLocator()))
    ..registerFactory(() => LeaveProject(serviceLocator()))
    ..registerFactory(() => DeleteDailyLog(serviceLocator())) // NEW
    // Bloc
    ..registerLazySingleton(
      () => ProjectBloc(
        createProject: serviceLocator(),
        updateProject: serviceLocator(),
        createDailyLog: serviceLocator(),
        updateDailyLog: serviceLocator(),
        manageLogTask: serviceLocator(),
        getAllProjects: serviceLocator(),
        getRecentProjects: serviceLocator(),
        getProjectById: serviceLocator(),
        getProjectByLink: serviceLocator(),
        updateMember: serviceLocator(),
        addRecentProject: serviceLocator(),
        deleteProject: serviceLocator(),
        leaveProject: serviceLocator(),
        deleteDailyLog: serviceLocator(), // NEW
      ),
    )
    ..registerFactory(
      () => SummaryBloc(generateProjectSummary: serviceLocator()),
    );
}

void _initInventory() {
  serviceLocator
    ..registerLazySingleton<InventoryLocalDataSource>(
      () => InventoryLocalDataSourceImpl(
        serviceLocator<Box>(instanceName: 'transactions'),
        serviceLocator<Box>(instanceName: 'materials'),
      ),
    )
    ..registerFactory<InventoryRemoteDataSource>(
      () => InventoryRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<InventoryRepository>(
      () => InventoryRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => InventoryBloc(inventoryRepository: serviceLocator()),
    );
}

void _initTheme() {
  serviceLocator.registerLazySingleton(() => ThemeBloc());
}

void _initSync() {
  serviceLocator.registerLazySingleton(() => Connectivity());

  serviceLocator.registerLazySingleton(
    () => SyncManager(
      projectRepository: serviceLocator(),
      inventoryRepository: serviceLocator(),
      connectivity: serviceLocator(),
    ),
  );
  // Trigger initialization to start listening
  serviceLocator<SyncManager>().initialize();

  serviceLocator.registerFactory(
    () => SyncStatusCubit(
      projectRepository: serviceLocator(),
      inventoryRepository: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => SyncListCubit(
      projectRepository: serviceLocator(),
      inventoryRepository: serviceLocator(),
    ),
  );
}
