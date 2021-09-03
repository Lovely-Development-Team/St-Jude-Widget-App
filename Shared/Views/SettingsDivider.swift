//
//  SettingsDivider.swift
//  SettingsDivider
//
//  Created by David Stephens on 03/09/2021.
//

import SwiftUI

struct SettingsDivider: View {
    var body: some View {
        GeometryReader { proxy in
            Divider()
                .offset(x: 20, y: 0)
                .frame(width: proxy.size.width - 20)
        }.frame(height: 0)
    }
}

struct SettingsDivider_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDivider()
    }
}
