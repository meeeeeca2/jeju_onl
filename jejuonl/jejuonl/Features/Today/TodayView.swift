import SwiftUI

struct TodayView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        TimelineView(.periodic(from: .now, by: 15)) { context in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let city = model.settings.city {
                        CitySegment(selection: city, onChange: model.selectCity)
                    }
                    if model.settings.city == nil {
                        CityPickerCards(onSelect: model.selectCity)
                            .padding(.top, 12)
                    } else if let error = model.loadError {
                        loadErrorView(error)
                    } else if let engine = model.engine, let city = model.settings.city {
                        todayBody(engine: engine, city: city, now: context.date)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
            .background(AppBackground())
        }
    }

    @ViewBuilder
    private func todayBody(engine: ScheduleEngine, city: CityID, now: Date) -> some View {
        let snapshot = engine.snapshot(city: city, now: now)
        let stale = model.catalog.map { CatalogFreshness.isStale(verifiedAt: $0.verifiedAt, now: now) } ?? false

        ScreenDateLine(text: DischargeDayText.header(weekday: snapshot.dischargeWeekday, dischargeDayStart: snapshot.dischargeDayStart))

        if stale {
            staleBanner
        }

        statusCard(snapshot: snapshot, now: now)
            .padding(.bottom, 16)

        SectionLabel(text: "오늘만")
        restrictedRow(snapshot.restrictedItems)
            .padding(.bottom, 18)

        SectionLabel(text: "매일")
        dailyRow(snapshot.alwaysOnItems)
            .padding(.bottom, 10)

        notes(for: city)
    }

    private func statusCard(snapshot: DischargeSnapshot, now: Date) -> some View {
        let justClosed = isJustClosed(snapshot: snapshot, now: now)
        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                switch snapshot.window {
                case .open:
                    liveBadge
                    Text("\(SeoulClockText.windowRange(open: snapshot.windowOpen, close: snapshot.windowClose)) · 내일 04시 마감")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkDim)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                case .beforeOpen:
                    waitBadge
                    CountdownText(until: snapshot.nextWindowToggle, now: now)
                    if justClosed {
                        Text("방금 창구가 닫혔어요")
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.inkDim)
                    }
                    Text("15:00 열림 · 지금은 음식물만")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkDim)
                }
            }
            Spacer(minLength: 8)
            if snapshot.window == .beforeOpen {
                ItemTile(item: .food, kind: .daily, showsCaption: false)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlass(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var liveBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Palette.hallabong)
                .frame(width: 8, height: 8)
                .shadow(color: Palette.hallabongGlow, radius: 5)
            Text("지금")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.hallabongInk)
        }
        .accessibilityLabel("지금 배출 가능")
    }

    private var waitBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Palette.inkFaint)
                .frame(width: 8, height: 8)
            Text("저녁부터")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.inkDim)
        }
        .accessibilityLabel("오늘 저녁부터")
    }

    private func restrictedRow(_ items: [WasteItem]) -> some View {
        let kind: ItemTile.SizeKind = items.count == 1 ? .large : .regular
        return HStack(alignment: .top, spacing: 14) {
            ForEach(items, id: \.self) { item in
                ItemTile(item: item, kind: kind)
            }
            if items.isEmpty {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dailyRow(_ items: [WasteItem]) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(items, id: \.self) { item in
                ItemTile(item: item, kind: .daily, useShortName: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func notes(for city: CityID) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("도움센터는 요일 구분 없이 받을 수 있어요.")
            switch city {
            case .jejuSi:
                Text("투명페트병은 전용수거함에")
            case .seogwipo:
                Text("투명페트는 전용함 또는 도움센터를 확인하세요.")
            }
        }
        .font(.system(size: 11))
        .foregroundStyle(Palette.sea)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var staleBanner: some View {
        Text("일정이 오래됐습니다")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Palette.hallabongInk)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.bottom, 12)
            .accessibilityLabel("일정이 오래됐습니다")
    }

    private func loadErrorView(_ error: ScheduleEngineError) -> some View {
        Text(errorCopy(error))
            .font(.system(size: 14))
            .foregroundStyle(Palette.ink)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorCopy(_ error: ScheduleEngineError) -> String {
        switch error {
        case .catalogSchemaTooNew:
            return "앱을 업데이트하세요"
        case .catalogMissing, .catalogItemUnknown, .missingTimeZone:
            return "앱을 다시 설치해 주세요"
        }
    }

    private func isJustClosed(snapshot: DischargeSnapshot, now: Date) -> Bool {
        guard snapshot.window == .beforeOpen else { return false }
        guard let calendar = try? SeoulCalendar.make() else { return false }
        var components = calendar.dateComponents([.year, .month, .day], from: snapshot.dischargeDayStart)
        components.hour = 4
        components.minute = 0
        components.second = 0
        guard let fourAM = calendar.date(from: components) else { return false }
        let minutes = now.timeIntervalSince(fourAM) / 60
        return minutes >= 0 && minutes < 30
    }
}

#Preview("오늘") {
    TodayView()
        .environment(AppModel(preview: true))
        .preferredColorScheme(.dark)
}
