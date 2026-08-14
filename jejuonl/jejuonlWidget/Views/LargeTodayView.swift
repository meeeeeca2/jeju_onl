import SwiftUI

struct LargeTodayView: View {
    let snapshot: DischargeSnapshot

    var body: some View {
        let extra = Self.weekExtra(from: snapshot)
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WidgetStatusMark(window: snapshot.window, compact: true)
                Spacer(minLength: 6)
                Text("\(snapshot.city.koreanName) · \(snapshot.dischargeWeekday.shortKoreanName)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            hero
                .padding(.top, 10)

            if let extra {
                weekRow(extra.days)
                    .padding(.top, 14)
                Text(extra.tomorrowLine)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.top, 8)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(largeAccessibility(extra: extra))
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 12) {
            heroIcons
            VStack(alignment: .leading, spacing: 2) {
                Text(heroTime)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(heroMeta)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                alwaysOnIcons
                    .padding(.top, 6)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var heroIcons: some View {
        let items = snapshot.restrictedItems
        switch items.count {
        case 0:
            EmptyView()
        case 1:
            WidgetItemWithNameBadge(item: items[0], side: 110, corner: 30)
        default:
            HStack(spacing: -28) {
                ForEach(Array(items.prefix(3).enumerated()), id: \.element) { index, item in
                    WidgetItemWithNameBadge(item: item, side: 92, corner: 26)
                        .zIndex(Double(index))
                }
            }
        }
    }

    private var alwaysOnIcons: some View {
        HStack(spacing: 5) {
            ForEach(snapshot.alwaysOnItems, id: \.self) { item in
                WidgetItemImage(item: item, side: 36, corner: 11)
            }
        }
    }

    private var heroTime: String {
        switch snapshot.window {
        case .open:
            return WidgetClockText.hm(snapshot.windowClose)
        case .beforeOpen:
            return WidgetClockText.hm(snapshot.windowOpen)
        }
    }

    private var heroMeta: String {
        switch snapshot.window {
        case .open:
            return "까지 · \(WidgetClockText.windowRange(open: snapshot.windowOpen, close: snapshot.windowClose))"
        case .beforeOpen:
            return "시작 · \(WidgetClockText.windowRange(open: snapshot.windowOpen, close: snapshot.windowClose))"
        }
    }

    private func weekRow(_ days: [DischargeSnapshot]) -> some View {
        HStack(spacing: 4) {
            ForEach(days, id: \.dischargeDayStart) { day in
                let isToday = day.dischargeDayStart == snapshot.dischargeDayStart
                VStack(spacing: 4) {
                    Text(day.dischargeWeekday.shortKoreanName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isToday ? WidgetPalette.hallabongInk : Color.secondary)
                    if let first = day.restrictedItems.first {
                        WidgetItemImage(item: first, side: 42, corner: 12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background {
                    if isToday {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(WidgetPalette.hallabong.opacity(0.16))
                    }
                }
            }
        }
        .padding(.top, 10)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.primary.opacity(0.12))
                .frame(height: 1)
        }
    }

    private func largeAccessibility(extra: WeekExtra?) -> String {
        var parts = [WidgetCopy.statusAccessibility(snapshot), snapshot.city.koreanName, heroTime, heroMeta]
        if let extra {
            parts.append(extra.tomorrowLine)
        }
        return parts.joined(separator: ", ")
    }

    private static func weekExtra(from snapshot: DischargeSnapshot) -> WeekExtra? {
        guard let catalog = try? ScheduleCatalog.load(),
              let engine = try? ScheduleEngine(catalog: catalog) else {
            return nil
        }
        let days = engine.week(city: snapshot.city, containing: snapshot.now)
        let next = engine.snapshot(city: snapshot.city, now: snapshot.nextRestrictedChange)
        let names = next.restrictedItems.map(\.koreanName).joined(separator: " · ")
        let tomorrowLine = names.isEmpty ? "내일" : "내일 \(names)"
        return WeekExtra(days: days, tomorrowLine: tomorrowLine)
    }

    private struct WeekExtra {
        var days: [DischargeSnapshot]
        var tomorrowLine: String
    }
}
