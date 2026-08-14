import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var showsCityPicker = false
    @State private var showsNotifications = false

    var body: some View {
        NavigationStack {
            settingsHome
                .navigationDestination(isPresented: $showsNotifications) {
                    NotificationSettingsView()
                }
                .toolbar(showsNotifications ? .automatic : .hidden, for: .navigationBar)
        }
    }

    private var settingsHome: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenDateLine(text: "설정")

                VStack(spacing: 0) {
                    Button {
                        showsCityPicker = true
                    } label: {
                        settingsRow(
                            title: "도시",
                            value: model.settings.city?.koreanName ?? "고르기"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("도시를 바꿉니다")

                    Divider()
                        .background(Color.white.opacity(0.08))

                    Button {
                        showsNotifications = true
                    } label: {
                        settingsRow(
                            title: "알림",
                            value: SeoulClockText.clock(model.settings.notifications.preOpenTime)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("알림 \(SeoulClockText.clock(model.settings.notifications.preOpenTime))")
                    .accessibilityHint("알림 설정을 엽니다")
                }
                .appGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                Text("위젯을 길게 눌러 제주시 / 서귀포시를 고르세요. 이미 붙인 위젯은 그대로입니다.")
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkDim)
                    .lineSpacing(3)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.top, 12)

                versionBlock
                    .padding(.top, 12)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
        .sheet(isPresented: $showsCityPicker) {
            cityPickerSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
        }
    }

    private func settingsRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Palette.ink)
            Spacer()
            Text("\(value)  ›")
                .font(.system(size: 12))
                .foregroundStyle(Palette.inkDim)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fillsHitTarget()
        .accessibilityElement(children: .combine)
    }

    private var versionBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let catalog = model.catalog {
                Text("\(catalog.catalogVersion) · \(SeoulClockText.dayStamp(catalog.verifiedAt))")
            }
            Text("창 15:00–04:00 · 개소마다 다를 수 있음")
        }
        .font(.system(size: 11))
        .foregroundStyle(Palette.inkFaint)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var cityPickerSheet: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 16) {
                Text("도시")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .padding(.top, 8)
                CityPickerCards { city in
                    model.selectCity(city)
                    showsCityPicker = false
                }
                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview("설정") {
    SettingsView()
        .environment(AppModel(preview: true))
        .preferredColorScheme(.dark)
}
