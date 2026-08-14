import Foundation

enum CityID: String, Codable, CaseIterable, Sendable {
    case jejuSi
    case seogwipo

    var koreanName: String {
        switch self {
        case .jejuSi: return "제주시"
        case .seogwipo: return "서귀포시"
        }
    }
}
