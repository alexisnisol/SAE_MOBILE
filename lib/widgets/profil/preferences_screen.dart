import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sae_mobile/models/viewmodels/settings_viewmodel.dart';
import 'package:settings_ui/settings_ui.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profil'),
        ),
        title: const Text('Gérer les préférences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: SettingsList(
            sections: [
              SettingsSection(title: const Text('Theme'), tiles: [
                SettingsTile.switchTile(
                  initialValue: context.watch<SettingsViewModel>().isDark,
                  onToggle: (bool value) {
                    context.read<SettingsViewModel>().isDark = value;
                  },
                  title: const Text('Mode sombre'),
                  leading: const Icon(Icons.invert_colors),
                )
              ]),
              SettingsSection(
                title: const Text('Confidentialité'),
                tiles: [
                  SettingsTile.switchTile(
                    initialValue: context
                        .watch<SettingsViewModel>()
                        .isGeolocationDisabled,
                    onToggle: (bool value) {
                      context.read<SettingsViewModel>().isGeolocationDisabled =
                          value;
                    },
                    title: const Text('Désactiver la géolocalisation'),
                    leading: const Icon(Icons.location_on),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
