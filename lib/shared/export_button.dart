import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gsmclone/core/providers/providers.dart';

class ImportExportWidget extends ConsumerStatefulWidget {
  const ImportExportWidget({super.key});

  @override
  ConsumerState<ImportExportWidget> createState() => _ImportExportWidgetState();
}

class _ImportExportWidgetState extends ConsumerState<ImportExportWidget> {
  bool _importing = false;

  // ── EXPORT ─────────────────────────────────────────────────────────────────
  Future<void> _export() async {
    final db = ref.read(databaseProvider);
    final favorites = await db.getFavoritesAsText();

    if (!mounted) return;

    if (favorites == 'No favorites saved yet.') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❤️ Add some favorites first!')),
      );
      return;
    }

    // Also build a JSON version for import compatibility
    final favDevices = await db.watchAllDevices().first;
    final favList = favDevices.where((d) => d.isFavorite).toList();
    final jsonData = jsonEncode(favList.map((d) => {
      'brand': d.brand,
      'name': d.name,
      'price': d.price,
      'cpuScore': d.cpuScore,
      'gpuScore': d.gpuScore,
      'cameraScore': d.cameraScore,
      'softwareScore': d.softwareScore,
    }).toList());

    // Show options: share as text or JSON
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Export Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.text_snippet_outlined, color: Colors.blue),
              title: const Text('Share as Text (WhatsApp, SMS, etc.)'),
              subtitle: const Text('Human-readable wishlist'),
              onTap: () async {
                Navigator.pop(context);
                await Share.share(favorites, subject: 'My Mobile Wishlist 📱');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.green),
              title: const Text('Share as JSON'),
              subtitle: const Text('Import-compatible format'),
              onTap: () async {
                Navigator.pop(context);
                await Share.share(
                  '// GSM Clone Wishlist\n$jsonData',
                  subject: 'GSM Clone Wishlist JSON',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── IMPORT ─────────────────────────────────────────────────────────────────
  Future<void> _import() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📥 Import Wishlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste JSON exported from another GSM Clone device:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '[{"brand":"Samsung","name":"S25 Ultra",...}]',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _importing = true);
    try {
      // Strip the comment header if present
      final raw = controller.text.trim()
          .replaceAll(RegExp(r'^//.*\n'), '');

      final List<dynamic> items = jsonDecode(raw);
      final db = ref.read(databaseProvider);
      int imported = 0;

      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final brand = item['brand']?.toString() ?? '';
        final name = item['name']?.toString() ?? '';
        if (brand.isEmpty || name.isEmpty) continue;

        // Try to mark as favorite in local DB if device already exists
        final all = await db.watchAllDevices().first;
        final existing = all.where((d) =>
        d.brand.toLowerCase() == brand.toLowerCase() &&
            d.name.toLowerCase() == name.toLowerCase()).firstOrNull;

        if (existing != null) {
          if (!existing.isFavorite) {
            await db.toggleFavorite(existing.id, false);
          }
          imported++;
        }
        // Note: we don't create new unknown devices from import for data integrity
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(imported > 0
                ? '✅ $imported device(s) marked as favorites!'
                : '⚠️ No matching devices found in your local DB.'),
            backgroundColor: imported > 0 ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Invalid JSON format. Please check and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.upload_outlined),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _export,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: _importing
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_outlined),
            label: const Text('Import'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _importing ? null : _import,
          ),
        ),
      ],
    );
  }
}