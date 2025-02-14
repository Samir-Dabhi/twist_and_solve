import 'package:flutter/material.dart';

class SettingsPanel extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPanel({
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (bool value) {
                onThemeChanged(value); // Notify parent to toggle theme
                Navigator.pop(context); // Close the modal
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the modal
            },
            child: const Text('Close',style: TextStyle(
              color: Colors.black
            ),),
          ),
        ],
      ),
    );
  }
}
