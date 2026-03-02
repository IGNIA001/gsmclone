import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';
import 'package:gsmclone/features/compare/widgets/filter_sheet.dart';

class CompareDevicesScreen extends ConsumerStatefulWidget {
  const CompareDevicesScreen({super.key});

  @override
  ConsumerState<CompareDevicesScreen> createState() =>
      _CompareDevicesScreenState();
}

class _CompareDevicesScreenState extends ConsumerState<CompareDevicesScreen> {
  double minPrice = 0;
  double maxPrice = 200000;
  bool reqCamera = false;
  bool reqPerformance = false;
  bool reqSoftware = false;

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => FilterSheet(
        initialMin: minPrice,
        initialMax: maxPrice,
        initialCamera: reqCamera,
        initialPerformance: reqPerformance,
        initialSoftware: reqSoftware,
        onApply: (min, max, cam, perf, soft) {
          setState(() {
            minPrice = min;
            maxPrice = max;
            reqCamera = cam;
            reqPerformance = perf;
            reqSoftware = soft;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);

    // Show active filter chips
    final activeFilters = <String>[];
    if (reqCamera) activeFilters.add('📷 Camera');
    if (reqPerformance) activeFilters.add('⚡ Performance');
    if (reqSoftware) activeFilters.add('✨ Clean UI');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Rankings'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: activeFilters.isNotEmpty,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _openFilterSheet,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filter chips row
          if (activeFilters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Text('Filters: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...activeFilters.map(
                        (f) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(f),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            if (f.contains('Camera')) reqCamera = false;
                            if (f.contains('Performance')) reqPerformance = false;
                            if (f.contains('UI')) reqSoftware = false;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Budget range indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.currency_rupee, size: 16),
                Text(
                  '${minPrice.round()} – ${maxPrice.round()}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Device list
          Expanded(
            child: StreamBuilder<List<Device>>(
              stream: db.watchFilteredDevices(
                minPrice: minPrice,
                maxPrice: maxPrice,
                reqCamera: reqCamera,
                reqPerformance: reqPerformance,
                reqSoftware: reqSoftware,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 60),
                        const SizedBox(height: 12),
                        const Text('No devices match your filters.'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            minPrice = 0;
                            maxPrice = 200000;
                            reqCamera = false;
                            reqPerformance = false;
                            reqSoftware = false;
                          }),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final device = items[index];
                    return _DeviceRankCard(
                      device: device,
                      rank: index + 1,
                      onFavoriteToggle: () =>
                          db.toggleFavorite(device.id, device.isFavorite),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceRankCard extends StatelessWidget {
  final Device device;
  final int rank;
  final VoidCallback onFavoriteToggle;

  const _DeviceRankCard({
    required this.device,
    required this.rank,
    required this.onFavoriteToggle,
  });

  Color _rankColor() {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade300;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: rank <= 3 ? 4 : 1,
      child: GestureDetector(
        onDoubleTap: () {
          onFavoriteToggle();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(device.isFavorite
                  ? '💔 Removed from Favorites'
                  : '❤️ Added to Favorites!'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 48,
              height: 80,
              decoration: BoxDecoration(
                color: _rankColor().withOpacity(0.2),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: rank <= 3 ? _rankColor() : theme.colorScheme.outline,
                  ),
                ),
              ),
            ),

            // Device image
            SizedBox(
              width: 70,
              height: 80,
              child: device.imageUrl != null
                  ? Image.network(
                device.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.phone_android, size: 40),
              )
                  : const Icon(Icons.phone_android, size: 40),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${device.brand} ${device.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('₹${device.price.round()}',
                        style: TextStyle(
                            color: theme.colorScheme.primary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _ScorePill('CPU', device.cpuScore, Colors.blue),
                        const SizedBox(width: 4),
                        _ScorePill('CAM', device.cameraScore, Colors.green),
                        const SizedBox(width: 4),
                        _ScorePill('GPU', device.gpuScore, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Favorite button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  device.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: onFavoriteToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScorePill(this.label, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $score',
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}