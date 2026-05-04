import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/database/app_database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final _equipmentListProvider = StreamProvider<List<EquipmentRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.equipment)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();
});

class EquipmentPage extends ConsumerWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final equipmentAsync = ref.watch(_equipmentListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.equipmentTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.equipmentAdd,
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: equipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${AppLocalizations.of(context).error}: $e')),
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.equipmentEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) => _EquipmentTile(
                  item: items[i],
                  onEdit: () => _openForm(context, items[i]),
                  onDelete: () => _softDelete(ref, items[i]),
                ),
              ),
      ),
    );
  }

  void _openForm(BuildContext context, EquipmentRow? existing) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EquipmentFormPage(existing: existing),
      ),
    );
  }

  Future<void> _softDelete(WidgetRef ref, EquipmentRow row) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.equipment)..where((t) => t.id.equals(row.id))).write(
      EquipmentCompanion(deletedAt: Value(DateTime.now().toUtc())),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final EquipmentRow item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.equipmentDelete),
          content: Text(l10n.equipmentDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.equipmentDelete),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: Icon(_typeIcon(item.type)),
        title: Text(item.name),
        subtitle: item.notes != null && item.notes!.isNotEmpty
            ? Text(item.notes!, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
      ),
    );
  }

  IconData _typeIcon(String type) => switch (type) {
        'telescope' => Icons.search,
        'mount' => Icons.settings_input_antenna,
        'camera' => Icons.camera_alt_outlined,
        'eyepiece' => Icons.lens_outlined,
        'filter' => Icons.filter_outlined,
        _ => Icons.category_outlined,
      };
}

// ── Form ──────────────────────────────────────────────────────────────────────

class EquipmentFormPage extends ConsumerStatefulWidget {
  const EquipmentFormPage({super.key, this.existing});

  final EquipmentRow? existing;

  @override
  ConsumerState<EquipmentFormPage> createState() => _EquipmentFormPageState();
}

class _EquipmentFormPageState extends ConsumerState<EquipmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late String _selectedType;
  bool _saving = false;

  static const _types = [
    'telescope',
    'mount',
    'camera',
    'eyepiece',
    'filter',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _notesCtrl = TextEditingController(text: widget.existing?.notes ?? '');
    _selectedType = widget.existing?.type ?? _types.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l10n, String type) => switch (type) {
        'telescope' => l10n.equipmentTypeTelescope,
        'mount' => l10n.equipmentTypeMount,
        'camera' => l10n.equipmentTypeCamera,
        'eyepiece' => l10n.equipmentTypeEyepiece,
        'filter' => l10n.equipmentTypeFilter,
        _ => l10n.equipmentTypeOther,
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final db = ref.read(databaseProvider);
    final now = DateTime.now().toUtc();

    if (widget.existing == null) {
      await db.into(db.equipment).insert(
            EquipmentCompanion.insert(
              id: const Uuid().v4(),
              name: _nameCtrl.text.trim(),
              type: _selectedType,
              notes: Value(_notesCtrl.text.trim().isEmpty
                  ? null
                  : _notesCtrl.text.trim()),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (db.update(db.equipment)
            ..where((t) => t.id.equals(widget.existing!.id)))
          .write(
        EquipmentCompanion(
          name: Value(_nameCtrl.text.trim()),
          type: Value(_selectedType),
          notes: Value(_notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim()),
          updatedAt: Value(now),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? widget.existing!.name : l10n.equipmentAdd),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.equipmentSave),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.equipmentNameLabel),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.error : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(labelText: l10n.equipmentTypeLabel),
              items: _types
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_typeLabel(l10n, t)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(labelText: l10n.equipmentNotesLabel),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
