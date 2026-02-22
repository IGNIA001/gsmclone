import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Add the /providers/ subfolder to the path
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';

class CompareDevicesScreen extends ConsumerWidget {
  const CompareDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This line will work once the import above is blue/green (not red)
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Device Rankings")),
      body: StreamBuilder<List<Device>>(
        stream: db.watchAllDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No devices found. Did you seed the database?"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final device = items[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("${device.brand} ${device.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("CPU Score: ${device.cpuScore} | GPU Score: ${device.gpuScore}"),
                  trailing: IconButton(
                    icon: Icon(device.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                    onPressed: () => db.toggleFavorite(device),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}