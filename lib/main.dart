import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/project_bloc.dart';

import 'core/common/cubits/app_user/app_user_cubit.dart';
import 'core/theme/theme.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/projectSection/presentation/pages/home_page.dart';
import 'init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<ProjectBloc>()),
      ],
      child: const MyApp(),
    ),
  );
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
    return MaterialApp(
      title: 'SiteBoard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkThemeMode,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          return const HomePage();
        },
      ),
    );
  }
}
