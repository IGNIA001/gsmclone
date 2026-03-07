import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/core/database/database.dart';
import 'package:gsmclone/core/providers/providers.dart';

class DeviceDetailScreen extends ConsumerWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${device.brand} ${device.name}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  device.imageUrl != null
                      ? Image.network(
                    device.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.phone_android,
                          size: 120, color: theme.colorScheme.primary),
                    ),
                  )
                      : Center(
                      child: Icon(Icons.phone_android,
                          size: 120, color: theme.colorScheme.primary)),
                  // Gradient overlay so title is readable
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Live favorite toggle
              StreamBuilder<List<Device>>(
                stream: db.watchAllDevices(),
                builder: (ctx, snap) {
                  final current = (snap.data ?? [])
                      .where((d) => d.id == device.id)
                      .firstOrNull;
                  final isFav = current?.isFavorite ?? device.isFavorite;
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () => db.toggleFavorite(device.id, isFav),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Price ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '₹${device.price.round()}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Score bars ────────────────────────────────────────
                  _SectionTitle('Performance Scores'),
                  const SizedBox(height: 12),
                  _ScoreBar('CPU Performance', device.cpuScore,
                      Colors.blue, Icons.memory),
                  _ScoreBar('GPU / Graphics', device.gpuScore,
                      Colors.orange, Icons.videogame_asset),
                  _ScoreBar('Camera Quality', device.cameraScore,
                      Colors.green, Icons.camera_alt),
                  _ScoreBar('Software / UI', device.softwareScore,
                      Colors.purple, Icons.android),

                  const SizedBox(height: 24),

                  // ── Overall rating ────────────────────────────────────
                  _SectionTitle('Overall Rating'),
                  const SizedBox(height: 12),
                  _OverallRating(device: device),

                  const SizedBox(height: 24),

                  // ── Spec table ────────────────────────────────────────
                  _SectionTitle('Specifications'),
                  const SizedBox(height: 12),
                  _SpecTable(device: device),

                  const SizedBox(height: 24),

                  // ── CTA buttons ───────────────────────────────────────
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Buy Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Opening store for ${device.brand} ${device.name}...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('Go Back'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold));
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final IconData icon;

  const _ScoreBar(this.label, this.score, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text('$score/100',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 800),
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallRating extends StatelessWidget {
  final Device device;
  const _OverallRating({required this.device});

  @override
  Widget build(BuildContext context) {
    final avg = ((device.cpuScore + device.gpuScore +
        device.cameraScore + device.softwareScore) /
        4)
        .round();
    Color c = Colors.red;
    String label = 'Poor';
    if (avg >= 90) { c = Colors.green; label = 'Excellent'; }
    else if (avg >= 75) { c = Colors.blue; label = 'Great'; }
    else if (avg >= 60) { c = Colors.orange; label = 'Good'; }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: c.withOpacity(0.15),
          child: Text('$avg',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: c)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: c)),
            Text('Average across all scores',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ]),
    );
  }
}

class _SpecTable extends StatelessWidget {
  final Device device;
  const _SpecTable({required this.device});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Brand', device.brand),
      ('Model', device.name),
      ('Price', '₹${device.price.round()}'),
      ('CPU Score', '${device.cpuScore}/100'),
      ('GPU Score', '${device.gpuScore}/100'),
      ('Camera Score', '${device.cameraScore}/100'),
      ('Software Score', '${device.softwareScore}/100'),
      ('Saved', device.isFavorite ? '❤️ In Favorites' : 'Not saved'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          final isFirst = e.key == 0;
          final row = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: e.key.isEven
                  ? Theme.of(context)
                  .colorScheme
                  .surfaceVariant
                  .withOpacity(0.3)
                  : null,
              borderRadius: isFirst
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : isLast
                  ? const BorderRadius.vertical(bottom: Radius.circular(12))
                  : null,
            ),
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Text(row.$1,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13))),
              Expanded(
                  flex: 3,
                  child: Text(row.$2,
                      style: const TextStyle(fontSize: 13))),
            ]),
          );
        }).toList(),
      ),
    );
  }
}