import SwiftUI
import WidgetKit

/// Home-screen widget: at-a-glance queue status for the active order.
/// Reads the snapshot the app writes to the shared App Group defaults.
struct QueueStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> QueueStatusEntry {
        QueueStatusEntry(
            date: Date(),
            itemsSummary: "2x Masala Dosa",
            waitMinutes: 12,
            status: "Preparing"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QueueStatusEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QueueStatusEntry>) -> Void) {
        let entry = entry(for: Date())
        // Refresh every 5 minutes while an order is live.
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func entry(for date: Date) -> QueueStatusEntry {
        if let snapshot = SharedQueueStatus.read() {
            return QueueStatusEntry(
                date: date,
                itemsSummary: snapshot.itemsSummary,
                waitMinutes: snapshot.waitMinutes,
                status: snapshot.status
            )
        }
        return QueueStatusEntry(
            date: date,
            itemsSummary: nil,
            waitMinutes: 0,
            status: ""
        )
    }
}

struct QueueStatusEntry: TimelineEntry {
    let date: Date
    let itemsSummary: String?
    let waitMinutes: Int
    let status: String
}

struct QueueStatusWidgetView: View {
    var entry: QueueStatusEntry

    var body: some View {
        if let summary = entry.itemsSummary {
            VStack(alignment: .leading, spacing: 6) {
                Text("QueueSense")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text(entry.status)
                    .font(.headline)
                Text(summary)
                    .font(.caption)
                    .lineLimit(2)
                Label("~\(entry.waitMinutes) min wait", systemImage: "hourglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("QueueSense")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("No live order")
                    .font(.headline)
                Text("Order from the cafeteria menu to see your wait time here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct QueueStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "QueueStatusWidget", provider: QueueStatusProvider()) { entry in
            QueueStatusWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Queue Status")
        .description("See your live cafeteria order and predicted wait time.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct QueueSenseWidgetBundle: WidgetBundle {
    var body: some Widget {
        QueueStatusWidget()
    }
}
