import Foundation

enum WasteItem: String, Codable, CaseIterable, Sendable {
    case plastic, clearPET, paper, vinyl, incombustible
    case general, food, canMetal, glass, styrofoam

    var isWeekdayRestricted: Bool {
        switch self {
        case .plastic, .clearPET, .paper, .vinyl, .incombustible: return true
        default: return false
        }
    }

    var koreanName: String {
        switch self {
        case .plastic: return "플라스틱"
        case .clearPET: return "투명페트"
        case .paper: return "종이"
        case .vinyl: return "비닐"
        case .incombustible: return "불연성"
        case .general: return "종량제"
        case .food: return "음식물"
        case .canMetal: return "캔·고철"
        case .glass: return "병류"
        case .styrofoam: return "스티로폼"
        }
    }

    /// Medium 위젯 매일 줄. 종량제·음식물·캔·병·스티로.
    var shortKoreanName: String {
        switch self {
        case .canMetal: return "캔"
        case .glass: return "병"
        case .styrofoam: return "스티로"
        default: return koreanName
        }
    }

    var symbolName: String {
        switch self {
        case .plastic: return "cube.box"
        case .clearPET: return "waterbottle"
        case .paper: return "newspaper"
        case .vinyl: return "bag"
        case .incombustible: return "shippingbox"
        case .general: return "trash"
        case .food: return "leaf"
        case .canMetal: return "cylinder"
        case .glass: return "wineglass"
        case .styrofoam: return "square.dashed"
        }
    }
}
