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
    
    func getRandomCampaign() -> Campaign? {
        return allCampaigns.filter({$0.id != RELAY_CAMPAIGN}).randomElement()
    }
    
    func moveSprite(containerGeometry: GeometryProxy, by increment: Double) {
        self.spriteOffset = max(0, min(containerGeometry.size.width-30-(16 * 10 * Double.spriteScale), self.spriteOffset + increment))
        
        self.currentBoxUnder = nil
        
        for element in self.boxXArr.sorted(by: {$0.value > $1.value}) {
            let index = element.key
            let spriteMaxX = self.spriteX + Double.stephenWidth
            let boxX = element.value
            let boxMaxX = boxX+Double.questionBoxWidth
            
            if(spriteMaxX > boxX && self.spriteX < boxMaxX) {
                currentBoxUnder = index
                break
            }
        }
    }
    
    func jump(containerGeometry: GeometryProxy) {
        withAnimation {
            self.hitArr = (0..<self.numBoxes).map { _ in return false }
            self.jumping = true
            if let currentBox = self.currentBoxUnder {
                self.showingResult = false
                self.resultOpacity = false
                DispatchQueue.main.asyncAfter(deadline: .now()+(self.animationDuration/2)) {
                    self.resultOffset = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                    withAnimation(.none) {
                        self.chosenCampaign = self.getRandomCampaign()
                    }
                    self.showingResult = true
                    self.jumping = false
                    self.hitArr[currentBox] = true
                    self.resultOpacity = true
                    self.resultOffset = true
                    DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                        self.hitArr = (0..<self.numBoxes).map { _ in return false }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()+self.animationDuration) {
                    self.jumping = false
                }
            }
        }
    }
    
    @ViewBuilder
    func controllerView(containerGeometry: GeometryProxy) -> some View {
        HStack {
            Rectangle()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .overlay(alignment: .center) {
                    GeometryReader { geometry in
                        ZStack(alignment: .center) {
                            Rectangle()
                                .foregroundStyle(.white)
                                .frame(width: geometry.size.width / 3)
                                .overlay {
                                    VStack {
                                        Button(action: {
                                            print("up")
                                        }, label: {
                                            Rectangle()
                                                .foregroundStyle(.white)
                                                .overlay {
                                                    Image(systemName: "chevron.up")
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(PlainButtonStyle())
                                        Spacer()
                                        Button(action: {
                                            print("down")
                                        }, label: {
                                            Rectangle()
                                                .foregroundStyle(.white)
                                                .overlay {
                                                    Image(systemName: "chevron.down")
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            Rectangle()
                                .foregroundStyle(.white)
                                .frame(height: geometry.size.height / 3)
                                .overlay {
                                    HStack {
                                        Button(action: {}, label: {
                                            Rectangle()
                                                .foregroundStyle(.white)
                                                .overlay {
                                                    Image(systemName: "chevron.left")
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(PressAndHoldButtonStyle(action: {
                                            self.moveSprite(containerGeometry: containerGeometry, by: -self.spriteIncrement)
                                        }))
                                        Spacer()
                                        Button(action: {}, label: {
                                            Rectangle()
                                                .foregroundStyle(.white)
                                                .overlay {
                                                    Image(systemName: "chevron.right")
                                                }
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.0, contentMode: .fit)
                                        })
                                        .buttonStyle(PressAndHoldButtonStyle(action: {
                                            self.moveSprite(containerGeometry: containerGeometry, by: self.spriteIncrement)
                                        }))
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            Spacer()
            Rectangle()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .overlay {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Spacer()
                            Button(action: {
                                self.jump(containerGeometry: containerGeometry)
                            }, label: {
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .overlay {
                                        Text("A")
                                    }
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                        HStack(spacing: 0) {
                            Button(action: {
                                self.dismiss()
                            }, label: {
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .overlay {
                                        Text("B")
                                    }
                            })
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                    }
                }
        }
    }
    
    var body: some View {
        GeometryReader { mainGeometry in
            VStack(spacing:0) {
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
                                                Button(action: {
                                                    self.campaignChoiceID = self.chosenCampaign?.id
                                                    self.dismiss()
                                                }, label: {
                                                    Text("View This Campaign")
                                                        .font(.headline)
                                                        .foregroundStyle(.white)
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                })
                                                .buttonStyle(BlockButtonStyle(tint: .accentColor))
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
                                    VStack(alignment: .leading) {
                                        HStack(spacing: 0) {
                                            if(!self.hitArr.isEmpty) {
                                                ForEach(0..<self.numBoxes) { i in
                                                    Spacer()
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
                                                Spacer()
                                            }
                                        }
                                        Rectangle()
                                            .foregroundStyle(.clear)
                                            .overlay(alignment: self.jumping ? .topLeading : .bottomLeading) {
                                                AdaptiveImage.stephen(colorScheme: self.colorScheme)
                                                    .imageAtScale()
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
            .background {
                Color.skyBackground
            }
        }
        .onAppear {
            self.hitArr = (0..<self.numBoxes).map { _ in return false }
        }
    }
}

struct RandomCampaignPickerView2024_Previews: PreviewProvider {
    static var previews: some View {
        RandomCampaignPickerView2024(campaignChoiceID: Binding<UUID?>(get: {return nil}, set: {_ in}), allCampaigns: [])
    }
}
