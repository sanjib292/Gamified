# MindQuest

Gamified learning platform — "Duolingo for nonfiction books". Flutter mobile app (iOS/Android) backed by Supabase.

## Architecture
- **State**: Riverpod (AsyncNotifier pattern; DataSource → Repository → Notifier)
- **Navigation**: GoRouter with StatefulShellRoute for tabs
- **Backend**: Supabase (Postgres + Auth + Realtime + Edge Functions + Storage)
- **AI**: OpenAI gpt-4o via Supabase Edge Function (ai-tutor), streaming
- **Gamification**: XP + levels + streaks + achievements + leaderboards

## Key invariants
- Adding a new book = DB rows only, ZERO code changes
- All content (quizzes/flashcards/missions/simulations) is JSONB in lesson_content table
- ContentBlock sealed class forces exhaustive switch on every content type
- XP ledger (xp_logs) is append-only; profiles.xp_total synced by trigger
- Level = GREATEST(1, floor(sqrt(xp/100)) + 1)  — quadratic curve

## Launch strategy
MVP: ONE book — "The Psychology of Money" by Morgan Housel
Architecture is multi-book from day 1.

## Database
32 migrations in supabase/migrations/ — run in sequence.
RLS on every user table. Premium gated by has_active_subscription() helper.

## Commands
```bash
dart run build_runner build --delete-conflicting-outputs  # code-gen
flutter test                                              # unit tests
```
