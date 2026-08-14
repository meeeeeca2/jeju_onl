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
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Spacer(minLength: 0)
                        ItemTile(item: item, kind: .large, showsCaption: false)
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 8)

                    Text(guide.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Palette.ink)

                    Text(guide.meta)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.inkDim)

                    Text(guide.body)
                        .font(.system(size: 14))
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
        }
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
