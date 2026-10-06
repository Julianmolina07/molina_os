import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  final ThemeController themeController;

  const SettingsPage({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Preferencias',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.brightness_6_rounded,
                color: colorScheme.primary,
              ),
              title: const Text('Apariencia'),
              subtitle: Text(_themeLabel(themeController.themeMode)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                _showThemeSelector(context);
              },
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Información',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Versión'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.code_rounded),
                  title: Text('Creado por'),
                  subtitle: Text('Julian Molina'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'MOLINA OS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.45),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final currentMode = themeController.themeMode;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Apariencia',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  title: 'Automático',
                  subtitle: 'Usar la apariencia del iPhone',
                  selected: currentMode == ThemeMode.system,
                  onTap: () async {
                    await themeController.setThemeMode(ThemeMode.system);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  title: 'Claro',
                  subtitle: 'Usar siempre el modo claro',
                  selected: currentMode == ThemeMode.light,
                  onTap: () async {
                    await themeController.setThemeMode(ThemeMode.light);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  title: 'Oscuro',
                  subtitle: 'Usar siempre el modo oscuro',
                  selected: currentMode == ThemeMode.dark,
                  onTap: () async {
                    await themeController.setThemeMode(ThemeMode.dark);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Automático';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
    }
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: onTap,
    );
  }
}
