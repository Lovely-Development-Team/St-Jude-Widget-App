//
//  PixelRounding.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/7/24.
//

import SwiftUI

struct PixelRounding: ViewModifier {
    @State var geometry: GeometryProxy? = nil
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            if let geometry = self.geometry {
                content
                    .mask {
                        HStack(spacing:0) {
                            Rectangle()
                                .frame(width: round(10*Double.spriteScale),
                                       height: geometry.size.height - round(((2*10)*Double.spriteScale)))
                            Rectangle()
                                .frame(width: geometry.size.width-round(((2*10)*Double.spriteScale)))
                            Rectangle()
                                .frame(width: round(10*Double.spriteScale),
                                       height: geometry.size.height - round(((2*10)*Double.spriteScale)))
                        }
                    }
            } else {
                content
                    .mask {
                        GeometryReader { geometry in
                            HStack(spacing:0) {
                                Rectangle()
                                    .frame(width: round(10*Double.spriteScale),
                                           height: geometry.size.height - round(((2*10)*Double.spriteScale)))
                                Rectangle()
                                    .frame(width: geometry.size.width-round(((2*10)*Double.spriteScale)))
                                Rectangle()
                                    .frame(width: round(10*Double.spriteScale),
                                           height: geometry.size.height - round(((2*10)*Double.spriteScale)))
                            }
                        }
                    }
            }
        } else {
            content
        }
    }
}
