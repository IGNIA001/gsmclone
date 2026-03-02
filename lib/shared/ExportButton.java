import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ensure these paths match your folder structure exactly
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';

class ExportButton extends ConsumerWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      // Corrected: Icon property gets the Icon widget
      icon: const Icon(Icons.share),
      // Corrected: Label property usually gets a Text widget
      label: const Text('Share Wishlist'),
      onPressed: () async {
        try {
          // Read the database via Riverpod
          final db = ref.read(databaseProvider);
          
          // Fetch the formatted string from our database.dart logic
          final data = await db.getFavoritesAsText();
          
          if (data == "No favorites saved yet.") {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Add some devices to your favorites first!")),
              );
            }
            return;
          }

          // Trigger the native share sheet
          await Share.share(
            data, 
            subject: 'My Mobile Device Wishlist'
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Export failed: $e")),
            );
          }
        }
      },
    );
  }
}