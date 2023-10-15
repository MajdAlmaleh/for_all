import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:for_all/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
        onPressed: () {
          ref.read(authProvider.notifier).signOut();
        },
        child: Text(' vddfdddddddddddddddddddd'));
  }
}
