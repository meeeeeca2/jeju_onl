import SwiftUI

struct WeekView: View {
    @Environment(AppModel.self) private var model
    @State private var selectedDay: DaySheet?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let city = model.settings.city {
                        CitySegment(selection: city, onChange: model.selectCity)
                    }
                    if model.settings.city == nil {
                        CityPickerCards(onSelect: model.selectCity)
                            .padding(.top, 12)
                    } else if let error = model.loadError {
                        Text(errorCopy(error))
                            .font(.system(size: 14))
                            .foregroundStyle(Palette.ink)
                            .padding(.top, 24)
                    } else if let engine = model.engine, let city = model.settings.city {
                        weekBody(engine: engine, city: city, now: context.date)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
            .background(AppBackground())
            .sheet(item: $selectedDay) { day in
                WeekDaySheet(snapshot: day.snapshot)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
        }
    }

    @ViewBuilder
    private func weekBody(engine: ScheduleEngine, city: CityID, now: Date) -> some View {
        let today = engine.snapshot(city: city, now: now)
        let days = engine.week(city: city, containing: now)

        ScreenDateLine(text: "이번 주 · 새벽 4시에 날짜가 바뀜")

        VStack(spacing: 8) {
            ForEach(days, id: \.dischargeDayStart) { day in
                let isToday = day.dischargeDayStart == today.dischargeDayStart
                Button {
                    selectedDay = DaySheet(snapshot: day)
                } label: {
                    weekRow(day, highlighted: isToday)
                        .fillsHitTarget()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .appGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func weekRow(_ day: DischargeSnapshot, highlighted: Bool) -> some View {
        HStack(spacing: 8) {
            Text(day.dischargeWeekday.shortKoreanName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(highlighted ? Palette.hallabongInk : Palette.inkDim)
                .frame(width: 22, alignment: .center)
            HStack(spacing: 6) {
                ForEach(day.restrictedItems, id: \.self) { item in
                    ItemTile(item: item, kind: .week, showsCaption: false)
                }
            }
            Spacer(minLength: 0)
            if highlighted {
                Circle()
                    .fill(Palette.hallabong)
                    .frame(width: 7, height: 7)
                    .shadow(color: Palette.hallabongGlow, radius: 4)
                    .frame(width: 16)
            } else {
                Color.clear.frame(width: 16, height: 7)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            if highlighted {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Palette.hallabong.opacity(0.22),
                                Palette.hallabong.opacity(0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Palette.hallabong.opacity(0.35), lineWidth: 1)
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(weekAccessibility(day, highlighted: highlighted))
        .accessibilityHint("자세히 보기")
        .accessibilityAddTraits(highlighted ? .isSelected : [])
    }

    private func weekAccessibility(_ day: DischargeSnapshot, highlighted: Bool) -> String {
        let items = day.restrictedItems.map(\.koreanName).joined(separator: ", ")
        let today = highlighted ? ", 오늘 배출일" : ""
        return "\(day.dischargeWeekday.koreanName) \(items)\(today)"
    }

    private func errorCopy(_ error: ScheduleEngineError) -> String {
        switch error {
        case .catalogSchemaTooNew:
            return "앱을 업데이트하세요"
        case .catalogMissing, .catalogItemUnknown, .missingTimeZone:
            return "앱을 다시 설치해 주세요"
        }
    }
}

private struct DaySheet: Identifiable {
    var id: Date { snapshot.dischargeDayStart }
    var snapshot: DischargeSnapshot
}

private struct WeekDaySheet: View {
    let snapshot: DischargeSnapshot

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 16) {
                Text(snapshot.dischargeWeekday.koreanName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                HStack(spacing: 14) {
                    ForEach(snapshot.restrictedItems, id: \.self) { item in
                        ItemTile(item: item, kind: .regular)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(SeoulClockText.windowRange(open: snapshot.windowOpen, close: snapshot.windowClose))
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkDim)
                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview("이번 주") {
    WeekView()
        .environment(AppModel(preview: true))
        .preferredColorScheme(.dark)
}
