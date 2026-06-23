//
//  AboutViewSettings.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/9/25.
//

import SwiftUI

struct ToggleSetting: View {
    var label: String
    @Binding var setting: Bool
    var onEnable: (() -> Void)? = nil
    var onDisable: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            Text(label)
                .fullWidth()
            HStack {
                Button(action: {
                    withAnimation {
                        self.setting = false
                        self.onDisable?()
                    }
                    
                }) {
                    Text("Yes")
                        .foregroundColor(!self.setting ? Theme.current.contentColorForAccent : .primary)
                        .frame(maxWidth: .infinity)
                }
                .themedButton(type: .primary, tint: !self.setting ? Theme.current.accentColor : .tertiarySystemBackground)
                Button(action: {
                    withAnimation {
                        self.setting = true
                        self.onEnable?()
                    }
                }) {
                    Text("No")
                        .foregroundColor(self.setting ? Theme.current.contentColorForAccent : .primary)
                        .frame(maxWidth: .infinity)
                }
                .themedButton(type: .primary, tint: self.setting ? Theme.current.accentColor : .tertiarySystemBackground)
            }
        }
    }
}

struct AltIconButton: View {
    @Binding var currentIcon: AltIcon?
    var icon: AltIcon
    
    var body: some View {
            Button(action: {
                icon.set()
                withAnimation {
                    currentIcon = icon
                }
            }) {
                VStack {
                    icon.image
                        .frame(width: 75, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 10)
                    Text(icon.title)
                        .foregroundStyle(self.currentIcon == self.icon ? Theme.current.contentColorForAccent : Color.primary)
                }
            }
            .themedButton(type: .primary,
                          tint: self.currentIcon == self.icon ? Theme.current.accentColor : .tertiarySystemBackground,
                          capsuleShape: false)
//            .buttonStyle(PrimaryButtonStyle(tint: self.currentIcon == self.icon ? .accentColor : .tertiarySystemBackground, useCapsuleShape: false))
    }
}

// TODO: Add these back conditionally
// 2024 theme settings
/*
GroupBox {
    VStack {
        Text("Use Pixel Font")
            .bold()
        HStack {
            Button(action: {
                disablePixelFont = false
            }) {
                Text("Yes")
                    .fontWeight(.bold)
                    .foregroundColor(!disablePixelFont ? .black : .primary)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(tint: !disablePixelFont ? .accentColor : .tertiarySystemBackground))
            Button(action: {
                disablePixelFont = true
            }) {
                Text("No")
                    .fontWeight(.bold)
                    .foregroundColor(disablePixelFont ? .black : .primary)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(tint: disablePixelFont ? .accentColor : .tertiarySystemBackground))
        }
    }
}
 */

// 2025 theme settings
/*
GroupBox {
    VStack {
        Text("Accent Color")
            .fontWeight(.bold)
        ForEach(Player.displayOrder) { player in
            let object = player.getPlayer()
            Button(action: {
                self.selectedAccentColor = player.rawValue
            }, label: {
                HStack {
                    Image.imageAtScale(object.headImage, scale: .spriteScale)
                        .scaleEffect(x: object.facingLeft ? -1 : 1)
                    Spacer()
                    Text(object.name)
                        .fontWeight(.bold)
                        .foregroundStyle(self.selectedAccentColor == player.rawValue ? .black : .white)

                    Spacer()
                }
                .padding(.horizontal)
            })
            .buttonStyle(PrimaryButtonStyle(tint: self.selectedAccentColor == player.rawValue ? .accentColor : .tertiarySystemBackground))
        }
        
        Text("Glow opacity")
            .fontWeight(.bold)
            .padding(.top)
        Slider(value: self.$debugGlowOpacity, in: 0...1)
            .padding(.bottom)
        
        Text("Edge highlight opacity")
            .fontWeight(.bold)
        Slider(value: self.$debugEdgeHighlightOpacity, in: 0...1)
    }
}
 */
