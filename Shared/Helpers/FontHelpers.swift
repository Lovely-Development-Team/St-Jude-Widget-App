//
//  FontHelpers.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

extension Font {
    /// A font with the large title text style.
    public static var largeTitle: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }

    /// A font with the title text style.
    public static var title: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .title1).pointSize)
    }

    /// Create a font for second level hierarchical headings.
    public static var title2: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .title2).pointSize)
    }

    /// Create a font for third level hierarchical headings.
    public static var title3: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .title3).pointSize)
    }

    /// A font with the headline text style.
    public static var headline: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
    }

    /// A font with the subheadline text style.
    public static var subheadline: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
    }

    /// A font with the body text style.
    public static var body: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .body).pointSize)
    }

    /// A font with the callout text style.
    public static var callout: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .callout).pointSize)
    }

    /// A font with the footnote text style.
    public static var footnote: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
    }

    /// A font with the caption text style.
    public static var caption: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
    }

    /// Create a font with the alternate caption text style.
    public static var caption2: Font {
        return Font.custom(Font.customFontName, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize)
    }
    
    public static var customFontName: String {
        return "Krungthep"
    }
}
