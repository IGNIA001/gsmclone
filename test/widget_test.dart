import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/main.dart';
import 'package:gsmclone/core/providers/providers.dart';
import 'package:gsmclone/core/database/database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart'; // Add this for DatabaseConnection

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Wrap the memory database in a Connection
    final testDb = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory())
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const GSMCloneApp(),
      ),
    );

    // Give the app a moment to settle
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
  });
}