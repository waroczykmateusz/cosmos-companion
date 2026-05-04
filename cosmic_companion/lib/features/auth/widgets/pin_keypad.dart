import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  const PinKeypad({
    required this.onDigit,
    required this.onBackspace,
    super.key,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'back'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows
          .map(
            (row) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((label) => _cell(context, label)).toList(),
            ),
          )
          .toList(),
    );
  }

  Widget _cell(BuildContext context, String label) {
    if (label.isEmpty) return const SizedBox.square(dimension: 72);

    if (label == 'back') {
      return _KeyCell(
        onTap: onBackspace,
        child: const Icon(Icons.backspace_outlined),
      );
    }

    return _KeyCell(
      onTap: () => onDigit(label),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _KeyCell extends StatelessWidget {
  const _KeyCell({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(36),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 72,
          child: Center(child: child),
        ),
      ),
    );
  }
}
