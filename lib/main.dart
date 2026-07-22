import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/local/hive_service.dart';
import 'data/repositories/entry_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'features/home/home_provider.dart';
import 'features/history/history_provider.dart';
import 'features/stats/stats_provider.dart';
import 'features/settings/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar & navigation bar theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local persistence (Hive & SharedPreferences) safely
  await HiveService.init();
  await SettingsRepository.init();

  final entryRepository = EntryRepository(HiveService.entriesBox);
  final settingsRepository = SettingsRepository();

  runApp(
    MyApp(
      entryRepository: entryRepository,
      settingsRepository: settingsRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final EntryRepository entryRepository;
  final SettingsRepository settingsRepository;

  const MyApp({
    super.key,
    required this.entryRepository,
    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EntryRepository>.value(value: entryRepository),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(settingsRepository),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (ctx) => HomeProvider(ctx.read<EntryRepository>()),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (ctx) => HistoryProvider(ctx.read<EntryRepository>()),
        ),
        ChangeNotifierProvider<StatsProvider>(
          create: (ctx) => StatsProvider(ctx.read<EntryRepository>()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Daily Hisaab',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}