import Foundation

enum LocaleWeekday: String, Codable, CaseIterable, Sendable {
    case mon, tue, wed, thu, fri, sat, sun

    var koreanName: String {
        switch self {
        case .mon: return "월요일"
        case .tue: return "화요일"
        case .wed: return "수요일"
        case .thu: return "목요일"
        case .fri: return "금요일"
        case .sat: return "토요일"
        case .sun: return "일요일"
        }
    }

    var shortKoreanName: String {
        switch self {
        case .mon: return "월"
        case .tue: return "화"
        case .wed: return "수"
        case .thu: return "목"
        case .fri: return "금"
        case .sat: return "토"
        case .sun: return "일"
        }
    }
}
