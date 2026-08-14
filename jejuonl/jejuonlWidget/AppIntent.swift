import AppIntents
import WidgetKit

struct TodayWidgetConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "도시"
    static var description = IntentDescription("이 위젯에 보여줄 시")

    @Parameter(title: "도시", default: .seogwipo)
    var city: CityAppEnum
}

enum CityAppEnum: String, AppEnum {
    case jejuSi
    case seogwipo

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "도시")

    static var caseDisplayRepresentations: [CityAppEnum: DisplayRepresentation] = [
        .jejuSi: "제주시",
        .seogwipo: "서귀포시",
    ]

    var cityID: CityID {
        CityID(rawValue: rawValue) ?? .seogwipo
    }
}
