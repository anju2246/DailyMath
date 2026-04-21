import SwiftUI

enum DMFont {
    static func largeTitle() -> Font { .system(size: 34, weight: .bold) }
    static func title() -> Font { .system(size: 28, weight: .bold) }
    static func title2() -> Font { .system(size: 22, weight: .bold) }
    static func title3() -> Font { .system(size: 20, weight: .bold) }
    static func headline() -> Font { .system(size: 17, weight: .semibold) }
    static func body() -> Font { .system(size: 17, weight: .regular) }
    static func callout() -> Font { .system(size: 15, weight: .regular) }
    static func calloutEmphasized() -> Font { .system(size: 15, weight: .semibold) }
    static func footnote() -> Font { .system(size: 13, weight: .regular) }
    static func caption() -> Font { .system(size: 12, weight: .regular) }
    static func caption2() -> Font { .system(size: 10, weight: .semibold) }
}
