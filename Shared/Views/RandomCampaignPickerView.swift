//
//  RandomCampaignPickerView.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/17/23.
//

import SwiftUI
import Kingfisher
import AVKit

struct RandomCampaignPickerView: View {
    @Binding var isPresented: Bool
    @Binding var campaignChoiceID: UUID?
    @State var allCampaigns: [Campaign]
    @State var chosenCampaign: Campaign?
    
    @State private var animationDuration: Double = 2.25
    
    @State private var wheelRotation: Angle = .degrees(0)
    
    @State private var indexToFlip: Int = 0
    @State private var animationFinished: Bool = false
    @State private var isResetting: Bool = false
    
#if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
#endif
    
    func getRandomCampaign() -> Campaign {
        while true {
            if let random = allCampaigns.randomElement(), random.id != RELAY_CAMPAIGN {
                return random
            }
        }
    }
    
    func playAnimation() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            let angleDegrees = Int(wheelRotation.degrees) + (180 * Int.random(in: 5..<10))
            indexToFlip = (angleDegrees % 360 == 0) ? 0 : 7
            wheelRotation = Angle(degrees: Double(angleDegrees))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+animationDuration, execute: {
            campaignChoiceID = chosenCampaign?.id
#if !os(macOS)
            bounceHaptics.impactOccurred()
#endif
            withAnimation(.spring()) {
                animationFinished = true
            }
        })
    }
    
    @State var wheelRadius: Double = 300
    @State var wedgeCount = 14
    
    var wheelCircumference: Double {
        return 2 * Double.pi * wheelRadius
    }
    
    var sectionWidth: Double {
        return wheelCircumference / Double(wedgeCount)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.confetti)
                .resizable()
                .scaleEffect(animationFinished ? CGSize(width: 3.0, height: 1.0) : .zero)
                .opacity(animationFinished || isResetting ? 0 : 1)
            VStack {
                Text("Random Fundraiser")
                    .font(.largeTitle)
                    .bold()
                if(!animationFinished) {
                    Spacer()
                }
                if let campaign = chosenCampaign, animationFinished {
                    VStack {
                        Spacer()
                        Text(campaign.title)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .font(.title)
                        Text(campaign.user.username)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .italic()
                            .foregroundStyle(.secondary)
                        Button(action: {
                            isPresented = false
                        }, label: {
                            Text("Visit This Campaign!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .padding(.horizontal, 20)
                                .background(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        })
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                animationFinished = false
                                isResetting = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
                                isResetting = false
                                chosenCampaign = getRandomCampaign()
                                playAnimation()
                                SoundEffectHelper.shared.playDrumrollSoundEffect()
                            })
                        }, label: {
                            Text("Spin Again")
                        })
                    }
                }
            }
            .padding([.bottom], wheelRadius*1.25)
        }
        .overlay(alignment:.bottom) {
            WheelLayout(radius: wheelRadius) {
                ForEach(0..<wedgeCount) { index in
                    WheelWedgeView(index: index, isTimeToFlip: $animationFinished, campaign: $chosenCampaign, shouldFlip: index == indexToFlip)
                        .frame(width: sectionWidth, height: wheelRadius)
                        .rotationEffect(Angle(degrees: (360/Double(wedgeCount))*Double(index)))
                }
            }
            .frame(width: wheelRadius*2, height: wheelRadius*2)
            .clipShape(Circle())
            .overlay {
                ZStack {
                    Image(.fullSizeAppIcon)
                        .resizable()
                        .frame(width: wheelRadius/5, height: wheelRadius/5)
                        .overlay {
                            Circle()
                                .stroke(.black, lineWidth: 4)
                        }
                        .clipShape(Circle())
                        .rotationEffect(Angle(degrees: -wheelRotation.degrees))
                        .shadow(radius: 5)
                    Circle()
                        .stroke(.black, lineWidth: 4)
                }
            }
            .rotationEffect(wheelRotation)
            .padding([.bottom], -wheelRadius*(animationFinished ? 0.8 : 0.9))
        }
        .padding()
        .onAppear {
            chosenCampaign = getRandomCampaign()
            playAnimation()
            SoundEffectHelper.shared.playDrumrollSoundEffect()
        }
        .interactiveDismissDisabled()
    }
}

struct WheelWedgeView: View {
    var index: Int
    @Binding var isTimeToFlip: Bool
    @Binding var campaign: Campaign?
    var shouldFlip: Bool
    
    @ViewBuilder
    func image() -> some View {
        if let campaign = campaign, let url = URL(string: campaign.avatar?.src ?? "") {
            KFImage.url(url)
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        Triangle()
            .foregroundStyle(index % 2 == 0 ? WidgetAppearance.stjudeRed : WidgetAppearance.relayYellow)
            .overlay {
                ZStack {
                    if(shouldFlip && isTimeToFlip) {
                        VStack {
                            image()
                                .padding()
                                .padding()
                            Spacer()
                        }
                    }
                    Triangle()
                        .stroke(.black, lineWidth: 2)
                }
            }
            .rotation3DEffect(.degrees(shouldFlip && isTimeToFlip ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.easeInOut, value: isTimeToFlip)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

struct WheelLayout: Layout {
    var radius: Double
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let angle: Double = (2 * Double.pi) / Double(subviews.count)
        
        // apple sample code is the best thank you big tim
        
        for (index, subview) in subviews.enumerated() {
            // Find a vector with an appropriate size and rotation.
            var point = CGPoint(x: 0, y: -radius/2)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index)))
            
            
            // Shift the vector to the middle of the region.
            point.x += bounds.midX
            point.y += bounds.midY
            
            
            // Place the subview.
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
        
    }

}
