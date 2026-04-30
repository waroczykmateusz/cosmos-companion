import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/features/auth/pages/lock_screen_page.dart';
import 'package:cosmic_companion/features/auth/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    redirect: (context, routerState) {
      final auth = ref.read(authStateProvider);
      final loc = routerState.matchedLocation;

      return switch (auth) {
        Unauthenticated() => loc == '/onboarding' ? null : '/onboarding',
        Locked() => loc == '/lock' ? null : '/lock',
        Authenticated() =>
          (loc == '/onboarding' || loc == '/lock') ? '/' : null,
      };
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreenPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const _PlaceholderPage('Dashboard'),
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$label — placeholder')),
    );
  }
}
