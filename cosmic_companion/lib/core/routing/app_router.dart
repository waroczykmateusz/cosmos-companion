import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder — rozbudowany w kroku 3 (auth guards) i 7 (dashboard route)
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _PlaceholderHome(),
    ),
  ],
);

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Cosmic Companion — bootstrap OK')),
    );
  }
}
