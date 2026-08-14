import SwiftUI

struct ItemDetailSelection: Identifiable, Hashable {
    let item: WasteItem
    var id: WasteItem { item }
}

struct ItemDetailSheet: View {
    let item: WasteItem
    let city: CityID

    private var guide: WasteItemGuide {
        WasteItemGuide(item: item, city: city)
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: 240)
                        .frame(maxWidth: .infinity)
                        .overlay {
                            Image(item.assetName)
                                .resizable()
                                .scaledToFill()
                        }
                        .clipped()
                        .clipShape(
                            UnevenRoundedRectangle(
                                bottomLeadingRadius: 18,
                                bottomTrailingRadius: 18,
                                style: .continuous
                            )
                        )

                    VStack(alignment: .leading, spacing: 12) {
                        Text(guide.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Palette.ink)

                        Text(guide.meta)
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.inkDim)

                        Text(guide.body)
                            .font(.system(size: 15))
                            .foregroundStyle(Palette.ink)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)

                        if !guide.extraLines.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(guide.extraLines, id: \.self) { line in
                                    Text(line)
                                }
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.sea)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .contentMargins(.top, 0, for: .scrollContent)
        }
        .ignoresSafeArea(edges: .top)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
}

#Preview("플라스틱 · 제주시") {
    ItemDetailSheet(item: .plastic, city: .jejuSi)
}

#Preview("투명페트 · 서귀포시") {
    ItemDetailSheet(item: .clearPET, city: .seogwipo)
}
