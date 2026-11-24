# QueueSense — Smart Cafeteria Wait-Time & Live Order Tracker

Native iOS app in Swift/SwiftUI. Browse the cafeteria menu, place an order,
and track it live — on the Dynamic Island / Lock Screen (ActivityKit) and
in a home-screen widget (WidgetKit). Orders are saved on-device with
Core Data. Wait times are predicted on-device by a Core ML model
(trained with Create ML), with a heuristic fallback when no model file
is present yet.

This matches the QueueSense project on the resume:
Swift · SwiftUI · Core ML · Create ML · ActivityKit · WidgetKit · Core Data.

## Honest status

Written and structured here; **not compiled yet** — this machine has no
Swift toolchain or Xcode, so the first build happens on your Mac.
Open the project in Xcode, pick your team under Signing & Capabilities,
and build for a simulator first. If Xcode reports an error, it is most
likely a small API or signing detail — fix that one error, the structure
is standard.

## Open and run (on your Mac)

```
open QueueSense.xcodeproj
```

1. Select the **QueueSense** target → Signing & Capabilities → pick your
   team. Do the same for **QueueSenseWidget**.
2. Make sure the **App Groups** capability is on for both targets, with
   group `group.com.himanshujoshi.queuesense` (already in both
   `.entitlements` files — Xcode enables it once a team is selected).
3. Run on a simulator (iPhone 15 or later, iOS 17+). Live Activities
   show best on a real device with Dynamic Island.

## What is inside

| Area | Files |
| --- | --- |
| App entry, tabs, cart/checkout | `QueueSense/QueueSenseApp.swift`, `QueueSense/Views/ContentView.swift` |
| Menu, live tracking, history | `QueueSense/Views/MenuListView.swift`, `OrderTrackingView.swift`, `OrdersHistoryView.swift` |
| Models | `QueueSense/Models/` — menu items, orders, Live Activity attributes |
| Wait-time prediction | `QueueSense/Services/WaitTimePredictor.swift` (Core ML + fallback) |
| Live Activity | `QueueSense/Services/LiveActivityManager.swift` |
| Cart / orders / simulation | `QueueSense/Services/OrderStore.swift` |
| Persistence | `QueueSense/Persistence.swift` — Core Data, model built in code |
| App Group sharing | `QueueSense/Shared/SharedQueueStatus.swift` (also in the widget target) |
| Widget | `QueueSenseWidget/QueueSenseWidget.swift` |
| Model training | `WaitTimeTrainer/` — sample CSV + Create ML script |

## Wait-time model

`WaitTimeTrainer/training_data.csv` is a small synthetic sample
(24 rows, clearly labelled sample data — replace it with real
cafeteria order logs when you have them). Train the model on a Mac:

```
cd WaitTimeTrainer
swift TrainWaitTime.swift
```

That writes `WaitTimePredictor.mlmodel`. Drag it into the QueueSense
target in Xcode. The app loads it at runtime if present
(`WaitTimePredictor.predictWithCoreML`); without it, the built-in
heuristic gives the same shape of answer, so the app works either way.

## Demo notes — read before showing it to anyone

- The menu and prices are sample campus-cafeteria data, in ₹.
- Order status moves Placed → Preparing → Ready → Completed on a
  20-second timer so the whole flow can be watched in about a minute.
  A real deployment would update status from the cafeteria backend
  instead; the Live Activity, widget and persistence paths are the
  same either way.
- Payment is "pay at the counter" — there is no payment integration.

## Push to the resume repo

The repo `https://github.com/Himanshujoshi3/queuesense.git` exists but
is empty. After the app builds clean in Xcode:

```
cd queuesense
git init
git add .
git commit -m "QueueSense: native iOS cafeteria wait-time tracker (SwiftUI, Core ML, ActivityKit, WidgetKit, Core Data)"
git branch -M main
git remote add origin https://github.com/Himanshujoshi3/queuesense.git
git push -u origin main
```

Check `git status` first and confirm no secrets are listed (there are
none in this project — no API keys, no backend credentials).
