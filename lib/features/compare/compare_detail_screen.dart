import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';

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

  // Slide-down video panel state
  bool _videoVisible = false;
  double _dragOffset = 0;
  late AnimationController _videoAnimController;
  late Animation<double> _videoSlideAnim;

  @override
  void initState() {
    super.initState();
    _videoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _videoSlideAnim = CurvedAnimation(
      parent: _videoAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _videoAnimController.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    if (_videoVisible) {
      _videoAnimController.reverse().then((_) {
        setState(() => _videoVisible = false);
      });
    } else {
      setState(() => _videoVisible = true);
      _videoAnimController.forward();
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(0.0, 300.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset > 60) {
      // Slide down enough to reveal
      setState(() => _videoVisible = true);
      _videoAnimController.forward();
    }
    setState(() => _dragOffset = 0);
  }

  Future<void> _pickDevice(bool isA, List<Device> all) async {
    final picked = await showModalBottomSheet<Device>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DevicePickerSheet(devices: all),
    );
    if (picked != null) {
      setState(() {
        if (isA) {
          _deviceA = picked;
        } else {
          _deviceB = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);
    final canCompare = _deviceA != null && _deviceB != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Devices'),
        actions: [
          if (canCompare)
            IconButton(
              icon: Icon(
                _videoVisible
                    ? Icons.videocam_off_outlined
                    : Icons.videocam_outlined,
              ),
              onPressed: _toggleVideo,
              tooltip: _videoVisible ? 'Hide video' : 'Watch comparison video',
            ),
        ],
      ),
      body: StreamBuilder<List<Device>>(
        stream: db.watchAllDevices(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];

          return Column(
            children: [
              // ---- Slide-down gesture hint bar ----
              if (canCompare)
                GestureDetector(
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                  onTap: _toggleVideo,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: 10 + (_dragOffset * 0.05)),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _videoVisible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        Text(
                          _videoVisible
                              ? 'Slide up or tap to hide video'
                              : 'Slide down or tap to watch comparison',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),

              // ---- Animated video panel ----
              if (_videoVisible)
                SizeTransition(
                  sizeFactor: _videoSlideAnim,
                  child: _VideoPlaceholderPanel(
                    deviceA: _deviceA!,
                    deviceB: _deviceB!,
                    onClose: _toggleVideo,
                  ),
                ),

              // ---- Device picker row ----
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _DeviceSlot(
                        label: 'Device A',
                        device: _deviceA,
                        color: Colors.blue,
                        onTap: () => _pickDevice(true, all),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          const Icon(Icons.compare_arrows, size: 28),
                          if (canCompare)
                            TextButton(
                              onPressed: () => setState(() {
                                final temp = _deviceA;
                                _deviceA = _deviceB;
                                _deviceB = temp;
                              }),
                              child: const Text('Swap'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _DeviceSlot(
                        label: 'Device B',
                        device: _deviceB,
                        color: Colors.deepOrange,
                        onTap: () => _pickDevice(false, all),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Comparison table ----
              if (!canCompare)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare_arrows,
                            size: 70,
                            color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        const Text(
                          'Select two devices above\nto compare their specs',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _CompareTable(a: _deviceA!, b: _deviceB!),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------
// Video placeholder panel (replace with video_player widget later)
// ----------------------------------------------------------------
class _VideoPlaceholderPanel extends StatelessWidget {
  final Device deviceA;
  final Device deviceB;
  final VoidCallback onClose;

  const _VideoPlaceholderPanel({
    required this.deviceA,
    required this.deviceB,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_filled,
                    color: Colors.white, size: 60),
                const SizedBox(height: 12),
                Text(
                  '${deviceA.brand} ${deviceA.name}  vs  ${deviceB.brand} ${deviceB.name}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Video comparison\n(plug in video_player package)',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// Device slot picker button
// ----------------------------------------------------------------
class _DeviceSlot extends StatelessWidget {
  final String label;
  final Device? device;
  final Color color;
  final VoidCallback onTap;

  const _DeviceSlot({
    required this.label,
    required this.device,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.05),
        ),
        child: device == null
            ? Column(
          children: [
            Icon(Icons.add_circle_outline, color: color, size: 36),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold)),
            const Text('Tap to select',
                style: TextStyle(fontSize: 11)),
          ],
        )
            : Column(
          children: [
            if (device!.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  device!.imageUrl!,
                  height: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.phone_android, size: 50),
                ),
              )
            else
              const Icon(Icons.phone_android, size: 50),
            const SizedBox(height: 4),
            Text(
              '${device!.brand} ${device!.name}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text('₹${device!.price.round()}',
                style:
                const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------
// Side-by-side comparison table
// ----------------------------------------------------------------
class _CompareTable extends StatelessWidget {
  final Device a;
  final Device b;

  const _CompareTable({required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _CompareRow('Price (₹)', a.price.round().toString(),
          b.price.round().toString(), higherIsBetter: false),
      _CompareRow('CPU Score', a.cpuScore.toString(), b.cpuScore.toString()),
      _CompareRow('GPU Score', a.gpuScore.toString(), b.gpuScore.toString()),
      _CompareRow(
          'Camera Score', a.cameraScore.toString(), b.cameraScore.toString()),
      _CompareRow('Software Score', a.softwareScore.toString(),
          b.softwareScore.toString()),
    ];

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Expanded(
                  flex: 2,
                  child: Text('Spec',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                child: Text(
                  '${a.brand}\n${a.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  '${b.brand}\n${b.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        ...rows.map((r) => r.build(context)),
        const SizedBox(height: 20),

        // Overall winner
        _WinnerBanner(a: a, b: b),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _CompareRow {
  final String label;
  final String valA;
  final String valB;
  final bool higherIsBetter;

  _CompareRow(this.label, this.valA, this.valB,
      {this.higherIsBetter = true});

  Widget build(BuildContext context) {
    final numA = double.tryParse(valA) ?? 0;
    final numB = double.tryParse(valB) ?? 0;
    final aWins =
    higherIsBetter ? numA > numB : numA < numB;
    final bWins =
    higherIsBetter ? numB > numA : numB < numA;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(fontSize: 13))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: aWins ? Colors.blue.withOpacity(0.15) : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (aWins)
                    const Icon(Icons.arrow_upward,
                        size: 12, color: Colors.blue),
                  Text(
                    valA,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                      aWins ? FontWeight.bold : FontWeight.normal,
                      color: aWins ? Colors.blue : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: bWins ? Colors.deepOrange.withOpacity(0.15) : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (bWins)
                    const Icon(Icons.arrow_upward,
                        size: 12, color: Colors.deepOrange),
                  Text(
                    valB,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                      bWins ? FontWeight.bold : FontWeight.normal,
                      color: bWins ? Colors.deepOrange : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WinnerBanner extends StatelessWidget {
  final Device a;
  final Device b;

  const _WinnerBanner({required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    // Simple scoring: sum of all scores
    final scoreA = a.cpuScore + a.gpuScore + a.cameraScore + a.softwareScore;
    final scoreB = b.cpuScore + b.gpuScore + b.cameraScore + b.softwareScore;

    final winner = scoreA > scoreB
        ? '${a.brand} ${a.name}'
        : scoreB > scoreA
        ? '${b.brand} ${b.name}'
        : null;

    final winnerColor =
    scoreA > scoreB ? Colors.blue : Colors.deepOrange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: winner != null
              ? [winnerColor.withOpacity(0.8), winnerColor]
              : [Colors.grey.shade600, Colors.grey.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🏆 Overall Winner',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            winner ?? 'It\'s a Tie!',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          if (winner != null)
            Text(
              'Score: ${scoreA > scoreB ? scoreA : scoreB}',
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// Device picker bottom sheet
// ----------------------------------------------------------------
class _DevicePickerSheet extends StatelessWidget {
  final List<Device> devices;

  const _DevicePickerSheet({required this.devices});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select a Device',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final d = devices[i];
                return ListTile(
                  leading: d.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      d.imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.phone_android),
                    ),
                  )
                      : const Icon(Icons.phone_android),
                  title: Text('${d.brand} ${d.name}'),
                  subtitle: Text('₹${d.price.round()} · CPU ${d.cpuScore}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, d),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}