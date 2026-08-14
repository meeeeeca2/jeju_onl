import Foundation

enum ScheduleEngineError: Error, Equatable {
    case missingTimeZone
    case catalogMissing
    case catalogItemUnknown(String)
    case catalogSchemaTooNew(Int)
}
