import Foundation

enum WindowState: String, Equatable, Sendable {
    /// [04:00, 15:00) 배출일 기준. 닫힘 = 다음 창을 기다리는 중.
    case beforeOpen
    /// [15:00, 익일 04:00)
    case open
}
