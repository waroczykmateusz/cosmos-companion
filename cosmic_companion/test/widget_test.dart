import 'package:cosmic_companion/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test — renders without crash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CosmicCompanionApp()),
    );
    expect(find.text('Cosmic Companion — bootstrap OK'), findsOneWidget);
  });
}
