import SwiftUI
import UIKit

struct NotificationSettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var showsPreOpenPicker = false
    @State private var showsEveningPicker = false

    private var prefs: NotificationPrefs { model.settings.notifications }

    private var titleText: String {
        if let city = model.settings.city {
            return "알림 · \(city.koreanName)"
        }
        return "알림"
    }

    private var watchedItems: [WasteItem] {
        [.plastic, .clearPET, .paper, .vinyl, .incombustible]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenDateLine(text: titleText)

                if model.notificationDeniedBanner {
                    deniedBanner
                        .padding(.bottom, 12)
                }

                if prefs.isEnabled, model.pendingNotificationCount == 0 {
                    rescheduleRow
                        .padding(.bottom, 12)
                }

                controlsCard

                SectionLabel(text: "품목")
                    .padding(.top, 16)

                itemsCard
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await model.refreshNotificationStatus()
        }
    }

    private var controlsCard: some View {
        VStack(spacing: 0) {
            Button {
                Task { await model.setNotificationsEnabled(!prefs.isEnabled) }
            } label: {
                HStack {
                    Text("알림")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Toggle("알림", isOn: masterBinding)
                        .labelsHidden()
                        .tint(Palette.hallabong)
                        .allowsHitTesting(false)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .fillsHitTarget()
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)

            rowDivider

            timeRow(
                title: "열리기 전",
                time: prefs.preOpenTime.clampedPreOpen(),
                expanded: $showsPreOpenPicker
            ) { date in
                model.updatePreOpenTime(clock(from: date).clampedPreOpen())
            }

            rowDivider

            Button {
                model.setEveningEnabled(!prefs.eveningEnabled)
            } label: {
                HStack {
                    Text("저녁에도")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Toggle("저녁에도", isOn: eveningBinding)
                        .labelsHidden()
                        .tint(Palette.hallabong)
                        .allowsHitTesting(false)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .fillsHitTarget()
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)

            if prefs.eveningEnabled {
                rowDivider
                timeRow(
                    title: "시간",
                    time: prefs.eveningTime.clampedEvening(),
                    expanded: $showsEveningPicker
                ) { date in
                    model.updateEveningTime(clock(from: date).clampedEvening())
                }
            }
        }
        .appGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var itemsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(watchedItems.enumerated()), id: \.element) { index, item in
                if index > 0 { rowDivider }
                itemRow(item)
            }
            rowDivider
            alwaysOnRow
        }
        .appGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func itemRow(_ item: WasteItem) -> some View {
        let seogwipoPET = item == .clearPET && model.settings.city == .seogwipo
        let selected = !seogwipoPET && prefs.watchedRestricted.contains(item)
        return Button {
            guard !seogwipoPET else { return }
            model.toggleWatched(item)
        } label: {
            HStack(spacing: 10) {
                Image(item.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .opacity(seogwipoPET ? 0.4 : 1)

                VStack(alignment: .leading, spacing: 1) {
                    Text(item.koreanName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(seogwipoPET ? Palette.inkDim : Palette.ink)
                    if seogwipoPET {
                        Text("제주시만")
                            .font(.system(size: 11))
                            .foregroundStyle(Palette.inkFaint)
                    }
                }
                Spacer()
                checkmark(selected && !seogwipoPET)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(seogwipoPET)
        .accessibilityLabel(seogwipoPET ? "\(item.koreanName), 제주시만" : item.koreanName)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityHint(seogwipoPET ? "" : (selected ? "알림에서 빼기" : "알림에 넣기"))
    }

    private var alwaysOnRow: some View {
        Button {
            model.setIncludeAlwaysOn(!prefs.includeAlwaysOn)
        } label: {
            HStack {
                Text("매일 품목도")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Palette.ink)
                Spacer()
                checkmark(prefs.includeAlwaysOn)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("매일 품목도")
        .accessibilityAddTraits(prefs.includeAlwaysOn ? .isSelected : [])
    }

    private var deniedBanner: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("설정 앱에서 알림을 켜 주세요")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button("설정") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Palette.basalt)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Palette.hallabong, in: Capsule())
            .contentShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var rescheduleRow: some View {
        Button {
            Task { await model.rescheduleNotificationsNow() }
        } label: {
            Text("다시 예약")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Palette.hallabongInk)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .fillsHitTarget()
        }
        .buttonStyle(.plain)
        .appGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityLabel("다시 예약")
    }

    private func timeRow(
        title: String,
        time: ClockTime,
        expanded: Binding<Bool>,
        onChange: @escaping (Date) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                expanded.wrappedValue.toggle()
            } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Text(SeoulClockText.clock(time))
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkDim)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title) \(SeoulClockText.clock(time))")

            if expanded.wrappedValue {
                DatePicker(
                    title,
                    selection: Binding(
                        get: { pickerDate(from: time) },
                        set: onChange
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .environment(\.timeZone, TimeZone(identifier: "Asia/Seoul") ?? .current)
                .colorScheme(.dark)
                .padding(.horizontal, 6)
                .padding(.bottom, 6)
            }
        }
    }

    private var masterBinding: Binding<Bool> {
        Binding(
            get: { prefs.isEnabled },
            set: { newValue in
                Task { await model.setNotificationsEnabled(newValue) }
            }
        )
    }

    private var eveningBinding: Binding<Bool> {
        Binding(
            get: { prefs.eveningEnabled },
            set: { model.setEveningEnabled($0) }
        )
    }

    private func checkmark(_ on: Bool) -> some View {
        Image(systemName: on ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(on ? Palette.hallabong : Palette.inkFaint)
            .shadow(color: on ? Palette.hallabongGlow : .clear, radius: 6)
            .accessibilityHidden(true)
    }

    private var rowDivider: some View {
        Divider().background(Color.white.opacity(0.08))
    }

    private func pickerDate(from time: ClockTime) -> Date {
        guard let calendar = try? SeoulCalendar.make() else { return Date() }
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = time.hour
        components.minute = time.minute
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components) ?? Date()
    }

    private func clock(from date: Date) -> ClockTime {
        guard let calendar = try? SeoulCalendar.make() else {
            return ClockTime(hour: 14, minute: 30)
        }
        return ClockTime(
            hour: calendar.component(.hour, from: date),
            minute: calendar.component(.minute, from: date)
        )
    }
}

#Preview("알림 · 서귀포시") {
    NavigationStack {
        NotificationSettingsView()
    }
    .environment(AppModel(preview: true))
    .preferredColorScheme(.dark)
}
