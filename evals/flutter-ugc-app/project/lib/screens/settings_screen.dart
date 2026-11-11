import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This permanently deletes your account, profile and coin balance. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    await user.delete();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(title: Text('Privacy Policy'), subtitle: Text('https://huddle.chat/privacy')),
          const ListTile(title: Text('Contact us'), subtitle: Text('support@huddle.chat')),
          ListTile(
            title: const Text('Log out'),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
          ListTile(
            title: const Text('Delete account', style: TextStyle(color: Colors.red)),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
