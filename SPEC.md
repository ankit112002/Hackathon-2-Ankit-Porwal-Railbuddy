# RailBuddy: Complete Build Spec (for Cursor / Antigravity)

This file is the single source of truth to build the whole RailBuddy app end to end: Flutter app, Supabase backend, matching logic, screens, realtime updates and a demo scenario. Give this file to your coding agent and follow the build order in Section 14.

## 0. How to use this file

1. Create an empty folder `railbuddy` and open it in Cursor or Antigravity.
2. Put this file in the project root (name it `SPEC.md`). In Cursor you can also copy Section 1 into `.cursor/rules`.
3. Attach your Stitch design screenshots (the 15 screens) to the agent chat when building the UI.
4. Run the agent prompts from **Section 14, one at a time, in order**. After each prompt, run the app and check the "Done when" line before moving on.
5. Do your Supabase work first (Section 4). The agent cannot create your Supabase project for you.

---

## 1. Project rules for the agent (read first)

**What we are building:** RailBuddy, a mobile app (Android first) that helps train passengers swap seats and helps families and friends sit together. It runs on **fake demo data** for a solo hackathon, with real multi-user behavior through Supabase.

**Core promise:** "Find a suitable seat swap for yourself, or find a better seating arrangement for your entire group."

**Hard rules:**
- Flutter (Dart 3) + Supabase + Riverpod + go_router. No other backend, no Firebase, no custom server.
- No real PNR, no IRCTC integration, no real personal data, no payments, no push notifications, no AI/LLM calls.
- No login. A demo user is chosen on the "Select Passenger" screen and stored locally (`shared_preferences`).
- The app only changes seats in its own database. It never claims to change official railway reservations.
- Every swap needs consent from both passengers.
- Matching logic lives in pure Dart functions in `lib/logic/` (no Flutter imports) so it can be unit tested.
- Show the footnote "Swaps are voluntary and subject to railway rules." on Home, Request Detail and Final Plan.
- Keep code simple and readable. Prefer small files. No unused code.

**Language/format:** Dart null safety, `const` constructors where possible, `flutter analyze` must pass with no errors.

---

## 2. Tech stack and packages

| Layer | Choice |
|---|---|
| UI | Flutter (stable), Material 3, `google_fonts` (Plus Jakarta Sans) |
| State | `flutter_riverpod` |
| Navigation | `go_router` |
| Backend | Supabase (Postgres + Realtime) via `supabase_flutter` |
| Local storage | `shared_preferences` (stores the selected demo passenger id) |
| Tests | `flutter_test` |

`pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.5.1
  go_router: ^14.0.0
  google_fonts: ^6.2.1
  shared_preferences: ^2.2.3
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

(Use the latest compatible versions if these are outdated.)

Run with keys (never hard-code them):

```
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxxx
```

---

## 3. Project structure

```
lib/
  main.dart
  app.dart                      # MaterialApp.router + theme
  core/
    env.dart                    # reads dart-define values
    router.dart                 # go_router routes
    theme/
      colors.dart               # color tokens
      app_theme.dart            # ThemeData
    widgets/                    # shared UI components
      primary_button.dart
      app_chip.dart
      status_chip.dart
      seat_chip.dart
      seat_tile.dart
      score_ring.dart
      dark_header_scaffold.dart # dark header + overlapping cream sheet
      ticket_card.dart
      stepper_bar.dart
      empty_state.dart
      error_state.dart
      loading_skeleton.dart
  models/
    trip.dart
    group.dart
    passenger.dart
    swap_request.dart
    plan.dart
  logic/                        # pure Dart, unit tested
    seat_utils.dart
    score.dart
    matcher.dart
    optimizer.dart
  data/
    supabase_client.dart
    session_store.dart          # shared_preferences wrapper
    trip_repo.dart
    group_repo.dart
    passenger_repo.dart
    request_repo.dart
  providers/
    providers.dart              # all Riverpod providers
  features/
    onboarding/
    select_passenger/
    home/
    trip_details/
    group/                      # create_group, join_group, dashboard
    seat_map/
    swap/                       # preferences, matches, request_detail
    optimizer/
    requests/                   # list + incoming sheet
    final_plan/
test/
  seat_utils_test.dart
  score_test.dart
  matcher_test.dart
  optimizer_test.dart
supabase/
  schema.sql
  seed.sql
```

---

## 4. Supabase setup (do this first)

1. Create a free Supabase project.
2. Open **SQL Editor** and run `schema.sql` below, then `seed.sql`.
3. Copy the project URL and the anon key (Settings, API) for `--dart-define`.
4. For the demo, Row Level Security is disabled on these tables (no login). Do not use this in production.

### 4.1 `supabase/schema.sql`

```sql
create extension if not exists "pgcrypto";

create table trips (
  id uuid primary key default gen_random_uuid(),
  train_no text not null,
  train_name text not null,
  from_station text not null,
  to_station text not null,
  depart_time text,
  arrive_time text,
  journey_date date not null
);

create table groups (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  name text not null,
  join_code text not null unique
);

create table passengers (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  group_id uuid references groups(id) on delete set null,
  name text not null,
  coach text not null,          -- 'S1'..'S5'
  seat_no int not null,         -- 1..72 (sleeper berths)
  willing_to_swap boolean not null default true,
  constraint uq_seat unique (trip_id, coach, seat_no) deferrable initially deferred
);

create table swap_requests (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  requester_id uuid not null references passengers(id) on delete cascade,
  target_id uuid not null references passengers(id) on delete cascade,
  requester_seat text not null,   -- snapshot like 'S1/23'
  target_seat text not null,      -- snapshot like 'S2/43'
  plan_id uuid,                   -- groups the requests of one optimizer plan
  message text,
  status text not null default 'pending'
    check (status in ('pending','accepted','rejected','cancelled','invalid')),
  created_at timestamptz not null default now(),
  responded_at timestamptz
);

create index on passengers (trip_id);
create index on swap_requests (target_id, status);
create index on swap_requests (requester_id, status);
create index on swap_requests (plan_id);

-- Demo mode: no auth, so RLS stays off.
alter table trips disable row level security;
alter table groups disable row level security;
alter table passengers disable row level security;
alter table swap_requests disable row level security;

-- Realtime
alter publication supabase_realtime add table passengers;
alter publication supabase_realtime add table swap_requests;

-- Accept a swap atomically (swaps the two passengers' seats).
create or replace function accept_swap(req_id uuid) returns text
language plpgsql as $$
declare r swap_requests; a passengers; b passengers;
begin
  select * into r from swap_requests where id = req_id and status = 'pending' for update;
  if not found then return 'not_pending'; end if;

  select * into a from passengers where id = r.requester_id for update;
  select * into b from passengers where id = r.target_id for update;

  -- If either seat changed since the request was made, mark it invalid.
  if (a.coach || '/' || a.seat_no) <> r.requester_seat
     or (b.coach || '/' || b.seat_no) <> r.target_seat then
    update swap_requests set status = 'invalid', responded_at = now() where id = req_id;
    return 'invalid';
  end if;

  update passengers set coach = b.coach, seat_no = b.seat_no where id = a.id;
  update passengers set coach = a.coach, seat_no = a.seat_no where id = b.id;
  update swap_requests set status = 'accepted', responded_at = now() where id = req_id;
  return 'accepted';
end $$;

create or replace function reject_swap(req_id uuid) returns text
language plpgsql as $$
begin
  update swap_requests set status = 'rejected', responded_at = now()
  where id = req_id and status = 'pending';
  return 'rejected';
end $$;

create or replace function cancel_swap(req_id uuid) returns text
language plpgsql as $$
begin
  update swap_requests set status = 'cancelled', responded_at = now()
  where id = req_id and status = 'pending';
  return 'cancelled';
end $$;
```

### 4.2 `supabase/seed.sql` (demo data)

```sql
do $$
declare t uuid; g uuid;
begin
  insert into trips (train_no, train_name, from_station, to_station, depart_time, arrive_time, journey_date)
  values ('12345', 'Demo Express', 'Indore Jn', 'Mumbai', '18:40', '06:15', '2026-11-14')
  returning id into t;

  insert into groups (trip_id, name, join_code) values (t, 'Sharma Family', 'RAIL-7X92')
  returning id into g;

  -- Sharma Family (scattered across 5 coaches)
  insert into passengers (trip_id, group_id, name, coach, seat_no, willing_to_swap) values
    (t, g, 'Aman',   'S1', 23, true),
    (t, g, 'Bhavna', 'S2', 41, true),
    (t, g, 'Chetan', 'S2', 42, true),
    (t, g, 'Disha',  'S3', 56, true),
    (t, g, 'Esha',   'S4', 21, true),
    (t, g, 'Farhan', 'S5', 37, true);

  -- Volunteers in the target bay (S2, seats 41 to 48)
  insert into passengers (trip_id, group_id, name, coach, seat_no, willing_to_swap) values
    (t, null, 'Passenger P', 'S2', 43, true),
    (t, null, 'Passenger Q', 'S2', 44, true),
    (t, null, 'Passenger R', 'S2', 45, true),
    (t, null, 'Passenger S', 'S2', 46, true),
    (t, null, 'Passenger T', 'S2', 47, false),
    (t, null, 'Passenger U', 'S2', 48, false);

  -- Other passengers for the individual swap demo
  insert into passengers (trip_id, group_id, name, coach, seat_no, willing_to_swap) values
    (t, null, 'Rahul',  'S1', 24, true),   -- Lower berth next to Aman
    (t, null, 'Priya',  'S1', 25, true),
    (t, null, 'Karan',  'S1', 22, false),
    (t, null, 'Neha',   'S1', 28, true),
    (t, null, 'Vikas',  'S1', 17, true),
    (t, null, 'Sunita', 'S3', 57, true),
    (t, null, 'Manoj',  'S3', 49, true),
    (t, null, 'Ritu',   'S3', 60, false),
    (t, null, 'Deepak', 'S4', 22, true),
    (t, null, 'Anjali', 'S4', 30, true),
    (t, null, 'Imran',  'S5', 38, true),
    (t, null, 'Pooja',  'S5', 36, false);
end $$;
```

---

## 5. Domain logic (pure Dart, in `lib/logic/`)

### 5.1 Seat model (Sleeper coach)

- Coaches `S1` to `S5`. Each coach has 72 berths, numbered 1 to 72.
- One bay holds 8 berths: 6 main berths and 2 side berths.
- Bay number (0-based) = `(seat - 1) ~/ 8`. Berth type comes from `(seat - 1) % 8`: Lower, Middle, Upper, Lower, Middle, Upper, Side Lower, Side Upper.
- Example: seats 41 to 48 are the same bay (bay index 5, shown as "Bay 6").

`seat_utils.dart`:

```dart
const berthTypes = [
  'Lower', 'Middle', 'Upper', 'Lower', 'Middle', 'Upper', 'Side Lower', 'Side Upper'
];

int bayOf(int seat) => (seat - 1) ~/ 8;
String berthOf(int seat) => berthTypes[(seat - 1) % 8];
int coachNo(String coach) => int.parse(coach.substring(1)); // 'S2' -> 2
String seatLabel(String coach, int seat) => '$coach / $seat'; // 'S2 / 43'
String seatKey(String coach, int seat) => '$coach/$seat';     // 'S2/43' (DB snapshot)
int bayStartSeat(int seat) => bayOf(seat) * 8 + 1;
int bayEndSeat(int seat) => bayOf(seat) * 8 + 8;
```

### 5.2 Group Seating Score (`score.dart`)

| Situation | Score |
|---|---|
| All members in the same bay | 100 |
| Same coach, different bays | 80 |
| Coaches next to each other (difference of 1) | 60 |
| Anything else (scattered) | 20 |

```dart
import '../models/passenger.dart';
import 'seat_utils.dart';

int groupScore(List<Passenger> g) {
  if (g.length < 2) return 100;
  final sameCoach = g.every((p) => p.coach == g.first.coach);
  if (sameCoach && g.every((p) => bayOf(p.seatNo) == bayOf(g.first.seatNo))) return 100;
  if (sameCoach) return 80;
  final nos = g.map((p) => coachNo(p.coach)).toList()..sort();
  return (nos.last - nos.first <= 1) ? 60 : 20;
}

int coachSpread(List<Passenger> g) => g.map((p) => p.coach).toSet().length;
```

Status color per member (dashboard): compare with the group's main bay. Green = same bay, amber = same coach, red = other coach. The "main bay" is the bay holding most members (ties: lowest coach number).

### 5.3 Individual matcher (`matcher.dart`)

Candidates are passengers of the same trip who are not me and not in my group. Score out of 100:

| Rule | Points |
|---|---|
| Berth type equals my preferred berth | +40 |
| Same coach as me | +30 |
| In a bay where my group already sits ("near group" ON) | +20 |
| Seat number closeness (same coach only): `10 - min(10, |seat diff|)` | up to +10 |

```dart
class Match {
  final Passenger passenger;
  final int score;
  const Match(this.passenger, this.score);
}

List<Match> findMatches({
  required Passenger me,
  required List<Passenger> all,
  required List<Passenger> group,
  String? preferredBerth,
  bool sameCoachOnly = false,
  bool nearGroup = false,
  bool onlyOpen = true,
}) {
  final groupIds = group.map((g) => g.id).toSet();
  final result = <Match>[];
  for (final p in all) {
    if (p.id == me.id || groupIds.contains(p.id)) continue;
    if (onlyOpen && !p.willingToSwap) continue;
    if (sameCoachOnly && p.coach != me.coach) continue;
    var s = 0;
    if (preferredBerth != null && berthOf(p.seatNo) == preferredBerth) s += 40;
    if (p.coach == me.coach) {
      s += 30;
      final diff = (p.seatNo - me.seatNo).abs();
      s += 10 - (diff > 10 ? 10 : diff);
    }
    if (nearGroup &&
        group.any((g) => g.coach == p.coach && bayOf(g.seatNo) == bayOf(p.seatNo))) {
      s += 20;
    }
    result.add(Match(p, s));
  }
  result.sort((a, b) => b.score.compareTo(a.score));
  return result;
}
```

### 5.4 Group optimizer (`optimizer.dart`)

Goal: bring all group members into one bay with the fewest voluntary swaps. If impossible, fall back to the same coach.

Algorithm:
1. If the group has more than 8 members, skip the bay plan (use the coach plan).
2. For every bay that contains at least one group member (candidate bays):
   - `inside` = members already in that bay. `outside` = the other members.
   - `pool` = passengers in that bay who are NOT in the group and `willing_to_swap`.
   - If `pool.length < outside.length`, skip this bay.
   - Pair each outside member with one volunteer from the pool. Prefer a volunteer whose berth type equals the member's current berth type.
   - Plan cost = number of swaps (`outside.length`).
3. Pick the plan with the fewest swaps (ties: the bay with more members already inside).
4. If no bay works, build a **coach plan**: choose the coach with the most members, and pair each outside member with a willing non-group passenger in that coach (any bay). Plan score = 80.
5. If nothing works, return `null`. The UI shows "Arrangement not possible right now."

```dart
class SwapPair {
  final Passenger member;     // group member who moves
  final Passenger volunteer;  // other passenger who gives the seat
  const SwapPair(this.member, this.volunteer);
}

class Plan {
  final String coach;
  final int? bay;             // null for a coach plan
  final List<SwapPair> swaps;
  final int targetScore;      // 100 for a bay plan, 80 for a coach plan
  const Plan(this.coach, this.bay, this.swaps, this.targetScore);
}

Plan? bestPlan({required List<Passenger> group, required List<Passenger> all}) {
  if (group.length < 2) return null;
  final groupIds = group.map((g) => g.id).toSet();
  final others = all.where((p) => !groupIds.contains(p.id) && p.willingToSwap).toList();

  Plan? best;
  if (group.length <= 8) {
    final bays = <(String, int)>{for (final m in group) (m.coach, bayOf(m.seatNo))};
    for (final (coach, bay) in bays) {
      final inside = group.where((m) => m.coach == coach && bayOf(m.seatNo) == bay).toList();
      final outside = group.where((m) => !inside.contains(m)).toList();
      final pool = others.where((p) => p.coach == coach && bayOf(p.seatNo) == bay).toList();
      if (pool.length < outside.length) continue;

      final swaps = <SwapPair>[];
      for (final m in outside) {
        pool.sort((a, b) {
          int rank(Passenger p) => berthOf(p.seatNo) == berthOf(m.seatNo) ? 0 : 1;
          return rank(a).compareTo(rank(b));
        });
        swaps.add(SwapPair(m, pool.removeAt(0)));
      }
      final candidate = Plan(coach, bay, swaps, 100);
      if (best == null ||
          swaps.length < best.swaps.length ||
          (swaps.length == best.swaps.length &&
              inside.length > group.where((m) => m.coach == best!.coach && bayOf(m.seatNo) == best.bay).length)) {
        best = candidate;
      }
    }
  }
  if (best != null) return best;

  // Coach plan fallback
  final counts = <String, int>{};
  for (final m in group) { counts[m.coach] = (counts[m.coach] ?? 0) + 1; }
  final coach = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  final outside = group.where((m) => m.coach != coach).toList();
  final pool = others.where((p) => p.coach == coach).toList();
  if (pool.length < outside.length) return null;
  final swaps = [for (var i = 0; i < outside.length; i++) SwapPair(outside[i], pool[i])];
  return Plan(coach, null, swaps, 80);
}
```

### 5.5 Reject handling ("Find another match")

When a request in a plan is rejected, call `bestPlan` again with `all` excluding passengers who already rejected. Easiest: keep a local set `excludedIds` in the UI state and filter `all` before calling `bestPlan`. Show "Arrangement not possible right now" if the result is `null`.

---

## 6. Data layer

Create one repository per area. All methods return typed models. Keep Supabase calls only inside `lib/data/`.

**`passenger_repo.dart`**
- `Stream<List<Passenger>> watchTripPassengers(String tripId)` using `supabase.from('passengers').stream(primaryKey: ['id']).eq('trip_id', tripId)`.
- `Future<Passenger> getById(String id)`.
- `Future<void> updateWillingToSwap(String id, bool value)`.
- `Future<void> updateSeat(String id, {required String coach, required int seatNo, String? name})` (used by Trip Details edit).
- `Future<void> assignToGroup(String passengerId, String? groupId)`.

**`group_repo.dart`**
- `Future<Group?> getByJoinCode(String code)`.
- `Future<Group> createGroup({required String tripId, required String name})` generates a code like `RAIL-XXXX` (4 random uppercase letters or digits) and retries if it already exists.
- `Future<Group?> getById(String id)`.

**`trip_repo.dart`**
- `Future<Trip> getDemoTrip()` returns the first trip (the seed trip).
- `Future<void> updateTrip(...)` optional.

**`request_repo.dart`**
- `Stream<List<SwapRequest>> watchIncoming(String passengerId)` (`target_id = me`).
- `Stream<List<SwapRequest>> watchOutgoing(String passengerId)` (`requester_id = me`).
- `Future<String> sendRequest({required Passenger from, required Passenger to, String? planId, String? message})` inserts a row with seat snapshots. Rejects duplicates (same requester and target with status pending).
- `Future<List<String>> sendPlanRequests(Plan plan, String tripId)` creates one request per `SwapPair` with a shared new `plan_id`, using `requester = member`, `target = volunteer`.
- `Future<String> accept(String id)` calls `rpc('accept_swap', params: {'req_id': id})`.
- `Future<void> reject(String id)`, `Future<void> cancel(String id)` call the matching RPCs.

**`session_store.dart`**
- `Future<String?> getPassengerId()`, `Future<void> setPassengerId(String id)`, `Future<void> clear()`, plus `onboardingSeen` flag.

### Models (`lib/models/`)

Plain Dart classes with `fromMap` / `toMap`:

```dart
class Passenger {
  final String id, tripId, name, coach;
  final String? groupId;
  final int seatNo;
  final bool willingToSwap;
  const Passenger({required this.id, required this.tripId, required this.name,
    required this.coach, required this.seatNo, required this.willingToSwap, this.groupId});
  factory Passenger.fromMap(Map<String, dynamic> m) => Passenger(
    id: m['id'], tripId: m['trip_id'], groupId: m['group_id'], name: m['name'],
    coach: m['coach'], seatNo: m['seat_no'], willingToSwap: m['willing_to_swap']);
  String get seatKey => '$coach/$seatNo';
}
```

Create `Trip`, `Group`, `SwapRequest` the same way (`SwapRequest` has `status` as an enum: pending, accepted, rejected, cancelled, invalid).

---

## 7. State management (Riverpod, `lib/providers/providers.dart`)

| Provider | Type | Purpose |
|---|---|---|
| `sessionStoreProvider` | Provider | shared_preferences wrapper |
| `currentPassengerIdProvider` | StateProvider<String?> | demo user id (loaded at startup) |
| `tripProvider` | FutureProvider<Trip> | the demo trip |
| `tripPassengersProvider` | StreamProvider<List<Passenger>> | all passengers (realtime) |
| `currentPassengerProvider` | Provider<Passenger?> | derived from the two providers above |
| `myGroupProvider` | Provider<List<Passenger>> | passengers with the same group_id as me |
| `groupScoreProvider` | Provider<int> | `groupScore(myGroup)` |
| `incomingRequestsProvider` | StreamProvider | requests sent to me |
| `outgoingRequestsProvider` | StreamProvider | requests I sent |
| `swapPrefsProvider` | StateProvider<SwapPrefs> | preferred berth and toggles |
| `matchesProvider` | Provider<List<Match>> | `findMatches(...)` from prefs and data |
| `planProvider` | Provider<Plan?> | `bestPlan(...)`, excluding rejected passengers |
| `excludedIdsProvider` | StateProvider<Set<String>> | passengers who rejected a plan request |
| `activePlanIdProvider` | StateProvider<String?> | plan id of the last "Send all requests" |

The app must update live: when a seat swap is accepted, the dashboard score, seat map and final plan must refresh automatically through `tripPassengersProvider`.

---

## 8. Navigation (`lib/core/router.dart`, go_router)

| Route | Screen | Shell |
|---|---|---|
| `/splash` | Splash | none |
| `/onboarding` | Onboarding (3 slides) | none |
| `/select-passenger` | Select Passenger | none |
| `/home` | Home | tab shell |
| `/group` | Group Dashboard | tab shell |
| `/requests` | Requests list | tab shell |
| `/profile` | Profile (simple: current passenger, "Switch passenger", "Open to swap" toggle) | tab shell |
| `/trip` | Trip Details | sub-flow |
| `/group/create` | Create Group | sub-flow |
| `/group/join` | Join Group | sub-flow |
| `/seat-map` | Coach Seat Map | sub-flow |
| `/swap/preferences` | Swap Preferences | sub-flow |
| `/swap/matches` | Swap Matches | sub-flow |
| `/swap/detail/:passengerId` | Request Detail | sub-flow |
| `/optimizer` | Optimizer Result | sub-flow |
| `/final-plan` | Final Seating Plan | sub-flow |

- Use a `StatefulShellRoute` with a custom floating bottom navigation for the 4 tab routes (Home, My Group, Requests, Profile).
- Sub-flow routes have no bottom navigation; they use a sticky bottom action bar.
- Redirect logic: no passenger selected means go to `/select-passenger`. Onboarding is shown once.
- Incoming requests open as a modal bottom sheet (not a route), triggered by a realtime listener (Section 9, Screen 13).

---

## 9. Screens: behavior and data

The visual design comes from the Stitch screens (mint + ink style). This section defines what each screen shows and does.

**1. Splash and Onboarding** (`/splash`, `/onboarding`)
- Splash for ~1.5 s, then onboarding (3 slides) if not seen, else `/select-passenger` or `/home`.
- "Get Started" sets `onboardingSeen = true` and goes to `/select-passenger`.

**2. Select Passenger** (`/select-passenger`)
- Lists all passengers of the demo trip who belong to a group (the 6 Sharma Family members), plus a section "Other passengers" with the volunteers (P, Q, R, S, and others) so you can accept requests as them in the demo.
- Selecting one and tapping "Continue as X" saves the id and goes to `/home`.

**3. Home** (`/home`)
- Shows greeting, trip form fields (From, To, Travellers, Coach) filled from the trip and group (read-only, tap "Edit" goes to `/trip`).
- Segmented chips: Group (default), Single swap, Multi swap. "Single swap" goes to `/swap/preferences`.
- "Seat swap open" toggle updates `willing_to_swap` for the current passenger.
- Primary button "Bring group together" goes to `/group` (if the user has no group, go to `/group/create`).
- Shows the footnote about voluntary swaps.

**4. Trip Details** (`/trip`)
- Edits the current passenger's name, coach, seat and "open to swap". Berth type is derived and shown read-only. "Use demo trip" resets to seed values.

**5. Create Group** (`/group/create`)
- Group name + member list (search and add passengers by name from the trip) + generated join code with Copy and Share.
- "Create group" inserts the group and assigns the selected passengers.

**6. Join Group** (`/group/join`)
- 8-character code input, preview card after a valid code, "Join group" assigns the current passenger to the group.

**7. Group Dashboard** (`/group`)
- Hero score card (`groupScoreProvider`), "Scattered across N coaches", "Best possible: X/100 with N swaps" from `planProvider`.
- Stepper: Group, Plan, Requests, Seated (derived from state).
- Member rows with seat chip and status dot (same bay, same coach, other coach). Mark "You".
- Primary button "Bring my group together" goes to `/optimizer`.

**8. Coach Seat Map** (`/seat-map`)
- Coach chips S1 to S5, a bay layout for the selected coach and bay (default: the bay with most group members), seat tiles with the states from Section 10, a legend and a bottom sheet listing passengers in this bay.
- Tapping a tile shows a small popup with the passenger's seat, berth type and an "open to swap" tag (no personal details).

**9. Swap Preferences** (`/swap/preferences`)
- Shows my seat, preferred berth chips, three toggles (same coach only, sit near my group, only open to swap). "Find matches" goes to `/swap/matches`.

**10. Swap Matches** (`/swap/matches`)
- List from `matchesProvider` with seat badge, berth chip, same coach chip, match percentage and "Send request" which opens `/swap/detail/:passengerId`.
- Empty state if there are no matches.

**11. Swap Request Detail** (`/swap/detail/:passengerId`)
- Ticket-style summary (my seat vs their seat), "Why this match" rows, optional message, footnote. "Send request" calls `sendRequest`, then shows the success dialog and goes to `/requests`.

**12. Group Optimizer Result** (`/optimizer`)
- Loading skeleton briefly, then the before and after card (current score to target score), target bay mini map, proposed swaps list.
- "Send all N requests" calls `sendPlanRequests`, stores `activePlanId`, shows the success dialog and goes to `/requests`.
- "Try another plan" re-runs `bestPlan` excluding the volunteers used in the current plan.
- If `planProvider` is null: show "Arrangement not possible right now" with an explanation and a back button.

**13. Requests** (`/requests`) and Incoming Request sheet
- Tabs: Pending, Accepted, Rejected (outgoing requests) with the progress card ("2 of 4 accepted" for the active plan).
- Pending card actions: Cancel. Rejected card action: "Find another match" (adds the volunteer to `excludedIds`, goes to `/optimizer`).
- A third section or tab "Incoming" shows requests sent to me with Accept and Reject buttons.
- A realtime listener on `incomingRequestsProvider` opens the Incoming Request bottom sheet whenever a new pending request arrives for the current passenger. Accept calls `accept_swap`; show a snackbar on `invalid` ("Seat changed, please find again").

**14. Final Seating Plan** (`/final-plan`)
- Opens automatically from the Requests screen when all requests of the active plan are accepted (or from Dashboard when score is 100).
- Ticket card: coach, bay range, group name, plan id, S2/41 and S2/43 style seat blocks, barcode. Row of member avatars, "All N seated together · Score 100/100", footnote, "Show to TTE / Share Plan" button (the share action uses a simple text summary via a share sheet or copies it to clipboard if no package is added).

**15. Profile** (`/profile`)
- Current passenger card, "Open to swap" toggle, "Switch passenger" (clears session and goes to `/select-passenger`), app version.

---

## 10. Design system (from the Stitch designs)

Colors (`lib/core/theme/colors.dart`):

| Token | Hex |
|---|---|
| ink | `#0F1115` |
| inkSoft | `#1B1F27` |
| mint | `#2FE3A5` |
| mintPressed | `#1FC48B` |
| mintScreenBg | `#D8F2E6` |
| mintTint | `#EAF8F1` |
| cream | `#F7F4EA` |
| white | `#FFFFFF` |
| fieldGrey | `#EEF1F5` |
| textPrimary | `#0F1115` |
| textSecondary | `#5B6470` |
| border | `#E1E5EA` |
| pending | `#F5A524` |
| accepted | `#12B27A` |
| rejected | `#E5484D` |

Rules:
- Text on mint is always ink.
- Typography: Plus Jakarta Sans. Hero 30 bold, title 22 semibold, section 17 semibold, card title 16 semibold, body 14, caption 12.
- Spacing: 8 px grid. Side margin 20. Radii: cards 24, fields 16, buttons 18, chips fully rounded, seat tiles 12.
- Dark header + overlapping cream sheet layout via `DarkHeaderScaffold`.
- Floating bottom navigation (ink, rounded, mint active icon).
- Sticky bottom action bar on sub-flow screens.

Shared widgets to build once and reuse: `PrimaryButton` (mint, ink text, trailing arrow), `DarkButton`, `AppChip` (selectable), `StatusChip`, `SeatChip` (pill like `S2 / 43`), `SeatTile` (states: yours, groupMember, other, openToSwap, selected), `ScoreRing`, `TicketCard` (ink top, cream bottom, notches, perforation line, barcode), `StepperBar` (Group, Plan, Requests, Seated), `DarkHeaderScaffold`, `EmptyState`, `ErrorState`, `LoadingSkeleton`.

Motion: short 200 ms fades and slides. Animate the score ring when the score changes.

Accessibility: tap targets at least 48 px, never rely on color alone for status.

---

## 11. End-to-end journeys

### Journey A: Individual seat swap
1. Aman opens the app, selects "Aman" on Select Passenger, lands on Home.
2. Taps "Single swap", sets preferred berth "Lower", keeps the toggles on, taps "Find matches".
3. Matches list shows Rahul (S1/24, Lower berth, same coach) at the top. Aman taps "Send request", reviews the ticket card, sends.
4. A `swap_requests` row is created with status `pending` and seat snapshots.
5. On a second device (or after switching the demo user to Rahul), the Incoming Request sheet opens. Rahul taps Accept.
6. `accept_swap` swaps the seats. Aman is now S1/24 and Rahul is S1/23. Both screens update live.

### Journey B: Group seating (main demo)
1. As Aman, open Home and tap "Bring group together". The dashboard shows score 20/100, "Scattered across 5 coaches".
2. Tap "Bring my group together". The optimizer shows target S2, Bay 41 to 48, 4 swaps, score 20 to 100.
3. Tap "Send all 4 requests". Four requests are created with the same `plan_id`.
4. Switch the demo user to Passenger P, Q, R and S in turn. For each, accept the incoming request. After each accept the Requests progress card updates ("1 of 4", "2 of 4"...).
5. When all four are accepted, the Final Seating Plan screen opens with score 100/100 and all six members in S2 seats 41 to 46.

### Journey C: A rejection
1. In Journey B, as Passenger R tap Reject.
2. As Aman, the Requests screen shows one Rejected card. Tap "Find another match".
3. The optimizer re-runs excluding R. If Passenger T or U is open to swap in the bay it picks them; otherwise it shows "Arrangement not possible right now" and offers the coach plan if available.

---

## 12. Edge cases to handle

- **Duplicate request:** do not allow a second pending request between the same two passengers.
- **Seat changed before accepting:** `accept_swap` returns `invalid`; show "Seat changed, please find again".
- **User not in a group:** hide group features and offer Create or Join Group.
- **Group larger than 8:** skip the bay plan, use the coach plan.
- **No volunteers in the bay:** use the coach plan, else show "not possible".
- **Passenger turns off "Open to swap":** they no longer appear in matches or plans.
- **Network errors:** show `ErrorState` with a Retry button; never crash.
- **Loading:** show `LoadingSkeleton` for lists and the optimizer.
- **Empty lists:** show `EmptyState` with a clear action.
- **Pending requests when someone leaves the screen:** they stay pending; the Requests screen always reflects the database.

---

## 13. Tests (`test/`)

Write unit tests for the logic using the seed data as fixtures:

- `seat_utils_test.dart`: `bayOf(41) == 5`, `bayOf(48) == 5`, `bayOf(49) == 6`, `berthOf(1) == 'Lower'`, `berthOf(7) == 'Side Lower'`.
- `score_test.dart`: the 6 Sharma members give 20; all in S2 seats 41 to 46 give 100; all in S2 but different bays give 80.
- `matcher_test.dart`: for Aman with preferred berth `Lower` and `sameCoachOnly`, Rahul (S1/24) is ranked first; non-willing passengers are excluded; group members are excluded.
- `optimizer_test.dart`: the seed data returns a plan with `coach == 'S2'`, `bay == 5`, 4 swaps, `targetScore == 100`; if P, Q, R, S are set to `willingToSwap: false`, the result is `null` or a coach plan.

`flutter test` must pass.

---

## 14. Build order and agent prompts

Paste these one at a time. Do not move on until "Done when" is true.

### Prompt 1: Scaffold
### Prompt 2: Theme and shared widgets
### Prompt 3: Models and logic with tests
### Prompt 4: Data layer
### Prompt 5: Providers and navigation
### Prompt 6: Onboarding, Select Passenger, Home, Profile, Trip Details
### Prompt 7: Individual swap (end to end)
### Prompt 8: Groups and dashboard
### Prompt 9: Group optimizer and final plan
### Prompt 10: Polish and states

---

## 15. Demo checklist and definition of done

**Before the demo**
- [ ] Re-run `seed.sql` (or a reset script) so the data is fresh.
- [ ] Two phones or emulators ready, or be ready to use the "Switch passenger" feature.
- [ ] Internet works and the Supabase project is awake.
- [ ] Build an APK: `flutter build apk --release --dart-define=...`.

**90-second demo script**
1. Show the problem on the dashboard: Sharma Family, 5 coaches, score 20.
2. Individual swap: Aman requests a swap with Rahul; accept on the second device.
3. Group optimizer: show the plan (4 swaps, 20 to 100) and send all requests.
4. Accept as P, Q, R (reject S once to show handling, then retry).
5. Final plan: ticket card, score 100, "Show to TTE".
6. Say clearly: swaps are voluntary and subject to railway rules; the app does not change official reservations.

**Definition of done**
- [ ] Journeys A, B and C work end to end with real Supabase data and realtime updates.
- [ ] All 15 screens exist and match the Stitch designs.
- [ ] `flutter analyze` has no errors and `flutter test` passes.
- [ ] No real PNR or personal data anywhere.
- [ ] Disclaimer visible on Home, Request Detail and Final Plan.
- [ ] README explains setup in under 10 steps.

---

## 16. Out of scope (do not build)

Real PNR or IRCTC integration, live train tracking, OTP login, push notifications, payments, AI chatbot, automatic changes in the railway reservation system, iOS-specific work, multi-train or multi-trip support.
