import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var step = 1
    @State private var pickedCity: CityID? = .seogwipo
    @State private var isRequestingNotifications = false

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 0) {
                switch step {
                case 1:
                    cityStep
                case 2:
                    notifyStep
                default:
                    widgetStep
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .preferredColorScheme(.dark)
    }

    private var cityStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepChrome(index: 1, title: AppIdentity.displayName, lead: "지금 주로 어디에 사나요?")
            Spacer(minLength: 12)
            CityPickerCards(
                selected: pickedCity,
                showsHeading: false,
                compactCopy: true
            ) { city in
                pickedCity = city
            }
            Spacer(minLength: 12)
            Button {
                guard let pickedCity else { return }
                model.selectCity(pickedCity)
                step = 2
            } label: {
                Text("다음")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            .foregroundStyle(pickedCity == nil ? Palette.ink.opacity(0.55) : Color.white)
            .background(
                Capsule().fill(pickedCity == nil ? Color.white.opacity(0.14) : Palette.hallabong)
            )
            .shadow(color: pickedCity == nil ? .clear : Palette.hallabongGlow, radius: 12)
            .disabled(pickedCity == nil)
            .accessibilityLabel("다음")
            .accessibilityHint(pickedCity == nil ? "도시를 고른 뒤에 쓸 수 있어요" : "알림 안내로 이동")
        }
    }

    private var notifyStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepChrome(index: 2, title: "열리기 전에\n알려줄까요?", lead: "매일 오후 2:30 · 요일제 품목만")
            Spacer(minLength: 16)
            HStack(spacing: 10) {
                Button {
                    Task {
                        isRequestingNotifications = true
                        await model.setNotificationsEnabled(true)
                        isRequestingNotifications = false
                        step = 3
                    }
                } label: {
                    Text("알림 받기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Palette.hallabong, in: Capsule())
                .shadow(color: Palette.hallabongGlow, radius: 12)
                .disabled(isRequestingNotifications)
                .accessibilityLabel("알림 받기")
                .accessibilityHint("창구 열리기 전에 알림을 받습니다")

                Button {
                    model.declineOnboardingNotifications()
                    step = 3
                } label: {
                    Text("나중에")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Palette.inkDim)
                .disabled(isRequestingNotifications)
                .accessibilityLabel("나중에")
                .accessibilityHint("알림 없이 계속합니다. 시스템 알림 창은 뜨지 않습니다")
            }
        }
    }

    private var widgetStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepChrome(index: 3, title: "홈에 붙이기", lead: "작은 · 넓은 · 큰 칸")
            VStack(spacing: 10) {
                widgetHowTo(number: 1, title: "빈 화면을 길게", detail: "앱이 흔들릴 때까지")
                widgetHowTo(number: 2, title: "왼쪽 위 +", detail: "위젯 갤러리")
                widgetHowTo(number: 3, title: AppIdentity.displayName, detail: "검색 후 칸 고르기")
                widgetHowTo(number: 4, title: "위젯을 길게", detail: "제주시 / 서귀포시")
            }
            .padding(.top, 2)
            Text("앱이 홈 화면에 위젯을 대신 붙일 수는 없어요. 홈 화면에서 직접 추가해 주세요.")
                .font(.caption)
                .foregroundStyle(Palette.sea)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
            Spacer(minLength: 16)
            Button {
                model.completeOnboarding()
            } label: {
                Text("시작하기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(Palette.hallabong, in: Capsule())
            .shadow(color: Palette.hallabongGlow, radius: 12)
            .accessibilityLabel("시작하기")
            .accessibilityHint("온보딩을 끝내고 오늘 화면으로 갑니다")
        }
    }

    private func stepChrome(index: Int, title: String, lead: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(index) / 3")
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.hallabongInk)
                .accessibilityLabel("\(index) 단계, 모두 3단계")
            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Palette.ink)
                .tracking(-0.4)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(lead)
                .font(.subheadline)
                .foregroundStyle(Palette.inkDim)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 18)
        }
    }

    private func widgetHowTo(number: Int, title: String, detail: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text("\(number)")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Palette.hallabong, in: Circle())
                .shadow(color: Palette.hallabongGlow, radius: 8)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Palette.inkDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(number). \(title). \(detail)")
    }
}

#Preview("온보딩") {
    OnboardingView()
        .environment(AppModel(preview: true))
        .preferredColorScheme(.dark)
}
