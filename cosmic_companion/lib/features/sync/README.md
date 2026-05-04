# Supabase Sync (FUTURE)

Synchronizacja danych użytkownika między urządzeniami przez Supabase.

**Drift schema jest już sync-ready od MVP:**
- UUID v4 jako PK (nie autoincrement)
- Kolumny: `createdAt`, `updatedAt`, `deletedAt` (soft delete)
- Kolumna `userId TEXT NULLABLE` — w MVP zawsze NULL, w sync mode = Supabase user ID
- Zero migracji danych przy włączeniu synca

**Plan implementacji:**
- `SupabaseAuthProvider implements AuthProvider` — swap 1 linii w providers.dart
- Supabase Realtime dla live sync
- Push/pull queue + conflict resolution (last-write-wins lub per-field)

**Zarezerwowane dependency (pubspec.yaml):**
```yaml
# supabase_flutter: ^2.x
```
