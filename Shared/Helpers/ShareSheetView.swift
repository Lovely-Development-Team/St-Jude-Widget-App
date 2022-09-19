//
//  ShareSheetView.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2022.
//

import SwiftUI
import UIKit

// From https://www.appsloveworld.com/swift/100/162/swift-uiactivityviewcontroller
extension UIActivity.ActivityType {
    static let openInSafari = UIActivity.ActivityType(rawValue: "openInSafari")
}

final class SafariActivity: UIActivity {

    var url: URL?

    var activityCategory: UIActivity.Category = .action

    override var activityType: UIActivity.ActivityType {
        .openInSafari
    }

    override var activityTitle: String? {
        "Open in Safari"
    }

    override var activityImage: UIImage? {
        UIImage(systemName: "safari")?.applyingSymbolConfiguration(.init(scale: .large))
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        activityItems.contains { $0 is URL ? UIApplication.shared.canOpenURL($0 as! URL) : false }
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        url = activityItems.first { $0 is URL ? UIApplication.shared.canOpenURL($0 as! URL) : false } as? URL
    }

    override func perform() {
        if let url = url {
            UIApplication.shared.open(url)
        }
        self.activityDidFinish(true)
    }

}

// From https://ishtiz.com/swiftui/share-sheet-in-swiftui-using-uiactivityviewcontroller
struct ShareSheetView: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void

    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = [SafariActivity()]
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
