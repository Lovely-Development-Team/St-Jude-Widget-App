//
//  RandomLandscapeView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/12/24.
//

import SwiftUI

enum LandscapeElementType: Int, CaseIterable {
    case myke
    case stephen
    case coin
    case bush
    case flower
    case empty
    
    static func random(isMainScreen: Bool = true) -> LandscapeElementType {
        if(isMainScreen) {
            return self.allCases.filter({$0 != .myke && $0 != .stephen})
                .randomElement()!
        }
        return self.allCases.filter({$0 != .myke && $0 != .stephen && $0 != .coin})
            .randomElement()!
    }
}

struct LandscapeElement: Identifiable {
    var id = UUID()
    
    var type: LandscapeElementType
    var offset: CGFloat = CGFloat.random(in: -25...25)
    
    @ViewBuilder
    func view(colorScheme: ColorScheme, easterEggEnabled: Bool) -> some View {
        switch self.type {
        case .myke:
            if(easterEggEnabled) {
                    ZStack(alignment:.bottom) {
                        AdaptiveImage.isoGround(colorScheme: colorScheme)
                            .imageAtScale()
                        VStack {
                            EasterEggImage(content: {
                                AdaptiveImage.jonyCube(colorScheme: colorScheme)
                                    .imageAtScale()
                            }, onTap: {
                                SoundEffectHelper.shared.play(.softMatt)
                            })
                                .padding(.bottom, (10 * 10) * Double.spriteScale)
                        }
                    }
            } else {
                EasterEggImage(content: {
                    AdaptiveImage.myke(colorScheme: colorScheme)
                        .imageAtScale()
                }, onTap: {
                    SoundEffectHelper.shared.play(.mykeRandom)
                })
            }
        case .stephen:
            if(easterEggEnabled) {
                EasterEggImage(content: {
                    AdaptiveImage.dogcow(colorScheme: colorScheme)
                        .imageAtScale()
                        .scaleEffect(x: -1)
                }, onTap: {
                    SoundEffectHelper.shared.play(.moof)
                })
            } else {
                EasterEggImage(content: {
                    AdaptiveImage.stephen(colorScheme: colorScheme)
                        .imageAtScale()
                        .scaleEffect(x: -1)
                }, onTap: {
                    SoundEffectHelper.shared.play(.stephenRandom)
                })
            }
        case .bush:
            AdaptiveImage.bush(colorScheme: colorScheme)
                .imageAtScale()
        case .flower:
            AdaptiveImage.flower(colorScheme: colorScheme)
                .imageAtScale()
        case .coin:
            TappableCoin()
        default:
            EmptyView()
        }
    }
}

struct RandomLandscapeData {
    var numBackgroundSlots = 5
    var numGroundElements = 4
    var numElevatedElements = 2
    
    var mykeElevated = false
    var stephenElevated = false
    var mykeLocation = -1
    var stephenLocation = -1
    
    var elevatedShown = false
    var backgroundShown = false
    
    var isForMainScreen = true
    
    var groundElements: [LandscapeElement] = []
    var elevatedElements: [LandscapeElement] = []
    
    var elevatedBlockIndex = -1
    var backgroundBlockIndex = -1
    
    // false = solid, true = striped
    var backgroundBlockType = Bool.random()
    var backgroundBlockColor = Color.randomBrandedColor
    
    init(isForMainScreen: Bool = true) {
        self.isForMainScreen = isForMainScreen
        self.generate()
    }
    
    mutating func generate() {
        self.backgroundShown = self.isForMainScreen ? Bool.random() : false
        self.elevatedShown = self.isForMainScreen ? Bool.random() : false
        self.numGroundElements = UserDefaults.shared.easterEggEnabled2024 ? 3 : 4
        
        self.mykeElevated = self.elevatedShown ? Bool.random() : false
        if(UserDefaults.shared.easterEggEnabled2024) {
            self.stephenElevated = self.elevatedShown ? !self.mykeElevated : false
        } else {
            self.stephenElevated = self.elevatedShown ? Bool.random() : false
        }
        
        if(self.isForMainScreen) {
            self.mykeLocation = Int.random(in: 0..<(self.mykeElevated ? self.numElevatedElements : self.numGroundElements))
            
            repeat {
                self.stephenLocation = Int.random(in: 0..<(self.stephenElevated ? self.numElevatedElements : self.numGroundElements))
            } while(self.stephenLocation == self.mykeLocation)
        } else {
            self.mykeLocation = -1
            self.stephenLocation = -1
        }
        
        self.elevatedBlockIndex = Int.random(in: 0..<self.numBackgroundSlots)
        self.backgroundBlockIndex = Int.random(in: 0..<self.numBackgroundSlots)
        
        self.groundElements = (0..<self.numGroundElements).map { i in
            if(!self.mykeElevated && self.mykeLocation == i) {
                return .init(type: .myke)
            }
            
            if(!self.stephenElevated && self.stephenLocation == i) {
                return .init(type: .stephen)
            }
            
            return .init(type: .random(isMainScreen: self.isForMainScreen))
        }
        
        if(self.mykeElevated && UserDefaults.shared.easterEggEnabled2024) {
            self.elevatedElements = [.init(type: .myke)]
        } else if(self.stephenElevated && UserDefaults.shared.easterEggEnabled2024) {
            self.elevatedElements = [.init(type: .stephen)]
        } else {
            self.elevatedElements = (0..<self.numElevatedElements).map { i in
                if(self.mykeElevated && self.mykeLocation == i) {
                    return .init(type: .myke)
                }
                
                if(self.stephenElevated && self.stephenLocation == i) {
                    return .init(type: .stephen)
                }
                
                return .init(type: .random(isMainScreen: self.isForMainScreen))
            }
        }
        self.backgroundBlockType = Bool.random()
        self.backgroundBlockColor = Color.randomBrandedColor
    }
}

struct RandomLandscapeView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    
    @Binding var data: RandomLandscapeData
    
    @ViewBuilder var content: Content
    
    @ViewBuilder
    func backgroundLayer() -> some View {
        HStack(alignment: .bottom, spacing:0) {
            ForEach(0..<self.data.numBackgroundSlots) { i in
                Spacer()
                if(self.data.backgroundBlockIndex == i) {
                    Group {
                        if(self.data.backgroundBlockType) {
                            AdaptiveImage.backgroundTall(colorScheme: self.colorScheme)
                                .imageAtScale()
                        } else {
                            AdaptiveImage.backgroundStripeTall(colorScheme: self.colorScheme)
                                .imageAtScale()
                        }
                    }
                    .colorMultiply(self.data.backgroundBlockColor.lighter())
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func elevatedLevel() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(0..<self.data.numBackgroundSlots) { i in
                Spacer()
                if(self.data.elevatedBlockIndex == i) {
                    VStack(spacing:0) {
                        HStack(alignment: .bottom, spacing:0) {
                            ForEach(self.data.elevatedElements) { element in
                                Spacer()
                                element.view(colorScheme: self.colorScheme, easterEggEnabled: self.easterEggEnabled2024)
                            }
                            Spacer()
                        }
                        AdaptiveImage.ground(colorScheme: self.colorScheme)
                            .imageAtScale()
                    }
                    .scaledToFit()
                }
            }
            Spacer()
            
        }
    }
    
    @ViewBuilder
    func groundLevel() -> some View {
        HStack(alignment:.bottom, spacing:0) {
            ForEach(self.data.groundElements) { element in
                Spacer()
                element.view(colorScheme: self.colorScheme, easterEggEnabled: self.easterEggEnabled2024)
            }
            Spacer()
        }
    }
    
    var body: some View {
        VStack(spacing:0) {
            ZStack(alignment: .bottom) {
                if(self.data.elevatedShown) {
                    self.elevatedLevel()
                }
                self.content
                self.groundLevel()
            }
            .background(alignment: .bottom) {
                if(self.data.backgroundShown) {
                    self.backgroundLayer()
                }
            }
        }
        .frame(maxWidth: min(Double.screenWidth, Double.stretchedContentMaxWidth))
    }
}

struct RandomLandscapePreviewView: View {
    @State private var data = RandomLandscapeData()
    @State private var notMainData = RandomLandscapeData(isForMainScreen: false)
    var body: some View {
        Group {
            ZStack {
                RandomLandscapeView(data: self.$data) {
                    Text("Main Screen")
                }
            }
        }
        .border(.black)
        Button(action: {
            self.data.generate()
        }, label: {
            Text("New")
        })
        Group {
            ZStack {
                RandomLandscapeView(data: self.$notMainData) {
                    Text("Not Main Screen")
                }
            }
        }
        .border(.black)
        Button(action: {
            self.notMainData.generate()
        }, label: {
            Text("New")
        })
    }
}

#Preview {
    RandomLandscapePreviewView()
}
