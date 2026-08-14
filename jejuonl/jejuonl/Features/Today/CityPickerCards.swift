import SwiftUI

struct CityPickerCards: View {
    var onSelect: (CityID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(AppIdentity.displayName)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Palette.ink)
                .tracking(-0.4)
            Text("지금 주로 어디에 사나요?")
                .font(.system(size: 14))
                .foregroundStyle(Palette.inkDim)
            HStack(spacing: 10) {
                card(
                    city: .jejuSi,
                    tag: nil,
                    subtitle: "투명페트 전용함 요일제",
                    emphasized: false
                )
                card(
                    city: .seogwipo,
                    tag: "집",
                    subtitle: "공식 안내는 플라스틱으로 표기",
                    emphasized: true
                )
            }
            Text("다른 시에 가면 홈 화면 위젯을 길게 눌러 도시를 바꾸세요.")
                .font(.system(size: 11))
                .foregroundStyle(Palette.sea)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func card(city: CityID, tag: String?, subtitle: String, emphasized: Bool) -> some View {
        Button {
            onSelect(city)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                if let tag {
                    Text(tag)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Palette.hallabongInk)
                }
                Text(city.koreanName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkDim)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .appGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                if emphasized {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Palette.hallabong, lineWidth: 2)
                        .shadow(color: Palette.hallabongGlow, radius: 10)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(city.koreanName)
        .accessibilityHint(subtitle)
    }
}

#Preview {
    ZStack {
        AppBackground()
        CityPickerCards(onSelect: { _ in })
            .padding(18)
    }
    .preferredColorScheme(.dark)
}
