//
//  AltIconPicker.swift
//  St Jude (iOS)
//
//  Created by Ben Cardy on 02/09/2024.
//

import UIKit
import SwiftUI

struct AltIconPicker: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var chosenIconName: String? = nil
    
    let iconWidth: CGFloat = 80
    
    let done: (Bool) -> ()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 10) {
                    ForEach(AltIcon.allCases) { icon in
                        VStack {
                            Button(action: {
                                setIcon(to: icon)
                            }) {
                                icon.image
                                    .frame(width: iconWidth, height: iconWidth)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
                .padding()
            }
            .task {
                chosenIconName = UIApplication.shared.alternateIconName
            }
        }
    }
    
    func setIcon(to icon: AltIcon) {
        icon.set()
        chosenIconName = icon.fileName
    }
    
}

#Preview {
    AltIconPicker() { _ in
        
    }
}
