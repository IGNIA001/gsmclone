import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';
import 'package:gsmclone/features/device_detail/device_detail_screen.dart';
import 'package:gsmclone/shared/export_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Icon(Icons.phone_android, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('GSM Clone'),
        ]),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
              themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find Your Perfect Phone',
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Compare specs, filter by budget, save favorites offline.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Quick Stats ───────────────────────────────────────────────
            Text('Quick Stats',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<List<Device>>(
              stream: db.watchAllDevices(),
              builder: (context, snapshot) {
                final devices = snapshot.data ?? [];
                final favCount = devices.where((d) => d.isFavorite).length;
                final topCpu = devices.isEmpty
                    ? 0
                    : devices.map((d) => d.cpuScore).reduce((a, b) => a > b ? a : b);
                return Row(children: [
                  _StatCard(icon: Icons.devices, label: 'Devices',
                      value: '${devices.length}', color: Colors.blue),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.favorite, label: 'Favorites',
                      value: '$favCount', color: Colors.red),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.speed, label: 'Top CPU',
                      value: '$topCpu', color: Colors.green),
                ]);
              },
            ),

            const SizedBox(height: 24),

            // ── Top Picks ─────────────────────────────────────────────────
            Text('Top Picks Today',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<List<Device>>(
              stream: db.watchAllDevices(),
              builder: (context, snapshot) {
                final devices = snapshot.data ?? [];
                if (devices.isEmpty) {
                  return const SizedBox(
                      height: 190,
                      child: Center(child: CircularProgressIndicator()));
                }
                final top = devices.take(8).toList();
                return SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: top.length,
                    itemBuilder: (ctx, i) {
                      final d = top[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DeviceDetailScreen(device: d)),
                        ),
                        child: Container(
                          width: 145,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: d.imageUrl != null
                                    ? Image.network(d.imageUrl!,
                                    height: 105,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                    const SizedBox(height: 105,
                                        child: Center(child: Icon(
                                            Icons.phone_android, size: 50))))
                                    : const SizedBox(height: 105,
                                    child: Center(child: Icon(
                                        Icons.phone_android, size: 50))),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${d.brand} ${d.name}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text('₹${d.price.round()}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.primary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Import / Export ───────────────────────────────────────────
            Text('Import & Export',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Share your wishlist or import a friend\'s list into your app.'),
            const SizedBox(height: 12),
            const ImportExportWidget(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label,
    required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ]),
      ),
    );
  }
}