//
//  InAppSettingsToggle.swift
//  InAppSettingsToggle
//
//  Created by David Stephens on 03/09/2021.
//

import SwiftUI

struct InAppSettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    init(_ titleKey: String, isOn: Binding<Bool>) {
        self.title = titleKey
        self._isOn = isOn
    }
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .padding(10)
            .padding(.horizontal, 10)
    }
}

struct InAppSettingsToggle_Previews: PreviewProvider {
    static var previews: some View {
        InAppSettingsToggle("A Settings Key", isOn: .constant(true))
    }
}
