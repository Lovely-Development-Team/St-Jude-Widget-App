//
//  FontHelpers.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

// If you get errors about this file when running a preview, swap the #if directives commented below

#if NOT_TRYING_TO_USE_PREVIEWS
//#if os(iOS)

extension Font {
    public static var customFontName: String { "SFPro" }
    
    public static func atSize(_ size: CGFloat) -> Font {
        return Font.system(size: size)
    }
    
    public static func largeTitle(disablePixelFont: Bool = false) -> Font { .largeTitle }
    public static func title(disablePixelFont: Bool = false) -> Font { .title }
    public static func title2(disablePixelFont: Bool = false) -> Font { .title2 }
    public static func title3(disablePixelFont: Bool = false) -> Font { .title3 }
    public static func headline(disablePixelFont: Bool = false) -> Font { .headline }
    public static func subheadline(disablePixelFont: Bool = false) -> Font { .subheadline }
    public static func body(disablePixelFont: Bool = false) -> Font { .body }
    public static func callout(disablePixelFont: Bool = false) -> Font { .callout }
    public static func footnote(disablePixelFont: Bool = false) -> Font { .footnote }
    public static func caption(disablePixelFont: Bool = false) -> Font { .caption }
    public static func caption2(disablePixelFont: Bool = false) -> Font { .caption2 }
    
}

#else

extension Font {
    
    /// A font with the large title text style.
    public static var largeTitle: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.largeTitle) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }

    /// A font with the title text style.
    public static var title: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.title) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .title1).pointSize)
    }
    
    /// Create a font for second level hierarchical headings.
    public static var title2: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.title2) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .title2).pointSize)
    }

    /// Create a font for third level hierarchical headings.
    public static var title3: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.title3) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .title3).pointSize)
    }

    /// A font with the headline text style.
    public static var headline: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.headline) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
    }

    /// A font with the subheadline text style.
    public static var subheadline: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.subheadline) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
    }

    /// A font with the body text style.
    public static var body: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.body) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .body).pointSize)
    }

    /// A font with the callout text style.
    public static var callout: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.callout) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .callout).pointSize)
    }

    /// A font with the footnote text style.
    public static var footnote: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.footnote) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
    }

    /// A font with the caption text style.
    public static var caption: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.caption) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
    }

    /// Create a font with the alternate caption text style.
    public static var caption2: Font {
        return UserDefaults.shared.disablePixelFont ? .system(.caption2) : Font.custom(Self.customFontName, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize)
    }
    
    public static var customFontName: String {
        return "ChicagoFLF"
    }
    
    public static func atSize(_ size: CGFloat) -> Font {
        return Font.custom(Self.customFontName, size: size)
    }
    
    public static func largeTitle(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.largeTitle) : .largeTitle
    }

    public static func title(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.title) : .title
    }

    public static func title2(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.title2) : .title2
    }

    public static func title3(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.title3) : .title3
    }

    public static func headline(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.headline) : .headline
    }

    public static func subheadline(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.subheadline) : .subheadline
    }

    public static func body(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.body) : .body
    }

    public static func callout(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.callout) : .callout
    }

    public static func footnote(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.footnote) : .footnote
    }

    public static func caption(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.caption) : .caption
    }

    public static func caption2(disablePixelFont: Bool = false) -> Font {
        disablePixelFont ? Font.system(.caption2) : .caption2
    }
    
}

#endif
