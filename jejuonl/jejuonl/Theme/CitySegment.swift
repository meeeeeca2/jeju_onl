import SwiftUI

struct CitySegment: View {
    let selection: CityID
    var onChange: (CityID) -> Void

    var body: some View {
        HStack(spacing: 2) {
            segment(.jejuSi)
            segment(.seogwipo)
        }
        .padding(3)
        .appGlass(in: Capsule())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("도시")
    }

    private func segment(_ city: CityID) -> some View {
        let selected = selection == city
        return Button {
            onChange(city)
        } label: {
            Text(city.koreanName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(selected ? Palette.basalt : Palette.inkDim)
                .padding(.horizontal, 13)
                .padding(.vertical, 6)
                .frame(maxHeight: .infinity)
                .background {
                    if selected {
                        Capsule().fill(Color.white.opacity(0.92))
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityLabel(city.koreanName)
    }
}

struct ScreenDateLine: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Palette.inkDim)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .padding(.horizontal, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(Palette.inkFaint)
            .padding(.horizontal, 2)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
