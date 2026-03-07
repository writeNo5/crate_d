// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:crate_d/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:crate_d/core/providers/app_state_provider.dart';

void main() {
  testWidgets('Home UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CollectionProvider()),
        ],
        child: const CrateDApp(),
      ),
    );

    // Verify that the title 'CRATE D' is present.
    expect(find.text('CRATE D'), findsOneWidget);
    
    // Verify that the user profile name is present.
    expect(find.text('RD Collector'), findsOneWidget);
    
    // Verify stats are present
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
  });
}
