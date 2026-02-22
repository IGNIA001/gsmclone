import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/core/sync/sync_manager.dart';
import 'package:gsmclone/features/home/home_screen.dart';
import 'package:gsmclone/features/news/news_screen.dart';
import 'package:gsmclone/features/compare/compare_screen.dart';
// These were unused, but now we will use them below
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Create the database instance
  final db = AppDatabase();

  // 2. Add sample data so the Compare screen isn't empty
  await db.seedDatabase();

  // 3. Start background sync
  SyncManager.init();

  runApp(
    ProviderScope(
      overrides: [
        // This makes the 'unused' import active
        databaseProvider.overrideWithValue(db),
      ],
      child: const GSMCloneApp(),
    ),
  );
}

class GSMCloneApp extends StatelessWidget {
  const GSMCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GSM Clone',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  final screens = [
    const HomeScreen(),
    const TechNewsScreen(),
    const CompareDevicesScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps your scroll position when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.newspaper), label: 'News'),
          NavigationDestination(icon: Icon(Icons.compare), label: 'Compare'),
        ],
      ),
    );
  }
}