//
//  RandomCampaignPickerView2024.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/8/24.
//

import SwiftUI

enum InputType {
    case up
    case down
    case left
    case right
    case a
    case b
    case start
    
    static var konamiCode: [InputType] = [.up, .up, .down, .down, .left, .right, .left, .right, .b, .a, .start]
}

struct RandomCampaignPickerView2024: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Namespace var namespace
    
    @State private var landscapeData = RandomLandscapeData(isForMainScreen: false)
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024 = false
    
    @Binding var campaignChoiceID: UUID?
    var allCampaigns: [Campaign]
    @State private var chosenCampaign: Campaign? = nil
    
    @State private var jumping: Bool = false
    @State private var resultOpacity = false
    @State private var resultOffset = false
    @State private var showShareSheet = false
    
    @State private var animationDuration: Double = 0.2
    
    @State private var showingResult: Bool = false
    
    @State private var spriteOffset: Double = 0.0
    
    var spriteWidth: Double {
        if(self.easterEggEnabled2024) {
            return self.isMyke ? Double.jonycubeSpriteWidth : Double.dogcowSpriteWidth
        }
        return Double.hostSpriteWidth
    }
    
    @State private var spriteIncrement: Double = 5.0
    
    @State private var numBoxes: Int = 3
    
    @State private var hitArr: [Bool] = []
    
    @State private var spriteX: Double = 0
    @State private var boxXArr: [Int: Double] = [:]
    @State private var currentBoxUnder: Int? = nil
    
    @State private var spriteImage: AdaptiveImage = .stephen(colorScheme: .light)
    @State private var animationImages: [AdaptiveImage] = AdaptiveImage.stephenWalkCycle(colorScheme: .light)
    @State private var isMyke: Bool = false
    @State private var isMoving: Bool = false
    // false = left, true = right
    @State private var direction = true
    
    @State private var justinAnAnimationIsInProgressStopTryingToBreakThingsOkay: Bool = false
    
    @State private var inputStackTimer: Timer? = nil
    @State private var inputStack: [InputType] = []
    @State private var showingKonamiCodeAlert: Bool = false
    
    @AppStorage(UserDefaults.coinCountKey, store: UserDefaults.shared) private var coinCount: Int = 0
    
    func getRandomCampaign() -> Campaign? {
        return allCampaigns.filter({$0.id != RELAY_CAMPAIGN}).randomElement()
    }
    
    var isAlmostKonamiCode: Bool {
        return self.inputStack == Array(InputType.konamiCode.prefix(upTo: InputType.konamiCode.count-1))
    }
    
    var isKonamiCode: Bool {
        return self.inputStack == InputType.konamiCode
    }
    
    func addInputToStack(input: InputType) {
        self.inputStackTimer?.invalidate()
        self.inputStack.append(input)
        
        if(self.isKonamiCode) {
            self.showingKonamiCodeAlert = true
        }
        
        self.inputStackTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: {_ in
            self.inputStack = []
        })
    }
    
    func moveSprite(containerGeometry: GeometryProxy, by increment: Double, manual: Bool = true) {
        withAnimation(manual ? .easeInOut(duration: 0.1) : .default) {
            direction = increment > 0
            let desiredPosition = self.spriteOffset + increment
            let minBound: Double
            let maxBound: Double
            
            if isMyke {
                minBound = -(containerGeometry.size.width - 60 - self.spriteWidth)
                maxBound = 0
            } else {
                minBound = 0
                maxBound = containerGeometry.size.width - 30 - self.spriteWidth
            }
            
            self.spriteOffset = max(minBound, min(maxBound, desiredPosition))
            
            self.currentBoxUnder = nil
            
            for element in self.boxXArr.sorted(by: {$0.value > $1.value}) {
                let index = element.key
                let spriteMaxX = self.spriteX + self.spriteWidth
                let boxX = element.value
                let boxMaxX = boxX+Double.questionBoxWidth
                
                if(spriteMaxX > boxX && self.spriteX < boxMaxX) {
                    currentBoxUnder = index
                    break
                }
            }
        }
    }
    
    func activateBox(_ currentBox: Int, withDelay delay: Bool = true) {
        guard !self.justinAnAnimationIsInProgressStopTryingToBreakThingsOkay else { return }
        self.justinAnAnimationIsInProgressStopTryingToBreakThingsOkay = true
        self.showingResult = false
        self.resultOpacity = false
        SoundEffectHelper.shared.play(.jump)
        DispatchQueue.main.asyncAfter(deadline: .now()+(delay ? self.animationDuration/2 : 0)) {
            self.resultOffset = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+(delay ? self.animationDuration : 0)) {
            withAnimation(.none) {
                self.chosenCampaign = self.getRandomCampaign()
            }
            self.coinCount += 1
            self.showingResult = true
            self.hitArr[currentBox] = true
            self.resultOpacity = true
            self.resultOffset = true
            DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                self.hitArr = (0..<self.numBoxes).map { _ in return false }
                self.justinAnAnimationIsInProgressStopTryingToBreakThingsOkay = false
            }
        }
    }
    
    func jump() {
        withAnimation {
            self.hitArr = (0..<self.numBoxes).map { _ in return false }
            self.jumping = true
            if(self.easterEggEnabled2024) {
                if(!self.isMyke) {
                    self.spriteImage = AdaptiveImage.dogcowJump(colorScheme: self.colorScheme)
                }
            } else {
                self.spriteImage = AdaptiveImage(colorScheme: self.colorScheme, light: self.isMyke ? .mykeWalk1 : .stephenWalk1)
            }
            if let currentBox = self.currentBoxUnder {
                self.activateBox(currentBox)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                self.jumping = false
                if(self.easterEggEnabled2024) {
                    self.spriteImage = self.isMyke ? .jonyCube(colorScheme: self.colorScheme) : .dogcow(colorScheme: self.colorScheme)
                } else {
                    self.spriteImage = self.isMyke ? .myke(colorScheme: self.colorScheme) : .stephen(colorScheme: self.colorScheme)
                }
            }
        }
    }
    
    @ViewBuilder
    func controllerView(containerGeometry: GeometryProxy) -> some View {
        HStack {
            Rectangle()
                .fill(.clear)
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .overlay(alignment: .center) {
                    GeometryReader { geometry in
                        ZStack(alignment: .center) {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: geometry.size.width / 3)
                                .overlay {
                                    VStack {
                                        Button(action: {
                                            // reset input stack
                                            if(self.inputStack != [.up]) {
                                                self.inputStack = []
                                            }
                                            self.addInputToStack(input: .up)
                                        }, label: {
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .overlay {
                                                    Image("pixel-chevron-right")
                                                        .foregroundStyle(.white)
                                                        .rotationEffect(.degrees(-90))
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(BlockButtonStyle(tint: .accentColor))
                                        Spacer()
                                        Button(action: {
                                            self.addInputToStack(input: .down)
                                        }, label: {
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .overlay {
                                                    Image("pixel-chevron-right")
                                                        .foregroundStyle(.white)
                                                        .rotationEffect(.degrees(90))
                                                        .scaleEffect(x: -1, y: 1)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(BlockButtonStyle(tint: .accentColor))
                                    }
                                }
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(height: geometry.size.height / 3)
                                .overlay {
                                    HStack {
                                        Button(action: {}, label: {
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .overlay {
                                                    Image("pixel-chevron-right")
                                                        .foregroundStyle(.white)
                                                        .scaleEffect(x: -1, y: 1)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(BlockButtonStyle(tint: .accentColor, usingPressAndHoldGesture: true, onStart: {
                                            self.addInputToStack(input: .left)
                                            self.isMoving = true
                                        }, action: {
                                            self.moveSprite(containerGeometry: containerGeometry, by: -self.spriteIncrement)
                                        }, onEnd: {
                                            self.isMoving = false
                                        }))
                                        Spacer()
                                        Button(action: {}, label: {
                                            Rectangle()
                                                .foregroundStyle(.clear)
                                                .overlay {
                                                    Image("pixel-chevron-right")
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(BlockButtonStyle(tint: .accentColor, usingPressAndHoldGesture: true, onStart: {
                                            self.addInputToStack(input: .right)
                                            self.isMoving = true
                                        }, action: {
                                            self.moveSprite(containerGeometry: containerGeometry, by: self.spriteIncrement)
                                        }, onEnd: {
                                            self.isMoving = false
                                        }))
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            Spacer()
            Rectangle()
                .fill(.clear)
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .overlay {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Spacer()
                            Button(action: {
                                self.addInputToStack(input: .a)
                                self.jump()
                            }, label: {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .aspectRatio(contentMode: .fit)
                                    .overlay {
                                        Text("A")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                    }
                            })
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                        }
                        HStack(spacing: 0) {
                            Button(action: {
                                self.addInputToStack(input: .b)
                            }, label: {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .aspectRatio(contentMode: .fit)
                                    .overlay {
                                        Text("B")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                    }
                            })
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            Spacer()
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    func questionBoxesView(containerGeometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            if(!self.hitArr.isEmpty) {
                ForEach(0..<self.numBoxes) { i in
                    Spacer()
                    Button(action: {
                        if !self.justinAnAnimationIsInProgressStopTryingToBreakThingsOkay {
                            withAnimation {
                                var boxOffsetIndex = i
                                var offsetMultiplier = 1.0
                                var adjustOffset = 0.0
                                
                                if isMyke {
                                    boxOffsetIndex = self.numBoxes - (i + 1)
                                    offsetMultiplier = -1
                                    adjustOffset = (self.spriteWidth / 2)
                                }
                                
                                if let newOffset = self.boxXArr[boxOffsetIndex] {
                                    let newSpriteOffset = (newOffset * offsetMultiplier) + adjustOffset
                                    self.isMoving = true
                                    self.moveSprite(containerGeometry: containerGeometry, by: newSpriteOffset-self.spriteOffset, manual: false)
                                }
                                
                                self.currentBoxUnder = i
                                DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                                    self.activateBox(i)
                                    self.isMoving = false
                                    self.jump()
                                }
                            }
                        }
                    }) {
                        AdaptiveImage.questionBox(colorScheme: self.colorScheme)
                            .imageAtScale()
                            .offset(y: self.hitArr[i] ? -10 : 0)
                            .animation(.easeOut(duration: self.animationDuration), value: self.hitArr)
                            .background {
                                GeometryReader { geometry in
                                    let boxX =  geometry.frame(in: .global).origin.x
                                    if let storedX = self.boxXArr[i] {
                                        if(boxX != storedX) {
                                            self.boxXArr[i] = boxX
                                        }
                                    } else {
                                        self.boxXArr[i] = boxX
                                    }
                                    
                                    return Color.clear
                                }
                            }
                            .background(alignment: .top) {
                                TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024, collectable: false, spinOnceOnTap: false, offset: 0, interval: 0.05)
                                    .offset(y: self.hitArr[i] ? -80 : 0)
                                    .opacity(self.hitArr[i] ? 0.0 : 2.0)
                            }
                            .compositingGroup()
                    }
                }
                Spacer()
            }
        }
    }
    
    var body: some View {
        GeometryReader { mainGeometry in
            VStack(spacing:0) {
                RandomLandscapeView(data: self.$landscapeData) {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .overlay {
                            VStack(spacing:0) {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .overlay(alignment: .center) {
                                        Group {
                                            if let campaign = self.chosenCampaign {
                                                VStack {
                                                    Button(action: {
                                                        self.campaignChoiceID = self.chosenCampaign?.id
                                                        self.dismiss()
                                                    }, label: {
                                                        FundraiserListItem(campaign: campaign, sortOrder: .byAmountRaised, showBackground: false, showShareSheet: self.$showShareSheet)
                                                    })
                                                    .buttonStyle(BlockButtonStyle())
                                                }
                                            } else {
                                                GroupBox {
                                                    Text("No campaigns to choose from")
                                                        .font(.headline)
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                }
                                                .groupBoxStyle(BlockGroupBoxStyle())
                                            }
                                        }
                                        .opacity(self.resultOpacity ? 1.0 : 0.0)
                                        .offset(y: self.resultOffset ? 0 : 20)
                                        .animation(.easeOut(duration: self.animationDuration), value: self.resultOffset)
                                        .animation(.easeInOut(duration: self.animationDuration/2), value: self.resultOpacity)
                                        .frame(maxWidth: Double.stretchedContentMaxWidth)
                                    }
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .overlay(alignment: .bottom) {
                                        VStack(alignment: .leading, spacing: 0) {
                                            self.questionBoxesView(containerGeometry: mainGeometry)
                                            Group {
                                                if(self.easterEggEnabled2024 && self.isMyke) {
                                                    Rectangle()
                                                        .foregroundStyle(.clear)
                                                        .overlay(alignment: .bottomTrailing) {
                                                            ZStack(alignment:.bottom) {
                                                                AdaptiveImage.isoGround(colorScheme: self.colorScheme)
                                                                    .imageAtScale()
                                                                    .matchedGeometryEffect(id: "stephenSprite", in: self.namespace)
                                                                    .background {
                                                                        GeometryReader { geometry in
                                                                            self.spriteX = geometry.frame(in: .global).origin.x
                                                                            return Color.clear
                                                                        }
                                                                    }
                                                                VStack {
                                                                    if(!self.jumping) {
                                                                        Spacer()
                                                                    }
                                                                    AdaptiveImage.jonyCube(colorScheme: self.colorScheme)
                                                                        .imageAtScale()
                                                                        .padding(.bottom, (10 * 10) * Double.spriteScale)
                                                                        .scaleEffect(x: self.direction ? -1 : 1)
                                                                    if(self.jumping) {
                                                                        Spacer()
                                                                    }
                                                                }
                                                            }
                                                                .offset(x: self.spriteOffset)
                                                                
                                                        }
                                                } else {
                                                    Rectangle()
                                                        .foregroundStyle(.clear)
                                                        .overlay(alignment: self.jumping ? (self.isMyke ? .topTrailing : .topLeading) : (self.isMyke ? .bottomTrailing : .bottomLeading)) {
                                                            AnimatedAdaptiveImage(idleImage: self.spriteImage, images: self.animationImages, animating: self.$isMoving)
                                                                .scaleEffect(x: self.direction ? -1 : 1)
                                                                .matchedGeometryEffect(id: "stephenSprite", in: self.namespace)
                                                                .background {
                                                                    GeometryReader { geometry in
                                                                        self.spriteX = geometry.frame(in: .global).origin.x
                                                                        return Color.clear
                                                                    }
                                                                }
                                                                .offset(x: self.spriteOffset)
                                                        }
                                                }
                                            }
                                            
                                        }
                                    }
                                    .frame(maxHeight: 200)
                            }
                            .padding(.horizontal)
                        }
                        .animation(.easeOut(duration: self.animationDuration), value: self.jumping)
                        .frame(maxHeight: .infinity)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(alignment: .bottom) {
                    SkyView()
                }
                .overlay(alignment: .bottomTrailing) {
                    if(self.isAlmostKonamiCode || self.isKonamiCode) {
                        Button(action: {
                            self.addInputToStack(input: .start)
                        }, label: {
                            Text("Start")
                                .foregroundStyle(.white)
                        })
                        .buttonStyle(BlockButtonStyle(tint: .accentColor))
                        .padding()
                        .padding(.bottom)
                    }
                }
                AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                    .tiledImageAtScale(axis: .horizontal)
                VStack {
                    self.controllerView(containerGeometry: mainGeometry)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    GeometryReader { geometry in
                        AdaptiveImage.undergroundRepeatable(colorScheme: self.colorScheme)
                            .tiledImageAtScale()
                            .frame(height: geometry.size.height + 1000)
                    }
                }
            }
        }
        .onAppear {
            self.hitArr = (0..<self.numBoxes).map { _ in return false }
            if Bool.random() {
                self.spriteImage = self.easterEggEnabled2024 ? AdaptiveImage.dogcow(colorScheme: self.colorScheme) : AdaptiveImage.stephen(colorScheme: self.colorScheme)
                self.animationImages = self.easterEggEnabled2024 ? AdaptiveImage.dogcowWalkCycle(colorScheme: self.colorScheme) : AdaptiveImage.stephenWalkCycle(colorScheme: self.colorScheme)
                self.isMyke = false
            } else {
                self.spriteImage = self.easterEggEnabled2024 ? AdaptiveImage.jonyCube(colorScheme: self.colorScheme) : AdaptiveImage.myke(colorScheme: self.colorScheme)
                self.animationImages = self.easterEggEnabled2024 ? [AdaptiveImage.jonyCube(colorScheme: self.colorScheme)] : AdaptiveImage.mykeWalkCycle(colorScheme: self.colorScheme)
                self.isMyke = true
                self.direction = false
            }
        }
        .onChange(of: self.easterEggEnabled2024) { _ in
            if(self.easterEggEnabled2024) {
                self.spriteImage = self.isMyke ? AdaptiveImage.jonyCube(colorScheme: self.colorScheme) : AdaptiveImage.dogcow(colorScheme: self.colorScheme)
                self.animationImages = self.isMyke ? [AdaptiveImage.jonyCube(colorScheme: self.colorScheme)] : AdaptiveImage.dogcowWalkCycle(colorScheme: self.colorScheme)
            } else {
                self.spriteImage = self.isMyke ? AdaptiveImage.myke(colorScheme: self.colorScheme) : AdaptiveImage.stephen(colorScheme: self.colorScheme)
                self.animationImages = self.isMyke ? AdaptiveImage.mykeWalkCycle(colorScheme: self.colorScheme) : AdaptiveImage.stephenWalkCycle(colorScheme: self.colorScheme)
            }
        }
        .alert("Secrets!", isPresented: self.$showingKonamiCodeAlert, actions: {
            if(konamiCodeEasterEggEnabled) {
                if(self.easterEggEnabled2024) {
                    Button(action: {}, label: {
                        Text("Keep the vibes goin 😍")
                    })
                    Button(action: {
                        UserDefaults.shared.easterEggEnabled2024.toggle()
                    }, label: {
                        Text("Back to normal pls")
                    })
                } else {
                    Button(action: {
                        UserDefaults.shared.easterEggEnabled2024.toggle()
                        SoundEffectHelper.shared.play(.underworld)
                    }, label: {
                        Text("Oh yes please 😈")
                    })
                    Button(action: {}, label: {
                        Text("Nah I'm good")
                    })
                }
            } else {
                Button(action: {
                    // TODO: Update with our campaign ID
                    self.campaignChoiceID = UUID(uuidString: "FE5B0F18-C993-4987-AAB0-3167E2D3F91A")
                    self.dismiss()
                }, label: {
                    Text("Visit our campaign!")
                })
            }
        }, message: {
            if(konamiCodeEasterEggEnabled) {
                if(self.easterEggEnabled2024) {
                    Text("Had enough? Or are you hungry for more 😈")
                } else {
                    Text("Enable cursed mode?")
                }
            } else {
                Text("Get our campaign to \(formatCurrency(from: konamiCodeEasterEggDollarThreshold, currency: "USD", showFullCurrencySymbol: false).1) to unlock something special!")
            }
        })
    }
}

struct RandomCampaignPickerView2024_Previews: PreviewProvider {
    static var previews: some View {
        RandomCampaignPickerView2024(campaignChoiceID: Binding<UUID?>(get: {return nil}, set: {_ in}), allCampaigns: [])
    }
}
