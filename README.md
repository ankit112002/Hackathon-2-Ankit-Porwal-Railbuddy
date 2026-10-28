# RailBuddy 🚆🤝
**Smart Group Seating & Voluntary Seat Swaps for Train Passengers**

RailBuddy connects train passengers to voluntarily swap berths and helps families and groups of friends scattered across sleeper coaches sit together in the same bay with the fewest possible swaps.

> *Disclaimer: Swaps are voluntary and subject to railway rules. RailBuddy operates on voluntary mutual consent between passengers and does not modify official railway reservation records.*

---

## ⚡ Quick Setup Guide (Under 10 Steps)

The demo Supabase project **railbuddy** (`mpqwpoqkzhrmxvmgdaxg`, Mumbai) already has the schema, swap functions, realtime, and seed data.

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Confirm the database**
   Tables: `trips`, `groups`, `passengers`, `swap_requests`. Join code: `RAIL-7X92`. If you need a fresh demo, open the SQL editor and run [`supabase/seed.sql`](supabase/seed.sql). That script deletes the previous demo trip first.

3. **Keys stay out of source**
   `secrets.json` is gitignored and already filled for this project. On another machine, copy [`secrets.example.json`](secrets.example.json) and paste the project URL and anon key from Supabase → Project Settings → API.

4. **Run unit tests and analysis**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Launch the app**
   ```bash
   flutter run --dart-define-from-file=secrets.json
   ```
   In Cursor or VS Code, the **RailBuddy** launch config does the same thing.

6. **Build an APK**
   ```bash
   flutter build apk --release --dart-define-from-file=secrets.json
   ```

Row Level Security is off on these four tables because the demo has no login. Do not use that setup in production.

If you create a new Supabase project instead, run [`supabase/schema.sql`](supabase/schema.sql) and then [`supabase/seed.sql`](supabase/seed.sql) in the SQL editor, then put that project's URL and anon key in `secrets.json`.

---

## 🎬 90-Second Demo Script

### Journey A: Individual Seat Swap
1. Open the app, proceed through onboarding, and choose **Aman (S1/23, Middle Berth)** on the **Select Passenger** screen.
2. On Home, select **Single Swap**, choose preferred berth **Lower**, and tap **Find Matches**.
3. Select **Rahul (S1/24)** at the top of the list, review the ticket preview card, and tap **Send Swap Request**.
4. Go to **Profile -> Switch Demo Passenger** and select **Rahul**.
5. The **Incoming Request** sheet pops up in realtime. Tap **Accept Swap**.
6. Both seats update immediately in the database (Aman is now S1/24, Rahul is S1/23).

### Journey B: Group Seating Optimization (Main Hackathon Demo)
1. Switch demo passenger back to **Aman**.
2. Tap **Bring group together** to view the **Group Dashboard**. Observe that the Sharma Family is scattered across 5 coaches with an initial cohesion score of **20/100**.
3. Tap **Bring my group together**. The optimizer calculates the optimal 4 swaps in **Coach S2, Bay 6 (Seats 41–48)** to achieve a perfect **100/100** score.
4. Tap **Send all 4 requests**.
5. Switch to **Passenger P**, **Passenger Q**, **Passenger R**, and **Passenger S** in turn and accept each request.
6. Observe the live progress bar in the **Requests** tab (*1 of 4, 2 of 4, 3 of 4, 4 of 4*).
7. Once all 4 requests are accepted, the **Final Seating Plan** opens automatically showing all 6 members seated together in S2 (Seats 41–46), with the official plan ticket and "Show to TTE / Share Plan" option.

### Journey C: Handling Rejections
1. If any volunteer passenger declines a swap request, the requester sees a **Rejected** card with the **Find another match** button.
2. Tapping it re-runs the optimizer excluding that passenger and discovers alternate arrangements.

---

## 🏗 Architecture & Tech Stack

- **Framework**: Flutter (Dart 3 null-safety, Material 3)
- **Design Language**: Mint & Ink Stitch Design System (`Plus Jakarta Sans`)
- **State Management**: Flutter Riverpod (`flutter_riverpod`)
- **Routing**: `go_router` with `StatefulShellRoute` & floating bottom navigation
- **Backend & Realtime**: Supabase Postgres & Realtime (`supabase_flutter`)
- **Local Session**: `shared_preferences`
- **Pure Logic**: All seat calculations, group cohesion scoring, matching, and optimization logic reside in `lib/logic/` with 100% pure Dart test coverage.
