import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showBodyDetailSheet(BuildContext context, CelestialBody body) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BodyDetailSheet(body: body),
  );
}

class _BodyDetailSheet extends StatelessWidget {
  const _BodyDetailSheet({required this.body});

  final CelestialBody body;

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header — glyph + name + retrograde badge
          Row(
            children: [
              Text(
                _glyph(body.id),
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          body.displayName,
                          style: theme.textTheme.titleLarge,
                        ),
                        if (body.isRetrograde) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Rx',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${_signGlyph(body.zodiacSign)} ${_signName(body.zodiacSign)}  '
                      '${body.signDegree.toStringAsFixed(1)}°',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Rise / Transit / Set
          _RiseSetRow(
            riseLabel: l10n.riseLabel,
            transitLabel: l10n.transitLabel,
            setLabel: l10n.setLabel,
            rise: body.riseTime,
            transit: body.transitTime,
            set: body.setTime,
            timeFmt: _timeFmt,
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Detail tiles row 1: altitude, azimuth, ecliptic lon
          Row(
            children: [
              _DetailTile(
                label: l10n.altitudeLabel,
                value: '${body.altitude.toStringAsFixed(1)}°',
                icon: body.isAboveHorizon
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                iconColor:
                    body.isAboveHorizon ? Colors.greenAccent : Colors.grey,
              ),
              _DetailTile(
                label: l10n.azimuthLabel,
                value: '${body.azimuth.toStringAsFixed(1)}°',
                icon: Icons.explore_outlined,
              ),
              _DetailTile(
                label: l10n.eclipticLonLabel,
                value: '${body.eclipticLongitude.toStringAsFixed(1)}°',
                icon: Icons.circle_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Detail tiles row 2: distance, magnitude
          Row(
            children: [
              _DetailTile(
                label: l10n.distanceLabel,
                value: '${body.distanceAU.toStringAsFixed(3)} AU',
                icon: Icons.straighten_outlined,
              ),
              _DetailTile(
                label: l10n.magnitudeLabel,
                value: body.apparentMagnitude.toStringAsFixed(1),
                icon: Icons.brightness_5_outlined,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  String _glyph(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => '☉',
        CelestialBodyId.moon => '☽',
        CelestialBodyId.mercury => '☿',
        CelestialBodyId.venus => '♀',
        CelestialBodyId.mars => '♂',
        CelestialBodyId.jupiter => '♃',
        CelestialBodyId.saturn => '♄',
        CelestialBodyId.uranus => '♅',
        CelestialBodyId.neptune => '♆',
        CelestialBodyId.pluto => '♇',
        _ => '★',
      };

  String _signGlyph(ZodiacSign sign) => switch (sign) {
        ZodiacSign.aries => '♈',
        ZodiacSign.taurus => '♉',
        ZodiacSign.gemini => '♊',
        ZodiacSign.cancer => '♋',
        ZodiacSign.leo => '♌',
        ZodiacSign.virgo => '♍',
        ZodiacSign.libra => '♎',
        ZodiacSign.scorpio => '♏',
        ZodiacSign.sagittarius => '♐',
        ZodiacSign.capricorn => '♑',
        ZodiacSign.aquarius => '♒',
        ZodiacSign.pisces => '♓',
      };

  String _signName(ZodiacSign sign) => switch (sign) {
        ZodiacSign.aries => 'Baran',
        ZodiacSign.taurus => 'Byk',
        ZodiacSign.gemini => 'Bliźnięta',
        ZodiacSign.cancer => 'Rak',
        ZodiacSign.leo => 'Lew',
        ZodiacSign.virgo => 'Panna',
        ZodiacSign.libra => 'Waga',
        ZodiacSign.scorpio => 'Skorpion',
        ZodiacSign.sagittarius => 'Strzelec',
        ZodiacSign.capricorn => 'Koziorożec',
        ZodiacSign.aquarius => 'Wodnik',
        ZodiacSign.pisces => 'Ryby',
      };
}

// ── Rise / Transit / Set row ─────────────────────────────────────────────────

class _RiseSetRow extends StatelessWidget {
  const _RiseSetRow({
    required this.riseLabel,
    required this.transitLabel,
    required this.setLabel,
    required this.rise,
    required this.transit,
    required this.set,
    required this.timeFmt,
  });

  final String riseLabel;
  final String transitLabel;
  final String setLabel;
  final DateTime? rise;
  final DateTime? transit;
  final DateTime? set;
  final DateFormat timeFmt;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TimeColumn(
          label: riseLabel,
          icon: Icons.wb_twilight_outlined,
          time: rise,
          timeFmt: timeFmt,
        ),
        _TimeColumn(
          label: transitLabel,
          icon: Icons.wb_sunny_outlined,
          time: transit,
          timeFmt: timeFmt,
        ),
        _TimeColumn(
          label: setLabel,
          icon: Icons.nights_stay_outlined,
          time: set,
          timeFmt: timeFmt,
        ),
      ],
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.label,
    required this.icon,
    required this.time,
    required this.timeFmt,
  });

  final String label;
  final IconData icon;
  final DateTime? time;
  final DateFormat timeFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = time?.toLocal();

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          local != null ? timeFmt.format(local) : '—',
          style: theme.textTheme.titleMedium,
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Detail tile ───────────────────────────────────────────────────────────────

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: iconColor ?? labelColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(color: labelColor),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
