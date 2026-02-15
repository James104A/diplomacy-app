import SwiftUI

// MARK: - Typography Scale

extension Font {
    /// 16pt bold — Game name / primary titles
    static let appTitle = Font.system(size: 16, weight: .bold)

    /// 14pt — Phase labels, supply center counts
    static let appSecondary = Font.system(size: 14)

    /// 14pt bold — Emphasized secondary text
    static let appSecondaryBold = Font.system(size: 14, weight: .bold)

    /// 12pt — Timestamps, captions
    static let appCaption = Font.system(size: 12)

    /// 12pt bold — Badge counts
    static let appBadge = Font.system(size: 12, weight: .bold)

    /// 20pt bold — Section headers
    static let appSectionHeader = Font.system(size: 20, weight: .bold)

    /// 24pt bold — Screen titles
    static let appScreenTitle = Font.system(size: 24, weight: .bold)
}
