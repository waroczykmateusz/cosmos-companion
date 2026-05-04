import 'package:cosmic_companion/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test — renders without crash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CosmicCompanionApp()),
    );
    // App renders; auth guard redirects to onboarding or lock screen.
    await tester.pump();
    expect(find.byType(CosmicCompanionApp), findsOneWidget);
  });
}
