import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';

class ExportButton extends ConsumerWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.share),
      label: const Text('Share Wishlist'),
      onPressed: () async {
        final db = ref.read(databaseProvider);
        final data = await db.getFavoritesAsText();

        if (!context.mounted) return;

        if (data == "No favorites saved yet.") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add some favorites first!")),
          );
          return;
        }

        // Updated for modern SharePlus syntax
        await Share.share(data, subject: 'My Mobile Wishlist');
      },
    );
  }
}