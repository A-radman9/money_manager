import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view_models/settings/settings_cubit.dart';
import '../../view_models/settings/settings_state.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'), // l10n.settings
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          // Get current locale from state
          String currentLanguage = 'en';
          if (state is SettingsLoaded) {
            currentLanguage = state.locale.languageCode;
          } else if (state is SettingsLanguageChanged) {
            currentLanguage = state.locale.languageCode;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Language Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language', // l10n.language
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLanguageOption(
                        context,
                        'en',
                        'English', // l10n.english
                        Icons.language,
                        currentLanguage == 'en',
                      ),
                      const SizedBox(height: 8),
                      _buildLanguageOption(
                        context,
                        'ar',
                        'العربية', // l10n.arabic
                        Icons.language,
                        currentLanguage == 'ar',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // App Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Version'),
                        subtitle: const Text('1.0.0'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('Developer'),
                        subtitle: const Text('Money Manager Team'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String languageName,
    IconData icon,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        context.read<SettingsCubit>().changeLanguage(languageCode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languageName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected ? theme.primaryColor : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
