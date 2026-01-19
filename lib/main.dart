import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/sync_list_cubit.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/sync_status_cubit.dart';
import 'core/common/bloc/theme/theme_bloc.dart';
import 'core/common/cubits/app_user/app_user_cubit.dart';
import 'core/theme/theme.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/projectSection/presentation/pages/home_page.dart';
import 'init_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = initDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Initializing..."),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Initialization Failed",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _initializationFuture = initDependencies();
                          });
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
              BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
              BlocProvider(create: (_) => serviceLocator<ProjectBloc>()),
              BlocProvider(
                create: (_) => serviceLocator<SyncStatusCubit>(),
                lazy: false,
              ),
              BlocProvider(create: (_) => serviceLocator<SyncListCubit>()),
              BlocProvider(
                create: (_) => serviceLocator<ThemeBloc>()..add(ThemeLoad()),
              ),
            ],
            child: const MyApp(),
          );
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'SiteBoard',
          debugShowCheckedModeBanner: false,
          themeMode: themeState.themeMode,
          theme: AppTheme.lightThemeMode,
          darkTheme: AppTheme.darkThemeMode,
          home: BlocSelector<AppUserCubit, AppUserState, bool>(
            selector: (state) {
              return state is AppUserLoggedIn;
            },
            builder: (context, isLoggedIn) {
              return HomePage(isLoggedIn: isLoggedIn);
            },
          ),
        );
      },
    );
  }
}
