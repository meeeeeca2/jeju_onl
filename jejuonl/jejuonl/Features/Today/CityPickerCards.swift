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
            Color.clear
                .aspectRatio(2.08, contentMode: .fit)
                .overlay {
                    GeometryReader { geo in
                        let side = max(0, (geo.size.width - 10) / 2)
                        HStack(spacing: 10) {
                            card(
                                city: .jejuSi,
                                subtitle: compactCopy ? "투명페트 전용함" : "투명페트 전용함 요일제",
                                side: side
                            )
                            card(
                                city: .seogwipo,
                                subtitle: compactCopy ? "플라스틱으로 표기" : "공식 안내는 플라스틱으로 표기",
                                side: side
                            )
                        }
                    }
                }
            if showsHeading {
                Text("다른 시에 가면 홈 화면 위젯을 길게 눌러 도시를 바꾸세요.")
                    .font(.caption)
                    .foregroundStyle(Palette.sea)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func card(city: CityID, subtitle: String, side: CGFloat) -> some View {
        let isSelected = selected == city
        return Button {
            onSelect(city)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(city.koreanName)
                    .font(.headline)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Palette.inkDim)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(width: side, height: side, alignment: .topLeading)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .appGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Palette.hallabong, lineWidth: 2)
                        .shadow(color: Palette.hallabongGlow, radius: 10)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: side, height: side)
        .accessibilityLabel("\(city.koreanName), \(subtitle)")
        .accessibilityHint(isSelected ? "선택됨" : "탭해서 고르기")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
