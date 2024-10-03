//
//  PixelRounding.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/7/24.
//

import SwiftUI

struct PixelRounding: ViewModifier {
    var geometry: GeometryProxy? = nil
    var pixelScale: Double = Double.spriteScale
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            Group {
                if let geometry = self.geometry {
                    content
                        .mask {
                            HStack(spacing:-1) {
                                Rectangle()
                                    .frame(width: round(10*self.pixelScale)+1,
                                           height: max(0, geometry.size.height - round(((2*10)*self.pixelScale))))
                                Rectangle()
                                    .frame(width: max(0, geometry.size.width-round(((2*10)*self.pixelScale))))
                                Rectangle()
                                    .frame(width: round(10*self.pixelScale)+1,
                                           height: max(0, geometry.size.height - round(((2*10)*self.pixelScale))))
                            }
                        }
                } else {
                    content
                        .mask {
                            GeometryReader { geometry in
                                HStack(spacing:-1) {
                                    Rectangle()
                                        .frame(width: round(10*self.pixelScale)+1,
                                               height: max(0, geometry.size.height - round(((2*10)*self.pixelScale))))
                                    Rectangle()
                                        .frame(width: max(0, geometry.size.width-round(((2*10)*self.pixelScale))))
                                    Rectangle()
                                        .frame(width: round(10*self.pixelScale)+1,
                                               height: max(0, geometry.size.height - round(((2*10)*self.pixelScale))))
                                }
                            }
                        }
                }
            }
        } else {
            content
        }
    }
}
