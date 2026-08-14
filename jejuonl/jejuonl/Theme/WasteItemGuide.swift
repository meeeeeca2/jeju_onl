import Foundation

/// Short Jeju clean-house sort notes. Window hours are the island-wide 15:00–04:00, not per site.
struct WasteItemGuide: Equatable, Sendable {
    let item: WasteItem
    let city: CityID

    var title: String { item.koreanName }

    var meta: String {
        if item.isWeekdayRestricted {
            return "요일제 · 15:00–04:00"
        }
        if item == .food {
            return "매일 · 24시간"
        }
        return "매일 · 15:00–04:00"
    }

    var body: String {
        switch item {
        case .plastic:
            var text = "플라스틱 용기·뚜껑. 이물질은 비우기."
            if city == .jejuSi {
                text += " 제주시 투명페트병은 이 칸이 아니라 전용함."
            }
            return text
        case .clearPET:
            return "투명 페트병만. 라벨은 비닐류. 내용물 비우고 전용수거함."
        case .paper:
            return "신문·상자·책자. 음식물 묻은 종이·영수증은 종량제."
        case .vinyl:
            return "비닐봉지·필름·페트 라벨. 이물질 많은 비닐은 종량제."
        case .incombustible:
            return "불연성(마대). 깨진 그릇·도자기 등. 가연 쓰레기는 종량제."
        case .general:
            return "종량제 봉투의 일반·가연 쓰레기. 클린하우스는 15:00–04:00."
        case .food:
            return "음식물만 24시간. 과일 씨·뼈·껍데기는 음식물 아님(종량제)."
        case .canMetal:
            return "캔·고철. 비우고 배출. 창 15:00–04:00."
        case .glass:
            return "병류. 깨진 유리는 불연성/주의. 창 15:00–04:00."
        case .styrofoam:
            return "스티로폼. 테이프·이물질 제거. 창 15:00–04:00."
        }
    }

    var extraLines: [String] {
        var lines: [String] = []
        if item == .clearPET, city == .seogwipo {
            lines.append("공식 요일표에 별도 품목이 아님. 전용함 또는 도움센터를 확인.")
        }
        if item == .plastic || (item == .clearPET && city == .jejuSi) {
            lines.append("도움센터는 요일 구분 없이 받을 수 있어요.")
        }
        return lines
    }
}
