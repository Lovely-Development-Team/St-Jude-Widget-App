//
//  ZoomTransitioniOS26.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 11/21/25.
//

import SwiftUI

struct ZoomTransitioniOS26Source: ViewModifier {
    var id: any Hashable
    var namespace: Namespace.ID
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .matchedTransitionSource(id: self.id, in: self.namespace)
        } else {
            content
        }
    }
}

struct ZoomTransitioniOS26: ViewModifier {
    var id: any Hashable
    var namespace: Namespace.ID
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationTransition(.zoom(sourceID: self.id, in: self.namespace))
        } else {
            content
        }
    }
}

extension View {
    func zoomTransitioniOS26Source(id: any Hashable, namespace: Namespace.ID) -> some View {
        self
            .modifier(ZoomTransitioniOS26Source(id: id, namespace: namespace))
    }
    
    func zoomTransitioniOS26(id: any Hashable, namespace: Namespace.ID) -> some View {
        self
            .modifier(ZoomTransitioniOS26(id: id, namespace: namespace))
    }
}
