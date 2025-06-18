import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todos/config/router/app_router.dart';
import 'package:todos/config/theme/app_theme.dart';
import 'package:todos/presentation/providers/theme_provider.dart';

import 'infrastructure/datasources/local_db_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDBDatasource().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = AppTheme();
    final themeMode = ref.watch(themeProvider); // <-- Escuchamos el provider

    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'TODOs',
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
