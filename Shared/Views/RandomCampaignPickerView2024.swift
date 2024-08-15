//
//  RandomCampaignPickerView2024.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/8/24.
//

import SwiftUI



struct RandomCampaignPickerView2024: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Namespace var namespace
    
    @State private var landscapeData = RandomLandscapeData(isForMainScreen: false)
    
    @Binding var campaignChoiceID: UUID?
    @State var allCampaigns: [Campaign]
    @State var chosenCampaign: Campaign? = nil
    
    @State var jumping: Bool = false
    @State var resultOpacity = false
    @State var resultOffset = false
    @State var showShareSheet = false
    
    @State var animationDuration: Double = 0.2
    
    @State var showingResult: Bool = false
    
    @State var spriteOffset: Double = 0.0
    
    var spriteIncrement: Double = 5.0
    
    @State var numBoxes: Int = 3
    
    @State var hitArr: [Bool] = []
    
    @State var spriteX: Double = 0
    @State var boxXArr: [Int: Double] = [:]
    @State var currentBoxUnder: Int? = nil
    
    @State var spriteImage: AdaptiveImage = .stephen(colorScheme: .light)
    @State var animationImages: [AdaptiveImage] = AdaptiveImage.stephenWalkCycle(colorScheme: .light)
    @State var isMyke: Bool = false
    @State private var isMoving: Bool = false
    // false = left, true = right
    @State var direction = true
    
    @State private var justinAnAnimationIsInProgressStopTryingToBreakThingsOkay: Bool = false
    
    func getRandomCampaign() -> Campaign? {
        return allCampaigns.filter({$0.id != RELAY_CAMPAIGN}).randomElement()
    }
    
    func moveSprite(containerGeometry: GeometryProxy, by increment: Double, manual: Bool = true) {
        withAnimation(manual ? .easeInOut(duration: 0.1) : .default) {
            direction = increment > 0
            let desiredPosition = self.spriteOffset + increment
            let minBound: Double
            let maxBound: Double
            
            if isMyke {
                minBound = -(containerGeometry.size.width - 30 - (16 * 10 * Double.spriteScale))
                maxBound = 0
            } else {
                minBound = 0
                maxBound = containerGeometry.size.width - 30 - (16 * 10 * Double.spriteScale)
            }
            
            self.spriteOffset = max(minBound, min(maxBound, desiredPosition))
            
            self.currentBoxUnder = nil
            
            for element in self.boxXArr.sorted(by: {$0.value > $1.value}) {
                let index = element.key
                let spriteMaxX = self.spriteX + Double.hostSpriteWidth
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
            self.spriteImage = AdaptiveImage(colorScheme: self.colorScheme, light: self.isMyke ? .mykeWalk1 : .stephenWalk1)
            if let currentBox = self.currentBoxUnder {
                self.activateBox(currentBox)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                self.jumping = false
                self.spriteImage = self.isMyke ? .myke(colorScheme: self.colorScheme) : .stephen(colorScheme: self.colorScheme)
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
                                            print("up")
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
                                            print("down")
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
                                self.dismiss()
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
                                }
                            Rectangle()
                                .foregroundStyle(.clear)
                                .overlay(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 0) {
                                            if(!self.hitArr.isEmpty) {
                                                ForEach(0..<self.numBoxes) { i in
                                                    Spacer()
                                                    Button(action: {
                                                        if !self.justinAnAnimationIsInProgressStopTryingToBreakThingsOkay {
                                                            withAnimation {
                                                                self.currentBoxUnder = i
                                                                
                                                                var boxOffsetIndex = i
                                                                var offsetMultiplier = 1.0
                                                                var adjustOffset = 0.0
                                                                
                                                                if isMyke {
                                                                    boxOffsetIndex = self.numBoxes - (i + 1)
                                                                    offsetMultiplier = -1
                                                                    adjustOffset = Double.hostSpriteWidth / 3
                                                                }
                                                                
                                                                if let newOffset = self.boxXArr[boxOffsetIndex] {
                                                                    let newSpriteOffset = (newOffset * offsetMultiplier) + adjustOffset
                                                                    self.isMoving = true
                                                                    self.moveSprite(containerGeometry: mainGeometry, by: newSpriteOffset-self.spriteOffset, manual: false)
                                                                }
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
                                                    }
                                                }
                                                Spacer()
                                            }
                                        }
                                        Rectangle()
                                            .foregroundStyle(.clear)
                                            .overlay(alignment: self.jumping ? (self.isMyke ? .topTrailing : .topLeading) : (self.isMyke ? .bottomTrailing : .bottomLeading)) {
                                                AnimatedAdaptiveImage(idleImage: self.$spriteImage, images: self.$animationImages, animating: self.$isMoving)
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
                                .frame(maxHeight: 200)
                        }
                        .padding(.horizontal)
                    }
                    .animation(.easeOut(duration: self.animationDuration), value: self.jumping)
                    .frame(maxHeight: .infinity)
                    .background(alignment: .bottom) {
                        AdaptiveImage.skyRepeatable(colorScheme: self.colorScheme)
                            .tiledImageAtScale(axis: .horizontal)
                    }
            }
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
            .background {
                Color.skyBackground
            }
        }
        .onAppear {
            self.hitArr = (0..<self.numBoxes).map { _ in return false }
            if Bool.random() {
                self.spriteImage = AdaptiveImage.stephen(colorScheme: self.colorScheme)
                self.animationImages = AdaptiveImage.stephenWalkCycle(colorScheme: self.colorScheme)
                self.isMyke = false
            } else {
                self.spriteImage = AdaptiveImage.myke(colorScheme: self.colorScheme)
                self.animationImages = AdaptiveImage.mykeWalkCycle(colorScheme: self.colorScheme)
                self.isMyke = true
                self.direction = false
            }
        }
    }
}

struct RandomCampaignPickerView2024_Previews: PreviewProvider {
    static var previews: some View {
        RandomCampaignPickerView2024(campaignChoiceID: Binding<UUID?>(get: {return nil}, set: {_ in}), allCampaigns: [])
    }
}
