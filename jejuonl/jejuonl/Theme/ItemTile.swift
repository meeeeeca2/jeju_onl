import SwiftUI

struct ItemTile: View {
    enum SizeKind {
        case large
        case regular
        case daily
        case week

        var side: CGFloat {
            switch self {
            case .large: return 148
            case .regular: return 96
            case .daily: return 48
            case .week: return 40
            }
        }

        var corner: CGFloat {
            switch self {
            case .large: return 32
            case .regular: return 22
            case .daily: return 14
            case .week: return 12
            }
        }

        var captionSize: CGFloat {
            switch self {
            case .large: return 12
            case .regular: return 11
            case .daily: return 9
            case .week: return 10
            }
        }
    }

    let item: WasteItem
    var kind: SizeKind = .regular
    var showsCaption: Bool = true
    var useShortName: Bool = false
    var onSelect: (() -> Void)? = nil

    private var caption: String {
        useShortName ? item.shortKoreanName : item.koreanName
    }

    var body: some View {
        if let onSelect {
            Button(action: onSelect) {
                tileStack
            }
            .buttonStyle(.plain)
            .fillsHitTarget()
            .accessibilityLabel(item.koreanName)
            .accessibilityHint("자세히 보기")
        } else {
            tileStack
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(item.koreanName)
        }
    }

    private var tileStack: some View {
        VStack(spacing: kind == .daily ? 4 : 7) {
            Image(item.assetName)
                .resizable()
                .scaledToFill()
                .frame(width: kind.side, height: kind.side)
                .clipShape(RoundedRectangle(cornerRadius: kind.corner, style: .continuous))
                .shadow(color: .black.opacity(kind == .daily || kind == .week ? 0.18 : 0.22), radius: kind == .large ? 10 : 6, y: 4)
            if showsCaption {
                Text(caption)
                    .font(.system(size: kind.captionSize, weight: .medium))
                    .foregroundStyle(kind == .daily ? Palette.inkDim : Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(width: kind.side)
    }
}
