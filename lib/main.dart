import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/transaction_dao.dart';
import 'data/datasources/category_dao.dart';
import 'data/datasources/account_dao.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/account_repository_impl.dart';
import 'presentation/view_models/dashboard/dashboard_cubit.dart';
import 'presentation/view_models/transaction/transaction_cubit.dart';
import 'presentation/view_models/category/category_cubit.dart';
import 'presentation/view_models/account/account_cubit.dart';
import 'presentation/view_models/settings/settings_cubit.dart';
import 'presentation/view_models/settings/settings_state.dart';
import 'presentation/views/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database; // This will create the database and tables

  runApp(const MoneyManagerApp());
}

class MoneyManagerApp extends StatelessWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // DAOs
        RepositoryProvider<TransactionDao>(
          create: (context) => TransactionDao(),
        ),
        RepositoryProvider<CategoryDao>(
          create: (context) => CategoryDao(),
        ),
        RepositoryProvider<AccountDao>(
          create: (context) => AccountDao(),
        ),
        // Repositories
        RepositoryProvider<TransactionRepositoryImpl>(
          create: (context) => TransactionRepositoryImpl(
            transactionDao: context.read<TransactionDao>(),
          ),
        ),
        RepositoryProvider<CategoryRepositoryImpl>(
          create: (context) => CategoryRepositoryImpl(
            categoryDao: context.read<CategoryDao>(),
          ),
        ),
        RepositoryProvider<AccountRepositoryImpl>(
          create: (context) => AccountRepositoryImpl(
            accountDao: context.read<AccountDao>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>(
            create: (context) => DashboardCubit(
              transactionRepository: context.read<TransactionRepositoryImpl>(),
            ),
          ),
          BlocProvider<TransactionCubit>(
            create: (context) => TransactionCubit(
              transactionRepository: context.read<TransactionRepositoryImpl>(),
            ),
          ),
          BlocProvider<CategoryCubit>(
            create: (context) => CategoryCubit(
              categoryRepository: context.read<CategoryRepositoryImpl>(),
            ),
          ),
          BlocProvider<AccountCubit>(
            create: (context) => AccountCubit(
              accountRepository: context.read<AccountRepositoryImpl>(),
            ),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: _buildTheme(settingsState),
              // locale: context.read<SettingsCubit>().currentLocale,
              // localizationsDelegates: const [
              //   AppLocalizations.delegate,
              //   GlobalMaterialLocalizations.delegate,
              //   GlobalWidgetsLocalizations.delegate,
              //   GlobalCupertinoLocalizations.delegate,
              // ],
              // supportedLocales: const [
              //   Locale('en'),
              //   Locale('ar'),
              // ],
              home: const DashboardScreen(),
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildTheme(SettingsState settingsState) {
    // Determine font family based on locale
    String fontFamily = 'Nunito'; // Default for English
    if (settingsState is SettingsLoaded && settingsState.locale.languageCode == 'ar') {
      fontFamily = 'Almarai';
    } else if (settingsState is SettingsLanguageChanged && settingsState.locale.languageCode == 'ar') {
      fontFamily = 'Almarai';
    }

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32), // Green theme for money app
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
