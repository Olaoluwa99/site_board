import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:site_board/feature/projectSection/domain/useCases/manage_log_task.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_daily_log.dart';
import 'package:site_board/feature/projectSection/domain/useCases/update_member.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/common/cubits/app_user/app_user_cubit.dart';
import 'core/network/connection_checker.dart';
import 'core/secrets/app_secrets.dart';
import 'feature/auth/data/datasources/auth_remote_data_source.dart';
import 'feature/auth/data/repositories/auth_repository_impl.dart';
import 'feature/auth/domain/repository/auth_repository.dart';
import 'feature/auth/domain/usecases/current_user.dart';
import 'feature/auth/domain/usecases/user_login.dart';
import 'feature/auth/domain/usecases/user_sign_up.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/projectSection/data/dataSources/project_local_data_source.dart';
import 'feature/projectSection/data/dataSources/project_remote_data_source.dart';
import 'feature/projectSection/data/repositories/project_repository_impl.dart';
import 'feature/projectSection/domain/repositories/project_repository.dart';
import 'feature/projectSection/domain/useCases/create_daily_log.dart';
import 'feature/projectSection/domain/useCases/create_project.dart';
import 'feature/projectSection/domain/useCases/get_all_projects.dart';
import 'feature/projectSection/domain/useCases/get_project_by_id.dart';
import 'feature/projectSection/domain/useCases/get_project_by_link.dart';
import 'feature/projectSection/domain/useCases/update_project.dart';
import 'feature/projectSection/presentation/bloc/project_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initProject();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  final appDocsDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocsDir.path);

  final recentProjectBox = await Hive.openBox('recent_projects');
  final offlineProjectBox = await Hive.openBox('offline_projects');
  /*debugPrint('-------------------------------------------------');
  for (var key in projectBox.keys) {
    debugPrint('-------------------------------------------------');
    debugPrint('Key: $key => Value: ${projectBox.get(key)}');
  }
  debugPrint('-------------------------------------------------');*/
  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerLazySingleton<Box>(
    () => recentProjectBox,
    instanceName: 'recent',
  );
  serviceLocator.registerLazySingleton<Box>(
    () => offlineProjectBox,
    instanceName: 'offline',
  );
  /*serviceLocator.registerLazySingleton(() => recentProjectBox);
  serviceLocator.registerLazySingleton(() => offlineProjectBox);*/
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    /*..registerFactory(
      <ProjectLocalDataSource>() =>
          ProjectLocalDataSourceImpl(serviceLocator()),
    )*/
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initProject() {
  serviceLocator
    //DataSource
    ..registerFactory<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(serviceLocator()),
    )
    /*..registerFactory<ProjectLocalDataSource>(
      () => ProjectLocalDataSourceImpl(serviceLocator()),
    )*/
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
      ),
    ) //UseCases
    ..registerFactory(() => CreateProject(serviceLocator()))
    ..registerFactory(() => UpdateProject(serviceLocator()))
    ..registerFactory(() => CreateDailyLog(serviceLocator()))
    ..registerFactory(() => UpdateDailyLog(serviceLocator()))
    ..registerFactory(() => ManageLogTask(serviceLocator()))
    ..registerFactory(() => GetAllProjects(serviceLocator()))
    ..registerFactory(() => GetProjectById(serviceLocator()))
    ..registerFactory(() => GetProjectByLink(serviceLocator()))
    ..registerFactory(() => UpdateMember(serviceLocator()))
    //Bloc
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
      ),
    );
}
