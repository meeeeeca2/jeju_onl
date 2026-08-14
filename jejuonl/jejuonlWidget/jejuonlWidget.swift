import SwiftUI
import WidgetKit

struct TodayProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayLoader.placeholder()
    }

    func snapshot(for configuration: TodayWidgetConfigIntent, in context: Context) async -> TodayEntry {
        let now = Date()
        let city = configuration.city.cityID
        return TodayEntry(date: now, load: TodayLoader.load(city: city, at: now), configuredCity: city)
    }

    func timeline(for configuration: TodayWidgetConfigIntent, in context: Context) async -> Timeline<TodayEntry> {
        let now = Date()
        let city = configuration.city.cityID
        guard let calendar = try? SeoulCalendar.make() else {
            let entry = TodayEntry(date: now, load: .parseFailed, configuredCity: city)
            return Timeline(entries: [entry], policy: .atEnd)
        }

        let dates = WidgetTimelineDates.timelineDates(from: now, count: 4, calendar: calendar)
        let entries = dates.map { date in
            TodayEntry(
                date: date,
                load: TodayLoader.load(city: city, at: date),
                configuredCity: city
            )
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: TodayEntry

    var body: some View {
        switch entry.load {
        case .cityMissing:
            WidgetMessageView(text: "도시를 선택해 주세요")
        case .parseFailed:
            WidgetMessageView(text: "앱을 다시 설치해 주세요")
        case .schemaTooNew:
            WidgetMessageView(text: "앱을 업데이트하세요")
        case .ready(let snapshot, _):
            switch family {
            case .systemSmall:
                SmallTodayView(snapshot: snapshot)
            case .systemMedium:
                MediumTodayView(snapshot: snapshot)
            case .systemLarge:
                LargeTodayView(snapshot: snapshot)
            default:
                SmallTodayView(snapshot: snapshot)
            }
        }
    }
}

struct jejuonlWidget: Widget {
    let kind: String = "kr.jejuonl.widget.today"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: TodayWidgetConfigIntent.self,
            provider: TodayProvider()
        ) { entry in
            TodayWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘 뭐 버려?")
        .description("오늘 클린하우스에 넣을 수 있는 쓰레기를 보여 줍니다")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(true)
    }
}

#Preview(as: .systemSmall) {
    jejuonlWidget()
} timeline: {
    TodayLoader.placeholder()
}

#Preview(as: .systemMedium) {
    jejuonlWidget()
} timeline: {
    TodayLoader.placeholder()
}

#Preview(as: .systemLarge) {
    jejuonlWidget()
} timeline: {
    TodayLoader.placeholder()
}
