import SwiftUI

// MARK: - Typography Scale (Dynamic Type compatible)

extension Font {
    /// 16pt bold — Game name / primary titles (scales with headline)
    static let appTitle = Font.headline

    /// 14pt — Phase labels, supply center counts (scales with subheadline)
    static let appSecondary = Font.subheadline

    /// 14pt bold — Emphasized secondary text (scales with subheadline)
    static let appSecondaryBold = Font.subheadline.bold()

    /// 12pt — Timestamps, captions (scales with caption)
    static let appCaption = Font.caption

    /// 12pt bold — Badge counts (scales with caption)
    static let appBadge = Font.caption.bold()

    /// 20pt bold — Section headers (scales with title3)
    static let appSectionHeader = Font.title3.bold()

    /// 24pt bold — Screen titles (scales with title2)
    static let appScreenTitle = Font.title2.bold()
}
