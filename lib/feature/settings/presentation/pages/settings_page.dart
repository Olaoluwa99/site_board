import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/core/common/bloc/theme/theme_bloc.dart';

import 'package:site_board/feature/projectSection/presentation/widgets/offline_toolbar.dart';
import 'package:site_board/core/theme/app_palette.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const SettingsPage());

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          const OfflineToolbar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, "Appearance"),
                  const SizedBox(height: 10),
                  _buildThemeSelector(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, "Feedback"),
                  const SizedBox(height: 10),
                  _buildRateUsTile(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, "About"),
                  const SizedBox(height: 10),
                  _buildAboutTile(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color:
            Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7) ??
            Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildRadioTile(
                context,
                title: "System Default",
                value: ThemeMode.system,
                groupValue: state.themeMode,
              ),
              _buildDivider(context),
              _buildRadioTile(
                context,
                title: "Light Mode",
                value: ThemeMode.light,
                groupValue: state.themeMode,
              ),
              _buildDivider(context),
              _buildRadioTile(
                context,
                title: "Dark Mode",
                value: ThemeMode.dark,
                groupValue: state.themeMode,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
  }) {
    final isSelected = value == groupValue;
    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: (val) {
        if (val != null) {
          context.read<ThemeBloc>().add(ThemeChanged(val));
        }
      },
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      activeColor: AppPalette.gradient2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      dense: true,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }

  Widget _buildRateUsTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star, color: Colors.amber),
        ),
        title: const Text("Rate Us on Play Store"),
        subtitle: const Text("Love the app? Let us know!"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          // Placeholder URL - replace with actual Play Store URL when available
          final Uri url = Uri.parse('https://play.google.com/store/apps');
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Could not open Play Store Link"),
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thanks for rating!"),
                ), // Fallback toast
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline, color: Colors.blue),
        ),
        title: const Text("Version"),
        trailing: const Text(
          "1.0.0",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
