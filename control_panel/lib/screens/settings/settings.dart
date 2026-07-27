import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Add own background'),
            subtitle: const Text(
              'Upload a custom image to use as a background',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed('/custom-background-upload');
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync_alt),
            title: const Text('Audio Synchronization'),
            subtitle: const Text(
              'Synchronize current slide with live audio feed',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed('/audio-sync-settings');
            },
          ),

          // Add more settings tiles below as needed
        ],
      ),
    );
  }
}
