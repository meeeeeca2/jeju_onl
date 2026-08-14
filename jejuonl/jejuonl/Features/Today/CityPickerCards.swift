import SwiftUI

struct CityPickerCards: View {
    var selected: CityID?
    var showsHeading: Bool
    var compactCopy: Bool
    var onSelect: (CityID) -> Void

    init(
        selected: CityID? = nil,
        showsHeading: Bool = true,
        compactCopy: Bool = false,
        onSelect: @escaping (CityID) -> Void
    ) {
        self.selected = selected
        self.showsHeading = showsHeading
        self.compactCopy = compactCopy
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if showsHeading {
                Text(AppIdentity.displayName)
                    .font(.title.weight(.bold))
                    .foregroundStyle(Palette.ink)
                    .tracking(-0.4)
                    .fixedSize(horizontal: false, vertical: true)
                Text("지금 주로 어디에 사나요?")
                    .font(.subheadline)
                    .foregroundStyle(Palette.inkDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 10) {
                card(
                    city: .jejuSi,
                    tag: nil,
                    subtitle: compactCopy ? "투명페트 전용함" : "투명페트 전용함 요일제",
                    recommended: false
                )
                card(
                    city: .seogwipo,
                    tag: "집",
                    subtitle: compactCopy ? "플라스틱으로 표기" : "공식 안내는 플라스틱으로 표기",
                    recommended: true
                )
            }
            Text(compactCopy ? "다른 시 → 위젯을 길게 눌러 바꾸기" : "다른 시에 가면 홈 화면 위젯을 길게 눌러 도시를 바꾸세요.")
                .font(.caption)
                .foregroundStyle(Palette.sea)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func card(city: CityID, tag: String?, subtitle: String, recommended: Bool) -> some View {
        let isSelected = selected == city
        let showStroke = isSelected || (recommended && selected == nil)
        return Button {
            onSelect(city)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                if let tag {
                    Text(tag)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Palette.hallabongInk)
                }
                Text(city.koreanName)
                    .font(.headline)
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Palette.inkDim)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .appGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                if showStroke {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Palette.hallabong, lineWidth: 2)
                        .shadow(color: Palette.hallabongGlow, radius: 10)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(cardLabel(city: city, tag: tag, subtitle: subtitle))
        .accessibilityHint(isSelected ? "선택됨" : "탭해서 집 도시로 고르기")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func cardLabel(city: CityID, tag: String?, subtitle: String) -> String {
        if let tag {
            return "\(city.koreanName), \(tag), \(subtitle)"
        }
        return "\(city.koreanName), \(subtitle)"
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
