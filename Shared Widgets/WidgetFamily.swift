//
//  WidgetFamily.swift
//  WidgetFamily
//
//  Created by David on 25/08/2021.
//

import Foundation
import WidgetKit

#if os(iOS)
func isLargeSize(family: WidgetFamily) -> Bool {
    if #available(iOS 15.0, iOSApplicationExtension 15.0, *) {
        return family == .systemLarge || family == .systemExtraLarge
    } else {
        return family == .systemLarge
    }
}
#else
func isLargeSize(family: WidgetFamily) -> Bool {
    return family == .systemLarge
}
#endif

#if os(iOS)
func isExtraLargeSize(family: WidgetFamily) -> Bool {
    if #available(iOS 15.0, iOSApplicationExtension 15.0, *) {
        return family == .systemExtraLarge
    } else {
        return false
    }
}
#else
func isExtraLargeSize(family: WidgetFamily) -> Bool {
    return false
}
#endif

#if os(iOS)
func isLockScreen(family: WidgetFamily) -> Bool {
    if #available(iOSApplicationExtension 16.0, *) {
        if(family == .accessoryCircular ||
           family == .accessoryRectangular ||
           family == .accessoryInline) {
            return true
        }
    }
    return false
}
#endif
