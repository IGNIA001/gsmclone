import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsmclone/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    // We wrap it in ProviderScope because your app uses Riverpod.
    await tester.pumpWidget(
      const ProviderScope(
        child: GSMCloneApp(),
      ),
    );

    // 2. Verify that the Dashboard loads by looking for the Home tab text.
    // Since you have a NavigationBar with 'Home', this should pass.
    expect(find.text('Home'), findsWidgets);

    // 3. Verify that we don't see the 'Compare' content immediately 
    // (since it's on a different tab).
    expect(find.text('Device Rankings'), findsNothing);
  });
}