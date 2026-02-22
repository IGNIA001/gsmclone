import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/providers.dart';

class ExportButton extends ConsumerWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.download),
      label: const Icon(Icons.share),
      onPressed: () async {
        final db = ref.read(databaseProvider);
        final data = await db.getFavoritesAsText();
        Share.share(data, subject: 'My Mobile Wishlist');
      },
    );
  }
}