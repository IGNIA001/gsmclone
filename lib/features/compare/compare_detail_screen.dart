import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/core/database/database.dart';
import 'package:gsmclone/core/providers/providers.dart';

class CompareDetailScreen extends ConsumerStatefulWidget {
  const CompareDetailScreen({super.key});

  @override
  ConsumerState<CompareDetailScreen> createState() =>
      _CompareDetailScreenState();
}

class _CompareDetailScreenState extends ConsumerState<CompareDetailScreen>
    with SingleTickerProviderStateMixin {
  Device? _deviceA;
  Device? _deviceB;

  // Slide-down video panel animation
  late AnimationController _videoController;
  late Animation<double> _videoAnimation;
  bool _videoVisible = false;

  @override
  void initState() {
    super.initState();
    _videoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _videoAnimation = CurvedAnimation(
      parent: _videoController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    setState(() => _videoVisible = !_videoVisible);
    if (_videoVisible) {
      _videoController.forward();
    } else {
      _videoController.reverse();
    }
  }

  // ── Pick device from bottom sheet ─────────────────────────────────────────
  Future<void> _pickDevice(bool isA, List<Device> all) async {
    final picked = await showModalBottomSheet<Device>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, sc) => Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Pick Device ${isA ? "A" : "B"}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: all.length,
                itemBuilder: (_, i) {
                  final d = all[i];
                  return ListTile(
                    leading: d.imageUrl != null
                        ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(d.imageUrl!,
                            width: 48, height: 48, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.phone_android, size: 32)))
                        : const Icon(Icons.phone_android, size: 32),
                    title: Text('${d.brand} ${d.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('₹${d.price.round()} · CPU ${d.cpuScore}'),
                    onTap: () => Navigator.pop(context, d),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        if (isA) _deviceA = picked;
        else _deviceB = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Devices'),
        actions: [
          // Swap A <-> B
          if (_deviceA != null && _deviceB != null)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Swap devices',
              onPressed: () =>
                  setState(() {
                    final tmp = _deviceA;
                    _deviceA = _deviceB;
                    _deviceB = tmp;
                  }),
            ),
          // Video panel toggle
          if (_deviceA != null && _deviceB != null)
            IconButton(
              icon: Icon(_videoVisible
                  ? Icons.videocam_off_outlined
                  : Icons.videocam_outlined),
              tooltip: 'Toggle video panel',
              onPressed: _toggleVideo,
            ),
        ],
      ),
      body: StreamBuilder<List<Device>>(
        stream: db.watchAllDevices(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];

          return Column(
            children: [
              // ── Slide-down video panel ──────────────────────────────
              SizeTransition(
                sizeFactor: _videoAnimation,
                axisAlignment: -1,
                child: GestureDetector(
                  onVerticalDragEnd: (d) {
                    if (d.primaryVelocity != null &&
                        d.primaryVelocity! > 200) {
                      _toggleVideo();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_outline,
                            color: Colors.white, size: 56),
                        const SizedBox(height: 8),
                        Text(
                          _deviceA != null && _deviceB != null
                              ? '${_deviceA!.brand} ${_deviceA!.name} vs '
                              '${_deviceB!.brand} ${_deviceB!.name}'
                              : 'Select two devices to compare',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text('Video comparison coming soon',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 8),
                        const Text('↓ Swipe down to close',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Device picker row ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                        child: _DevicePickerButton(
                          device: _deviceA,
                          label: 'Device A',
                          color: Colors.blue,
                          onTap: () => _pickDevice(true, all),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('VS',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.colorScheme.primary)),
                    ),
                    Expanded(
                        child: _DevicePickerButton(
                          device: _deviceB,
                          label: 'Device B',
                          color: Colors.orange,
                          onTap: () => _pickDevice(false, all),
                        )),
                  ],
                ),
              ),

              // ── Comparison table ────────────────────────────────────
              if (_deviceA == null || _deviceB == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare_arrows,
                            size: 72,
                            color: theme.colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('Tap the buttons above to pick two devices',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5))),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: _CompareTable(
                      deviceA: _deviceA!, deviceB: _deviceB!),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Device picker button ──────────────────────────────────────────────────────
class _DevicePickerButton extends StatelessWidget {
  final Device? device;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DevicePickerButton({
    required this.device,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: device == null
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_circle_outline, color: color, size: 20),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ])
            : Column(children: [
          if (device!.imageUrl != null)
            Image.network(device!.imageUrl!,
                height: 52, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.phone_android, size: 40, color: color))
          else
            Icon(Icons.phone_android, size: 40, color: color),
          const SizedBox(height: 4),
          Text('${device!.brand} ${device!.name}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// ── Side-by-side comparison table ────────────────────────────────────────────
class _CompareTable extends StatelessWidget {
  final Device deviceA;
  final Device deviceB;

  const _CompareTable({required this.deviceA, required this.deviceB});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Winner banner
    final scoreA = deviceA.cpuScore + deviceA.gpuScore +
        deviceA.cameraScore + deviceA.softwareScore;
    final scoreB = deviceB.cpuScore + deviceB.gpuScore +
        deviceB.cameraScore + deviceB.softwareScore;
    final winner = scoreA > scoreB
        ? '🏆 ${deviceA.brand} ${deviceA.name} wins!'
        : scoreB > scoreA
        ? '🏆 ${deviceB.brand} ${deviceB.name} wins!'
        : '🤝 It\'s a tie!';

    final rows = [
      _CompareRow('Price',
          '₹${deviceA.price.round()}', '₹${deviceB.price.round()}',
          deviceA.price < deviceB.price, deviceB.price < deviceA.price),
      _CompareRow('CPU Score',
          '${deviceA.cpuScore}', '${deviceB.cpuScore}',
          deviceA.cpuScore > deviceB.cpuScore,
          deviceB.cpuScore > deviceA.cpuScore),
      _CompareRow('GPU Score',
          '${deviceA.gpuScore}', '${deviceB.gpuScore}',
          deviceA.gpuScore > deviceB.gpuScore,
          deviceB.gpuScore > deviceA.gpuScore),
      _CompareRow('Camera',
          '${deviceA.cameraScore}', '${deviceB.cameraScore}',
          deviceA.cameraScore > deviceB.cameraScore,
          deviceB.cameraScore > deviceA.cameraScore),
      _CompareRow('Software',
          '${deviceA.softwareScore}', '${deviceB.softwareScore}',
          deviceA.softwareScore > deviceB.softwareScore,
          deviceB.softwareScore > deviceA.softwareScore),
      _CompareRow('Total Score',
          '$scoreA', '$scoreB',
          scoreA > scoreB, scoreB > scoreA),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Winner banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(winner,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),

          // Table header
          Row(children: [
            const Expanded(flex: 2, child: SizedBox()),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Text('${deviceA.brand}\n${deviceA.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue)),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Text('${deviceB.brand}\n${deviceB.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orange)),
              ),
            ),
          ]),

          // Table rows
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: rows.asMap().entries.map((e) {
                final row = e.value;
                final isLast = e.key == rows.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: e.key.isEven
                        ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                        : null,
                    borderRadius: isLast
                        ? const BorderRadius.vertical(
                        bottom: Radius.circular(10))
                        : null,
                  ),
                  child: Row(children: [
                    Expanded(
                      flex: 2,
                      child: Text(row.label,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        decoration: row.aWins
                            ? BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6))
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (row.aWins)
                              const Text('✓ ',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 11)),
                            Text(row.valueA,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: row.aWins
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: row.aWins ? Colors.blue : null)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        decoration: row.bWins
                            ? BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6))
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (row.bWins)
                              const Text('✓ ',
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 11)),
                            Text(row.valueB,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: row.bWins
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: row.bWins ? Colors.orange : null)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CompareRow {
  final String label;
  final String valueA;
  final String valueB;
  final bool aWins;
  final bool bWins;

  const _CompareRow(
      this.label, this.valueA, this.valueB, this.aWins, this.bWins);
}