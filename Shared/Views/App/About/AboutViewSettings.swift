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
                .themedButton(type: .primary, tint: !self.setting ? Theme.current.accentColor : .tertiarySystemBackground, id: "toggle-yes-\(label)")
                .sensoryFeedback(.success, trigger: self.setting)
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
                .themedButton(type: .primary, tint: self.setting ? Theme.current.accentColor : .tertiarySystemBackground, id: "toggle-no-\(label)")
                .sensoryFeedback(.success, trigger: self.setting)
            }
        }
    }
}

struct AltIconButton: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentIcon: AltIcon?
    var icon: AltIcon
    var disabled: Bool
    @State private var showMilestoneAlert: Bool = false
    @Binding var selectedDestination: CampaignListDestination?
    
    var body: some View {
            Button(action: {
                if !disabled {
                    icon.set()
                    withAnimation {
                        currentIcon = icon
                    }
                } else {
                    self.showMilestoneAlert = true
                }
            }) {
                VStack {
                    ZStack {
                        icon.image
                            .frame(width: 75, height: 75)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .blur(radius: disabled ? 10 : 0)
                        if disabled {
                            Image(systemName: "lock.fill")
                        }
                    }
                    if disabled {
                        Text("Placholder").redacted(reason: .placeholder)
                            .foregroundStyle(.primary)
                    } else {
                        Text(icon.title)
                            .foregroundStyle(self.currentIcon == self.icon ? Theme.current.contentColorForAccent : Color.primary)
                    }
                }
            }
            .themedButton(type: .primary,
                          tint: self.currentIcon == self.icon ? Theme.current.accentColor : .tertiarySystemBackground,
                          capsuleShape: false, id: "\(self.icon.rawValue)-\(self.icon.id)")
            .sensoryFeedback(.success, trigger: currentIcon)
            .alert("That there icon's locked.", isPresented: self.$showMilestoneAlert, actions: {
                Button(action: {
                    self.showMilestoneAlert = false
                    Task {
                        if let campaign = try? await AppDatabase.shared.fetchCampaign(with: TLD_CAMPAIGN) {
                            self.selectedDestination = .campaign(campaign, true)
                            self.dismiss()
                        }
                    }
                }, label: {
                    Text("Take me there!")
                })
            }, message: {
                Text("Donate to our campaign to unlock it!")
            })
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
